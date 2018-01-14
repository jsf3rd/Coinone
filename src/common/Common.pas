unit Common;

interface

uses System.SysUtils, System.Classes;

const
  PROJECT_CODE = 'Coin24';

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

  TTraderOption = record
    Coins: TArray<TCoinInfo>;
  end;

const
  OPER_ENABLE = 'enable';
  OPER_DISABLE = 'disable';
  OPER_TEST = 'test';

implementation

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
  if ARate > Self.ShortPoint then
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
