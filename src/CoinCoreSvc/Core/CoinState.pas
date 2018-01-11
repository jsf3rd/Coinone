unit CoinState;

interface

uses System.Classes, System.SysUtils, Coinone, cbOption, System.JSON, REST.JSON,
  JdcGlobal.ClassHelper, JdcGlobal, cbGlobal, System.Math;

type

  TStochType = (stNormal, stOverBought, stOverSold);
  TPriceState = (psStable, psIncrease, psDecrease);

  TPriceInfo = record
    Rate: double;
    State: TPriceState;
  end;

  TTrader = class;

  TState = class
  strict protected
    FTrader: TTrader;
    function CalcSellCount(ARate: double; AQty: double; Avail: double): double;
    function CalcBuyValue(ARate: double; AOrder: TOrder; Avail: double): Integer;

  public
    procedure OverBought(AInfo: TPriceInfo; AOrder: TOrder; Avail: double); virtual;
    procedure OverSold(AInfo: TPriceInfo; AOrder: TOrder; Avail: double); virtual;
    procedure Normal(AInfo: TPriceInfo; AOrder: TOrder; Avail: double); virtual;
    constructor Create(ATrader: TTrader);
  end;

  TStateNormal = class(TState)
  public
    procedure OverBought(AInfo: TPriceInfo; AOrder: TOrder; Avail: double); override;
    procedure OverSold(AInfo: TPriceInfo; AOrder: TOrder; Avail: double); override;
    procedure Normal(AInfo: TPriceInfo; AOrder: TOrder; Avail: double); override;
  end;

  TStateOverBought = class(TState)
  public
    procedure OverSold(AInfo: TPriceInfo; AOrder: TOrder; Avail: double); override;
    procedure Normal(AInfo: TPriceInfo; AOrder: TOrder; Avail: double); override;
  end;

  TStateOverSold = class(TState)
  public
    procedure OverBought(AInfo: TPriceInfo; AOrder: TOrder; Avail: double); override;
    procedure Normal(AInfo: TPriceInfo; AOrder: TOrder; Avail: double); override;
  end;

  TTrader = class
  strict private
    FCoin: string;
    FPoint: double;

    FCoinone: TCoinone;

    FState: TState;
    FStateNormal: TState;
    FStateOverBought: TState;
    FStateOverSold: TState;
    procedure SetState(AState: TState);
  private
    function GetLastOrder: TOrder;
    procedure _Order(APrice: Integer; ACount: double; AType: TRequestType);
  public
    constructor Create(ACoin: String; APoint: double);
    destructor Destroy; override;

    procedure Tick(APrice: Integer; AHighLow: THigLow; Avail: double);

    procedure OrderByCoinCount(AType: TRequestType; ACount: double);
    procedure OrderByValue(AType: TRequestType; AValue: Integer);

    property StateNormal: TState read FStateNormal write FStateNormal;
    property StateOverBought: TState read FStateOverBought write FStateOverBought;
    property StateOverSold: TState read FStateOverSold write FStateOverSold;
    property State: TState write SetState;
  end;

implementation

{ TState }

function TState.CalcBuyValue(ARate: double; AOrder: TOrder; Avail: double): Integer;
begin
  // 최종거래 매도금액과 (가용코인수 * 하락분 * 최종거래 단가) 중 작은 금액 만큼 매수
  Result := round((Avail * ARate) * AOrder.price.ToInteger);

  TGlobal.Obj.ApplicationMessage(msDebug, 'CalcBuyValue', 'LastOrder=%d,Calc=%d',
    [AOrder.GetValue, Result]);
  Result := Min(AOrder.GetValue, Result);
end;

function TState.CalcSellCount(ARate: double; AQty: double; Avail: double): double;
begin
  // 최종거래 매수개수와 (가용코인수 * 상승분) 중 작은 수 매도
  Result := Avail * ARate;
  TGlobal.Obj.ApplicationMessage(msDebug, 'CalcSellCount', 'LastOrder=%0.4f,Calc=%0.4f',
    [AQty, Result]);
  Result := Min(Result, AQty);
end;

constructor TState.Create(ATrader: TTrader);
begin
  FTrader := ATrader;
end;

procedure TState.Normal(AInfo: TPriceInfo; AOrder: TOrder; Avail: double);
begin
  //
