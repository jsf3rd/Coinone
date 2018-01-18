unit CoinState;

interface

uses System.Classes, System.SysUtils, Coinone, cbOption, System.JSON, REST.JSON,
  JdcGlobal.ClassHelper, JdcGlobal, cbGlobal, System.Math, System.DateUtils, Common;

type
  TOnStrEvent = procedure(AParams: String) of object;
  TOnJsonEvent = procedure(AParams: TJSONObject) of object;

  TPriceInfo = record
    Last: Integer;
    Rate: double;
    State: TPriceState;
    Stoch: double;
    Avail: double;
    function ToString: string;
    procedure SetRate(AOldPrice: Integer);
    procedure SetStoch(AHighLow: THighLow);
    function CalcSellCount(ALastOrder: TOrder; ShortDeal: double = 0): double;
    function CalcBuyCount(ALastOrder: TOrder; ShortDeal: double = 0): double;
  end;

  TTrader = class;

  TState = class
  strict protected
    FTrader: TTrader;
    procedure MarketSell(AInfo: TPriceInfo; LastOrder: TOrder; ShortDeal: double = 0);
    procedure MarketBuy(AInfo: TPriceInfo; LastOrder: TOrder; ShortDeal: double = 0);

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

    FOnNewOrder: TOnJsonEvent;
    FOnCancelOrder: TOnStrEvent;

    function GetLastOrder: TOrder;
  public
    constructor Create(ACoin: TCoinInfo);
    destructor Destroy; override;

    procedure Execute(APrice: Integer; AHighLow: THighLow; Avail: double);

    function ExistLimitOrder: boolean;
    procedure Order(AType: TRequestType; ALast: Integer; ACount: double);

    property StateNormal: TState read FStateNormal write FStateNormal;
    property StateOverBought: TState read FStateOverBought write FStateOverBought;
    property StateOverSold: TState read FStateOverSold write FStateOverSold;
    property State: TState write SetState;

    property CoinInfo: TCoinInfo read FCoinInfo;
    property OnNewOrder: TOnJsonEvent read FOnNewOrder write FOnNewOrder;
    property OnCancelOrder: TOnStrEvent read FOnCancelOrder write FOnCancelOrder;
  end;

implementation

{ TState }

procedure TState.MarketSell(AInfo: TPriceInfo; LastOrder: TOrder; ShortDeal: double = 0);
var
  SellCount: double;
begin
  if FTrader.ExistLimitOrder then
  begin
    TGlobal.Obj.ApplicationMessage(msInfo, 'ExistLimitOrder');
    Exit;
  end;

  SellCount := AInfo.CalcSellCount(LastOrder, ShortDeal);

  if (AInfo.Avail - SellCount) < FTrader.CoinInfo.MinCount then
    raise Exception.Create('MinCount Over ' + FTrader.CoinInfo.MinCount.ToString);

  FTrader.Order(rtLimitSell, AInfo.Last, SellCount)
end;

procedure TState.MarketBuy(AInfo: TPriceInfo; LastOrder: TOrder; ShortDeal: double = 0);
begin
  if FTrader.ExistLimitOrder then
  begin
    TGlobal.Obj.ApplicationMessage(msInfo, 'ExistLimitOrder');
    Exit;
  end;

  FTrader.Order(rtLimitBuy, AInfo.Last, AInfo.CalcBuyCount(LastOrder, ShortDeal))
end;

constructor TState.Create(ATrader: TTrader);
begin
  FTrader := ATrader;
end;

