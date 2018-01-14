unit CoinState;

interface

uses System.Classes, System.SysUtils, Coinone, cbOption, System.JSON, REST.JSON,
  JdcGlobal.ClassHelper, JdcGlobal, cbGlobal, System.Math, System.DateUtils, Common;

type
  TPriceInfo = record
    Last: Integer;
    Rate: double;
    State: TPriceState;
    Stoch: double;
    Avail: double;
    function ToString: string;
    procedure SetRate(AOldPrice: Integer);
    procedure SetStoch(AHighLow: THighLow);
    function CalcSellCount(ALastOrder: TOrder): double;
    function CalcBuyCount(ALastOrder: TOrder): double;
  end;

  TTrader = class;

  TState = class abstract
  strict protected
    FTrader: TTrader;
    procedure MarketSell(AInfo: TPriceInfo; LastOrder: TOrder);
    procedure MarketBuy(AInfo: TPriceInfo; LastOrder: TOrder);

  public
    procedure OverBought(AInfo: TPriceInfo; LastOrder: TOrder); virtual;
    procedure OverSold(AInfo: TPriceInfo; LastOrder: TOrder); virtual;
    procedure Normal(AInfo: TPriceInfo; LastOrder: TOrder); virtual;
    constructor Create(ATrader: TTrader);
  end;

  TStateNormal = class(TState)
  public
    procedure OverBought(AInfo: TPriceInfo; LastOrder: TOrder); override;
    procedure OverSold(AInfo: TPriceInfo; LastOrder: TOrder); override;
    procedure Normal(AInfo: TPriceInfo; LastOrder: TOrder); override;
  end;

  TStateOverBought = class(TState)
  public
    procedure OverSold(AInfo: TPriceInfo; LastOrder: TOrder); override;
    procedure Normal(AInfo: TPriceInfo; LastOrder: TOrder); override;
  end;

  TStateOverSold = class(TState)
  public
    procedure OverBought(AInfo: TPriceInfo; LastOrder: TOrder); override;
    procedure Normal(AInfo: TPriceInfo; LastOrder: TOrder); override;
  end;

  TTrader = class
  strict private
    FState: TState;
    FStateNormal: TState;
    FStateOverBought: TState;
    FStateOverSold: TState;
    procedure SetState(AState: TState);

  strict private
    FCoinone: TCoinone;
    FCoinInfo: TCoinInfo;

    FTestOrder: TOrder;
    function GetLastOrder: TOrder;
  public
    constructor Create(ACoin: TCoinInfo);
    destructor Destroy; override;

    procedure Tick(APrice: Integer; AHighLow: THighLow; Avail: double);

    procedure Order(AType: TRequestType; ALast: Integer; ACount: double);

    property StateNormal: TState read FStateNormal write FStateNormal;
    property StateOverBought: TState read FStateOverBought write FStateOverBought;
    property StateOverSold: TState read FStateOverSold write FStateOverSold;
    property State: TState write SetState;

    property CoinInfo: TCoinInfo read FCoinInfo;

  end;

implementation

{ TState }

procedure TState.MarketSell(AInfo: TPriceInfo; LastOrder: TOrder);
var
  SellCount: double;
begin
  SellCount := AInfo.CalcSellCount(LastOrder);

  if (AInfo.Avail - SellCount) < FTrader.CoinInfo.MinCount then
    raise Exception.Create('MinCount Over ' + FTrader.CoinInfo.MinCount.ToString);

  FTrader.Order(rtLimitSell, AInfo.Last, SellCount)
end;