end;

procedure TState.OverBought(AInfo: TPriceInfo; AOrder: TOrder; Avail: double);
begin
  //
end;

procedure TState.OverSold(AInfo: TPriceInfo; AOrder: TOrder; Avail: double);
begin
  //
end;

{ TTrader }

constructor TTrader.Create(ACoin: String; APoint: double);
begin
  FCoin := ACoin;
  FPoint := APoint;
  FStateNormal := TStateNormal.Create(Self);
  FStateOverBought := TStateOverBought.Create(Self);
  FStateOverSold := TStateOverSold.Create(Self);

  FState := FStateNormal;
  FCoinone := TCoinone.Create(TOption.Obj.AccessToken, TOption.Obj.SecretKey);
end;

destructor TTrader.Destroy;
begin
  FCoinone.Free;

  FStateNormal.Free;
  FStateOverBought.Free;
  FStateOverSold.Free;

  inherited;
end;

procedure TTrader.SetState(AState: TState);
begin
  TGlobal.Obj.ApplicationMessage(msDebug, 'ChangeState', AState.ClassName);
  FState := AState;
end;

function TTrader.GetLastOrder: TOrder;
var
  Params, JSONObject, LastOrder: TJSONObject;
  Orders: TJSONArray;

begin
  Params := TJSONObject.Create;
  Params.AddPair('currency', FCoin);

  JSONObject := FCoinone.Order(rtRecentCompleteOrders, Params);
  try
    Orders := JSONObject.GetValue('completeOrders') as TJSONArray;
    LastOrder := Orders.Items[0] as TJSONObject;
    Result := TJson.JsonToRecord<TOrder>(LastOrder);
    Result.order_type := LastOrder.GetString('type');
  finally
    JSONObject.Free;
  end;
end;

procedure TTrader.OrderByCoinCount(AType: TRequestType; ACount: double);
var
  Ticker: TJSONObject;
  Last: Integer;
begin
  Ticker := FCoinone.PublicInfo(rtTicker, FCoin);
  Last := Ticker.GetString('last').ToInteger;
  Ticker.Free;
  _Order(Last, ACount, AType);
end;

procedure TTrader.OrderByValue(AType: TRequestType; AValue: Integer);
var
  Ticker: TJSONObject;
  Count: double;
  Last: Integer;
begin
  Ticker := FCoinone.PublicInfo(rtTicker, FCoin);
  Last := Ticker.GetString('last').ToInteger;
  Ticker.Free;

  Count := AValue / Last;
  _Order(Last, Count, AType);
end;

procedure TTrader.Tick(APrice: Integer; AHighLow: THigLow; Avail: double);
var
  Params, JSONObject: TJSONObject;
  Orders: TJSONArray;
  MyOrder: TOrder;
  Stoch: double;

  StochType: TStochType;

  PriceInfo: TPriceInfo;
begin
  MyOrder := GetLastOrder;
  PriceInfo.Rate := (APrice - MyOrder.price.ToInteger) / MyOrder.price.ToInteger;
  Stoch := (APrice - AHighLow.low_price) / (AHighLow.high_price - AHighLow.low_price);

  if PriceInfo.Rate > FPoint then
    PriceInfo.State := psIncrease
  else if PriceInfo.Rate < -FPoint then
    PriceInfo.State := psDecrease
  else
    PriceInfo.State := psStable;

  TGlobal.Obj.ApplicationMessage(msDebug, 'Tick', 'Rate=%.4f,Avail=%.4f,Order=%s',
    [PriceInfo.Rate, Avail, TJson.RecordToJsonString(MyOrder)]);

  if Stoch >= 80 then
    FState.OverBought(PriceInfo, MyOrder, Avail)
  else if Stoch <= 20 then
    FState.OverSold(PriceInfo, MyOrder, Avail)
  else
    FState.Normal(PriceInfo, MyOrder, Avail);
end;

procedure TTrader._Order(APrice: Integer; ACount: double; AType: TRequestType);
var
  Params, res: TJSONObject;
