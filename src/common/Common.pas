unit Common;

interface

uses System.SysUtils, System.Classes, System.Types;

const
  PROJECT_CODE = 'Coin24';
  DATA_SERVICE_CODE = 'CoinDataSvc';
  CORE_SERVICE_CODE = 'CoinCoreSvc';

type
  TStochType = (stNormal, stOverBought, stOverSold);
  TPriceState = (psStable, psIncrease, psDecrease);

  TCoinInfo = record
    Currency: String; // btc, xrp, qtum...
    ShortPoint: Double; // 단타 등락율
    LongPoint: Double; // 장타 등락율
    StochHour: Integer; // Stoch 최고/최저값 구간
    MinCount: Double; // 최소 가용 코인수
    ShortDeal: Double; // 단타 최초매수매도 량 - 가용코인수 * ShortDeal
    Oper: string; // 가동 - enable, disable, test
    function ToString: string;
    function ShortState(ARate: Double): TPriceState;
    function LongState(ARate: Double): TPriceState;
  end;

const
  OPER_ENABLE = 'enable';
  OPER_DISABLE = 'disable';
  OPER_TEST = 'test';

function EncodeKey(const AKey: string): string;
function DecodeKey(const AEncoded: string): string;

implementation

uses JdcGlobal, IdGlobal;

function DecodeKey(const AEncoded: string): string;
var
  GUID: TGUID;
  IdBytes: TIdBytes;
  Bytes: TBytes;
  Src, Dest: TBytesStream;
const
  ZIP_HEADER = '789C';
begin
  IdBytes := HexStrToBytes(ZIP_HEADER + AEncoded);

  Dest := TBytesStream.Create;
  try
    Src := TBytesStream.Create;
    try
      Src.WriteBuffer(IdBytes[0], Length(IdBytes));
      Src.Position := 0;
      DeCompressStream(Src, Dest, nil);
    finally
      Src.Free;
    end;

    Bytes := Dest.Bytes;
    SetLength(Bytes, Dest.Size);
  finally
    Dest.Free;
  end;

  GUID := TGUID.Create(Bytes);
  result := StringsReplace(GUID.ToString, ['{', '}'], ['', '']);
end;

function EncodeKey(const AKey: string): string;
var
  GUID: TGUID;
  Bytes: TArray<System.Byte>;
  Src: TBytesStream;
  Dest: TBytesStream;
begin
  GUID := StringToGUID('{' + AKey + '}');
  Bytes := GUID.ToByteArray;
  Src := TBytesStream.Create;
  Src.Write(Bytes, Length(Bytes));
  Src.Position := 0;
  Dest := TBytesStream.Create;
  CompressStream(Src, Dest, nil);
  Bytes := Dest.Bytes;
  SetLength(Bytes, Dest.Size);

  result := BytesToHex(Bytes, '').Substring(4);
end;

{ TCoinInfo }

function TCoinInfo.LongState(ARate: Double): TPriceState;
begin
  if ARate > Self.LongPoint then
    result := psIncrease
  else if ARate < -Self.LongPoint then
    result := psDecrease
  else
    result := psStable;
end;

function TCoinInfo.ShortState(ARate: Double): TPriceState;
begin
  if ARate > Self.ShortPoint + Sqr(Self.ShortPoint) then
    result := psIncrease
  else if ARate < -Self.ShortPoint then
    result := psDecrease
  else
    result := psStable;
end;

function TCoinInfo.ToString: string;
begin
  result := format
    ('Currency=%s,ShortPoint=%.2f,LongPoint=%.2f,StochHour=%d,MinCount=%.4f,ShortDeal=%.2f,Oper=%s',
    [Self.Currency, Self.ShortPoint, Self.LongPoint, Self.StochHour, Self.MinCount,
    Self.ShortDeal, Self.Oper]);
end;

end.