procedure TState.MarketBuy(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  FTrader.Order(rtLimitBuy, AInfo.Last, AInfo.CalcBuyCount(LastOrder))
end;

constructor TState.Create(ATrader: TTrader);
begin
  FTrader := ATrader;
end;

procedure TState.Normal(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  //
end;

procedure TState.OverBought(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  //
end;

procedure TState.OverSold(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  //
end;

{ TTrader }

constructor TTrader.Create(ACoin: TCoinInfo);
var
  InitOrder: Integer;
begin
  FCoinInfo := ACoin;
  FStateNormal := TStateNormal.Create(Self);
  FStateOverBought := TStateOverBought.Create(Self);
  FStateOverSold := TStateOverSold.Create(Self);

  FCoinone := TCoinone.Create(TOption.Obj.AccessToken, TOption.Obj.SecretKey);
  FState := FStateNormal;

  if FCoinInfo.Oper = OPER_ENABLE then
  begin
    TGlobal.Obj.ApplicationMessage(msDebug, 'InitState', 'State=%s,%s',
      [FState.ClassName, FCoinInfo.ToString]);
  end
  else if FCoinInfo.Oper = OPER_TEST then
  begin
    InitOrder := round(FCoinone.PublicInfo(rtTicker, 'currency=' + ACoin.Currency)
      .GetString('last').ToInteger * 0.95);
    FTestOrder.price := InitOrder.ToString;
    FTestOrder.qty := '100';
    FTestOrder.order_type := 'bid';
    TGlobal.Obj.ApplicationMessage(msDebug, 'TestOrder', 'Currency=%s,%s',
      [ACoin.Currency, FTestOrder.ToString]);
    TGlobal.Obj.ApplicationMessage(msDebug, 'TestState', 'State=%s,%s',
      [FState.ClassName, FCoinInfo.ToString]);
  end
  else
    TGlobal.Obj.ApplicationMessage(msError, 'InitState', FCoinInfo.Oper);
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
var
  FOldState: TState;
begin
  FOldState := FState;
  FState := AState;
  TGlobal.Obj.ApplicationMessage(msDebug, 'ChangeState', '%s->%s',
    [FOldState.ClassName, AState.ClassName]);
end;

function TTrader.GetLastOrder: TOrder;
var
  Params, JSONObject, LastOrder: TJSONObject;
  Orders: TJSONArray;
  OrderLog: string;
begin
  try
    Params := TJSONObject.Create;
    try
      Params.AddPair('currency', FCoinInfo.Currency);
      JSONObject := FCoinone.Order(rtMyCompleteOrders, Params);
    finally
      Params.Free;
    end;

    try
      Orders := JSONObject.GetValue('completeOrders') as TJSONArray;
      LastOrder := Orders.Items[0] as TJSONObject;
      OrderLog := LastOrder.ToString;

      if FCoinInfo.Oper = OPER_ENABLE then
      begin
        Result := TJson.JsonToRecord<TOrder>(LastOrder);
        Result.order_type := LastOrder.GetString('type');
      end
      else if FCoinInfo.Oper = OPER_TEST then
        Result := FTestOrder;
    finally
      JSONObject.Free;
    end;
  except
    on E: Exception do
    begin
      raise Exception.Create(Format('GetLastOrder - MyOrder=%s,E=%s', [OrderLog, E.Message]));
    end;
  end;
end;

procedure TTrader.Order(AType: TRequestType; ALast: Integer; ACount: double);
var
  Params: TJSONObject;
  MinOrderCount: double;
begin
  MinOrderCount := TCoinone.MinOrderCount(FCoinInfo.Currency);
  if MinOrderCount > ACount then
    raise Exception.Create('Order Count Upper ' + MinOrderCount.ToString);

  Params := TJSONObject.Create;
  try
    Params.AddPair('price', Format('%d', [ALast]));
    Params.AddPair('qty', Format('%.4f', [ACount]));
    Params.AddPair('currency', FCoinInfo.Currency);

    TGlobal.Obj.ApplicationMessage(msDebug, 'Order', 'Type=%s,Params=%s',
      [TCoinone.RequestName(AType), Params.ToString]);

    if FCoinInfo.Oper = OPER_ENABLE then
      FCoinone.Order(AType, Params);
  finally
    Params.Free;
  end;

  if FCoinInfo.Oper = OPER_TEST then
  begin
    FTestOrder.timestamp := IntToStr(DateTimeToUnix(Now));
    FTestOrder.price := ALast.ToString;
    if AType = rtLimitBuy then
      FTestOrder.order_type := 'bid'
    else if AType = rtLimitSell then
      FTestOrder.order_type := 'ask';
    FTestOrder.qty := ACount.ToString;
    FTestOrder.orderId := TGUID.NewGuid.ToString;
  end;
end;

procedure TTrader.Tick(APrice: Integer; AHighLow: THighLow; Avail: double);
var
  LastOrder: TOrder;
  PriceInfo: TPriceInfo;
begin
  LastOrder := GetLastOrder;

  PriceInfo.Last := APrice;
  PriceInfo.Avail := Avail;
  PriceInfo.SetRate(LastOrder.price.ToInteger);
  PriceInfo.SetStoch(AHighLow);
  PriceInfo.State := FCoinInfo.LongState(PriceInfo.Rate);

  TGlobal.Obj.ApplicationMessage(msDebug, 'Tick', 'Coin=%s,%s,LastOrder={%s}',
    [FCoinInfo.Currency, PriceInfo.ToString, LastOrder.ToString]);

  if PriceInfo.Stoch > 0.8 then
    FState.OverBought(PriceInfo, LastOrder)
  else if PriceInfo.Stoch < 0.2 then
    FState.OverSold(PriceInfo, LastOrder)
  else
    FState.Normal(PriceInfo, LastOrder);
end;

{ TStateNormal }

procedure TStateNormal.Normal(AInfo: TPriceInfo; LastOrder: TOrder);
var
  ShortState: TPriceState;
  NewInfo: TPriceInfo;
begin
  // LongPoint 초과 시 ShortTime 동작 안 함
  if AInfo.State <> psStable then
    Exit;

  ShortState := FTrader.CoinInfo.ShortState(AInfo.Rate);
  NewInfo := AInfo;
  NewInfo.Rate := FTrader.CoinInfo.ShortDeal;
  case ShortState of
    psStable:
      //
      ;
    psIncrease:
      begin
        if LastOrder.WasSold then
          Exit;

        if AInfo.Stoch > 0.5 then
          MarketSell(AInfo, LastOrder);
      end;

    psDecrease:
      begin
        if LastOrder.WasBought then
          Exit;

        if AInfo.Stoch < 0.5 then
          MarketBuy(AInfo, LastOrder);
      end;
  end;

end;

procedure TStateNormal.OverBought(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  if AInfo.State = psIncrease then
    MarketSell(AInfo, LastOrder);

  FTrader.State := FTrader.StateOverBought;
end;

procedure TStateNormal.OverSold(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  if AInfo.State = psDecrease then
    MarketBuy(AInfo, LastOrder);

  FTrader.State := FTrader.StateOverSold;
end;

{ TStateOverBought }

procedure TStateOverBought.Normal(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  if AInfo.State = psIncrease then
    MarketSell(AInfo, LastOrder);

  FTrader.State := FTrader.StateNormal;
end;

procedure TStateOverBought.OverSold(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  FTrader.State := FTrader.StateNormal;
end;

{ TStateOverSold }

procedure TStateOverSold.Normal(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  if AInfo.State = psDecrease then
    MarketBuy(AInfo, LastOrder);

  FTrader.State := FTrader.StateNormal;
end;

procedure TStateOverSold.OverBought(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  FTrader.State := FTrader.StateNormal;
end;

{ TPriceInfo }

procedure TPriceInfo.SetRate(AOldPrice: Integer);
begin
  if AOldPrice = 0 then
    raise Exception.Create('LastOrder Price = 0');

  Self.Rate := (Self.Last - AOldPrice) / AOldPrice;
end;

function TPriceInfo.CalcBuyCount(ALastOrder: TOrder): double;
var
  Count: double;
begin
  Result := Self.Avail * abs(Self.Rate);

  if ALastOrder.WasSold then
  begin
    Count := ALastOrder.GetValue / Self.Last;
    // 최종거래 매도금액으로 구매 할 수있는 코인수와 (가용코인수 * 하락분) 중 작은 수 매수
    TGlobal.Obj.ApplicationMessage(msDebug, 'CalcBuyCount', 'LastOrder=%0.4f,Calc=%0.4f',
      [Count, Result]);
    Result := Min(Count, Result);
  end;
end;

function TPriceInfo.CalcSellCount(ALastOrder: TOrder): double;
var
  LastCount: double;
begin
  Result := Self.Avail * abs(Self.Rate);

  if ALastOrder.WasBought then
  begin
    LastCount := ALastOrder.qty.ToDouble;
    // 최종거래에서 매수한 코인 개수와 (가용코인수 * 상승분) 중 작은 수 매도
    TGlobal.Obj.ApplicationMessage(msDebug, 'CalcSellCount', 'LastOrder=%0.4f,Calc=%0.4f',
      [LastCount, Result]);
    Result := Min(LastCount, Result);
  end;
end;

procedure TPriceInfo.SetStoch(AHighLow: THighLow);
begin
  if AHighLow.high_price = AHighLow.low_price then
    raise Exception.Create('high_price = low_price, ' + AHighLow.low_price.ToString);

  Self.Stoch := (Self.Last - AHighLow.low_price) / (AHighLow.high_price - AHighLow.low_price);
end;

function TPriceInfo.ToString: string;
begin
  Result := Format('Last=%d,Rate=%.3f,Stoch=%.3f,Avail=%.4f',
    [Self.Last, Self.Rate, Self.Stoch, Self.Avail]);
end;

end.