begin
  Params := TJSONObject.Create;
  Params.AddPair('price', Format('%d', [APrice]));
  Params.AddPair('qty', Format('%.4f', [ACount]));
  Params.AddPair('currency', FCoin);

  TGlobal.Obj.ApplicationMessage(msDebug, '_Order', 'Type=%d,Params=%s',
    [Integer(AType), Params.ToString]);

  res := FCoinone.Order(AType, Params);

  if res.GetString('result') <> 'success' then
    TGlobal.Obj.ApplicationMessage(msError, 'Order', res.ToString);

end;

{ TStateNormal }

procedure TStateNormal.Normal(AInfo: TPriceInfo; AOrder: TOrder; Avail: double);
var
  MyCount: double;
  MyValue: Integer;
begin
  if AInfo.State = psStable then
  begin
    TGlobal.Obj.ApplicationMessage(msDebug, 'NormalOnNormal');
    Exit;
  end;

  if (AInfo.State = psIncrease) and (AOrder.order_type = 'bid') then
  begin
    MyCount := CalcSellCount(AInfo.Rate, AOrder.qty.ToDouble, Avail);
    FTrader.OrderByCoinCount(rtLimitSell, MyCount);
    Exit;
  end;

  if (AInfo.State = psDecrease) and (AOrder.order_type = 'ask') then
  begin
    MyValue := CalcBuyValue(AInfo.Rate, AOrder, Avail);
    FTrader.OrderByValue(rtLimitBuy, MyValue);
    Exit;
  end;

  TGlobal.Obj.ApplicationMessage(msWarning, 'NormalOnNormal');
end;

procedure TStateNormal.OverBought(AInfo: TPriceInfo; AOrder: TOrder; Avail: double);
var
  MyCount: double;
begin

  if (AInfo.State = psIncrease) then
  begin
    // 매도
    if (AOrder.order_type = 'ask') then
      FTrader.OrderByCoinCount(rtLimitSell, Avail * AInfo.Rate)
    else
    begin
      MyCount := CalcSellCount(AInfo.Rate, AOrder.qty.ToDouble, Avail);
      FTrader.OrderByCoinCount(rtLimitSell, MyCount);
    end;
  end;

  FTrader.State := FTrader.StateOverBought;
end;

procedure TStateNormal.OverSold(AInfo: TPriceInfo; AOrder: TOrder; Avail: double);
var
  MyValue: Integer;
begin

  if AInfo.State = psDecrease then
  begin
    // 매수
    if (AOrder.order_type = 'bid') then
      FTrader.OrderByCoinCount(rtLimitBuy, Avail * AInfo.Rate)
    else
    begin
      MyValue := CalcBuyValue(AInfo.Rate, AOrder, Avail);
      FTrader.OrderByValue(rtLimitBuy, MyValue);
    end;
  end;

  FTrader.State := FTrader.StateOverSold;
end;

{ TStateOverBought }

procedure TStateOverBought.Normal(AInfo: TPriceInfo; AOrder: TOrder; Avail: double);
var
  MyCount: double;
begin
  if AInfo.State = psIncrease then
  begin
    // 매도
    if (AOrder.order_type = 'ask') then
      FTrader.OrderByCoinCount(rtLimitSell, Avail * AInfo.Rate)
    else
    begin
      MyCount := CalcSellCount(AInfo.Rate, AOrder.qty.ToDouble, Avail);
      FTrader.OrderByCoinCount(rtLimitSell, MyCount);
    end;
  end;

  FTrader.State := FTrader.StateNormal;
end;

procedure TStateOverBought.OverSold(AInfo: TPriceInfo; AOrder: TOrder; Avail: double);
begin
  FTrader.State := FTrader.StateNormal;
end;

{ TStateOverSold }

procedure TStateOverSold.Normal(AInfo: TPriceInfo; AOrder: TOrder; Avail: double);
var
  MyValue: Integer;
begin

  if AInfo.State = psDecrease then
  begin
    // 매수
    if (AOrder.order_type = 'bid') then
      FTrader.OrderByCoinCount(rtLimitBuy, Avail * AInfo.Rate)
    else
    begin
      MyValue := CalcBuyValue(AInfo.Rate, AOrder, Avail);
      FTrader.OrderByValue(rtLimitBuy, MyValue);
    end;
  end;

  FTrader.State := FTrader.StateNormal;
end;

procedure TStateOverSold.OverBought(AInfo: TPriceInfo; AOrder: TOrder; Avail: double);
begin
  FTrader.State := FTrader.StateNormal;
end;

end.
