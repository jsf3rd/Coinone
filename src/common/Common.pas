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

  TTraderOption = record
    Currency: String;
    DiffRate: double;
    Deal: double;
    function ToString: string;
  end;

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

{ TTraderOption }

function TTraderOption.ToString: string;
begin
  result := format('Currency=%s,Deal=%.2f,DiffRate=%.2f',
    [Self.Currency, Self.Deal, Self.DiffRate]);
end;

end.