procedure TState.Normal(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  FTrader.State := FTrader.StateNormal;
  Self.Free;
end;

procedure TState.OverBought(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  FTrader.State := FTrader.StateOverBought;
  Self.Free;
end;

procedure TState.OverSold(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  FTrader.State := FTrader.StateOverSold;
  Self.Free;
end;

{ TTrader }

constructor TTrader.Create(ACoin: TCoinInfo);
var
  InitOrder: Integer;
  JSONObject: TJSONObject;
begin
  FCoinInfo := ACoin;
  FStateNormal := TStateNormal.Create(Self);
  FStateOverBought := TStateOverBought.Create(Self);
  FStateOverSold := TStateOverSold.Create(Self);

  FCoinone := TCoinone.Create(TOption.Obj.AccessToken, TOption.Obj.SecretKey);
  FState := TState.Create(Self);

  if FCoinInfo.Oper = OPER_ENABLE then
  begin
    TGlobal.Obj.ApplicationMessage(msInfo, 'InitTrader', '%s', [FCoinInfo.ToString]);
  end
  else if FCoinInfo.Oper = OPER_TEST then
  begin
    JSONObject := FCoinone.PublicInfo(rtTicker, 'currency=' + ACoin.Currency);
    try
      InitOrder := round(JSONObject.GetString('last').ToInteger * 0.97);
    finally
      JSONObject.Free;
    end;

    FTestOrder.price := InitOrder.ToString;
    FTestOrder.qty := '100';
    FTestOrder.order_type := 'bid';
    TGlobal.Obj.ApplicationMessage(msDebug, 'TestOrder', 'Currency=%s,%s',
      [ACoin.Currency, FTestOrder.ToString]);
    TGlobal.Obj.ApplicationMessage(msDebug, 'TestState', 'State=%s,%s',
      [FState.ClassName, FCoinInfo.ToString]);
  end
  else
    TGlobal.Obj.ApplicationMessage(msError, 'InitTrader', FCoinInfo.Oper);
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
      Orders := JSONObject.GetJSONArray('completeOrders');
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
      raise Exception.Create('GetLastOrder,' + E.Message);
    end;
  end;
end;

procedure TTrader.Order(AType: TRequestType; ALast: Integer; ACount: double);
  function CreateNewOrderParams(AID: String): TJSONObject;
  begin
    Result := TJSONObject.Create;
    Result.AddPair('order_id', '{' + AID + '}');
    Result.AddPair('coin_code', UpperCase(FCoinInfo.Currency));
    Result.AddPair('order_stamp', Now.ToISO8601);
    Result.AddPair('user_id', TGlobal.Obj.UserID);
    Result.AddPair('price', ALast);
    Result.AddPair('qty', ACount);

    if AType = rtLimitBuy then
      Result.AddPair('order_type', 'bid')
    else
      Result.AddPair('order_type', 'ask');

  end;

var
  Params, res, DSParams: TJSONObject;
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

    TGlobal.Obj.ApplicationMessage(msInfo, 'Order', 'Type=%s,Params=%s',
      [TCoinone.RequestName(AType), Params.ToString]);

    if FCoinInfo.Oper = OPER_ENABLE then
    begin
      res := FCoinone.Order(AType, Params);
      try
        if res.GetString('result') = RES_SUCCESS then
        begin
          DSParams := CreateNewOrderParams(res.GetString('orderId'));
          OnNewOrder(DSParams);
        end;
      finally
        res.Free;
      end;
    end;
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

procedure TTrader.Execute(APrice: Integer; AHighLow: THighLow; Avail: double);
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

  TGlobal.Obj.ApplicationMessage(msDebug, 'Ticker', 'Coin=%s,%s,LastOrder={%s}',
    [FCoinInfo.Currency, PriceInfo.ToString, LastOrder.ToString]);

  if PriceInfo.Stoch > 0.8 then
    FState.OverBought(PriceInfo, LastOrder)
  else if PriceInfo.Stoch < 0.2 then
    FState.OverSold(PriceInfo, LastOrder)
  else
    FState.Normal(PriceInfo, LastOrder);
end;

function TTrader.ExistLimitOrder: boolean;
var
  JSONObject, Params: TJSONObject;
  _MyOrder, res: TJSONObject;
  Orders: TJSONArray;
  I: Integer;
  DateTime: TDateTime;
begin
  Params := TJSONObject.Create;
  try
    Params.AddPair('currency', FCoinInfo.Currency);
    JSONObject := FCoinone.Order(rtMyLimitOrders, Params);
  finally
    Params.Free;
  end;

  try
    Orders := JSONObject.GetJSONArray('limitOrders');
    Result := Orders.Count > 0;

    for I := 0 to Orders.Count - 1 do
    begin
      _MyOrder := Orders.Items[I] as TJSONObject;
      DateTime := UnixToDateTime(_MyOrder.GetString('timestamp').ToInteger);
      DateTime := IncHour(DateTime, 9);

      if MinuteSpan(Now, DateTime) > 10 then
      begin
        Params := TJSONObject.Create;
        try
          Params.AddPair('order_id', _MyOrder.GetString('orderId'));
          Params.AddPair('price', _MyOrder.GetString('price'));
          Params.AddPair('qty', _MyOrder.GetString('qty'));
          if _MyOrder.GetString('type') = 'ask' then
            Params.AddPair('is_ask', '1')
          else
            Params.AddPair('is_ask', '0');
          Params.AddPair('currency', FCoinInfo.Currency);

          try
            res := FCoinone.Order(rtCancelOrder, Params);
            try
              // DB 이력 삭제
              // if res.GetString('result') = RES_SUCCESS then
              // OnCancelOrder('{' + _MyOrder.GetString('orderId') + '}');
            finally
              res.Free;
            end;

            TGlobal.Obj.ApplicationMessage(msDebug, 'CancelOrder', 'RegTime=%s,Type=%s',
              [DateTime.FormatWithoutMSec, _MyOrder.GetString('type')]);
          except
            on E: Exception do
              TGlobal.Obj.ApplicationMessage(msError, 'CancelOrder', E.Message);
          end;
        finally
          Params.Free;
        end;
      end;
    end;
  finally
    JSONObject.Free;
  end;

end;

{ TStateNormal }

procedure TStateNormal.Normal(AInfo: TPriceInfo; LastOrder: TOrder);
var
  ShortState: TPriceState;
begin
  // LongPoint 초과 시 ShortTime 동작 안 함
  if AInfo.State <> psStable then
    Exit;

  ShortState := FTrader.CoinInfo.ShortState(AInfo.Rate);
  case ShortState of
    psStable:
      //
      ;
    psIncrease:
      begin
        if LastOrder.WasSold then
          Exit;

        if AInfo.Stoch > 0.5 then
          MarketSell(AInfo, LastOrder, FTrader.CoinInfo.ShortDeal);
      end;

    psDecrease:
      begin
        if LastOrder.WasBought then
          Exit;

        if AInfo.Stoch < 0.5 then
          MarketBuy(AInfo, LastOrder, FTrader.CoinInfo.ShortDeal);
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

function TPriceInfo.CalcBuyCount(ALastOrder: TOrder; ShortDeal: double = 0): double;
var
  LastValueCount: double;
  MinCount, MaxCount: double;
begin
  Result := Self.Avail * abs(Self.Rate);

  if ALastOrder.WasSold then
  begin
    LastValueCount := ALastOrder.GetValue / Self.Last;
    if ShortDeal = 0 then
    begin
      TGlobal.Obj.ApplicationMessage(msInfo, 'CalcBuyCount', 'LastValueCount=%0.4f,Calc=%0.4f',
        [LastValueCount, Result]);

      // 최종거래 매도금액으로 구매 할 수있는 코인수와 (가용코인수 * 하락분) 중 작은 수 매수
      Result := Min(LastValueCount, Result);
    end
    else
    begin
      // MaxCount 가용코인수 * ( ShortDeal의 1.5배)
      MaxCount := Self.Avail * (ShortDeal * 1.5);
      MinCount := Self.Avail * ShortDeal;
      TGlobal.Obj.ApplicationMessage(msInfo, 'CalcBuyCount',
        'LastValueCount=%0.4f,MaxCalc=%0.4f,MinCalc=%0.4f',
        [LastValueCount, MaxCount, MinCount]);

      // 최종거래 매도금액으로 구매 할 수있는 코인수가 ShortDeal MaxCount, MinCount 넘지않는경우  선택
      // 최종거래 매도금액으로 구매 할 수있는 코인수가 ShortDeal MaxCount, MinCount 넘는 경우 MinCount
      if (LastValueCount < MaxCount) and (LastValueCount > MinCount) then
        Result := LastValueCount
      else
        Result := MinCount;
    end;
  end;

  if Self.Last * Result > 1000000 then
    raise Exception.Create('Value Exception - Over 1,000,000KRW');

end;

function TPriceInfo.CalcSellCount(ALastOrder: TOrder; ShortDeal: double = 0): double;
var
  LastCount: double;
  MinCount, MaxCount: double;
begin
  Result := Self.Avail * abs(Self.Rate);

  if ALastOrder.WasBought then
  begin
    LastCount := ALastOrder.qty.ToDouble;
    if ShortDeal = 0 then
    begin
      // 최종거래에서 매수한 코인 개수와 (가용코인수 * 상승분) 중 작은 수 매도
      TGlobal.Obj.ApplicationMessage(msInfo, 'CalcSellCount', 'LastOrder=%0.4f,Calc=%0.4f',
        [LastCount, Result]);
      Result := Min(LastCount, Result);
    end
    else
    begin
      MaxCount := Self.Avail * (ShortDeal + abs(Self.Rate));
      MinCount := Self.Avail * ShortDeal;
      TGlobal.Obj.ApplicationMessage(msInfo, 'CalcSellCount',
        'LastOrder=%0.4f,MaxCalc=%0.4f,MinCalc=%0.4f', [LastCount, MaxCount, MinCount]);

      if (LastCount < MaxCount) and (LastCount > MinCount) then
        Result := LastCount
      else
        Result := MinCount;
    end;
  end;

  if Self.Last * Result > 1000000 then
    raise Exception.Create('Value Exception - Over 1,000,000KRW');

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
