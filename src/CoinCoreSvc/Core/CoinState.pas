unit CoinState;

interface

uses System.Classes, System.SysUtils, Coinone, cbOption, System.JSON, REST.JSON,
  JdcGlobal.ClassHelper, JdcGlobal, cbGlobal, System.Math, System.DateUtils, Common;

type
  TOnStrEvent = procedure(AParams: String) of object;
  TOnJsonEvent = procedure(AParams: TJSONObject) of object;

  TLongOverException = class(Exception);
  TLongDealException = class(Exception);
  TLongPointException = class(Exception);

  TPriceInfo = record
    Last: Integer;
    Rate: double;
    State: TPriceState;
    Stoch: double;
    Avail: double;
    Mode: TDealMode;
    function ToString: string;
    procedure SetRate(AOldPrice: Integer);
    procedure SetStoch(AHighLow: THighLow);
    procedure SetState(APoint: double);
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
    procedure OverBought(AInfo: TPriceInfo; LastOrder: TOrder); override;
  end;

  TStateOverSold = class(TState)
  public
    procedure OverBought(AInfo: TPriceInfo; LastOrder: TOrder); override;
    procedure Normal(AInfo: TPriceInfo; LastOrder: TOrder); override;
    procedure OverSold(AInfo: TPriceInfo; LastOrder: TOrder); override;
  end;

  TTrader = class
  strict private
    FShortState: TState;
    FLongState: TState;

    FStateNormal: TState;
    FStateOverBought: TState;
    FStateOverSold: TState;

    procedure SetState(AMode: TDealMode; AState: TState);
  strict private
    FCoinone: TCoinone;
    FCurrency: string;

    FOnNewOrder: TOnJsonEvent;
    FOnCancelOrder: TOnStrEvent;

    function GetLastOrder: TOrder;
  public
    constructor Create(ACurrency: string);
    destructor Destroy; override;

    procedure Execute(APrice: Integer; Avail: double);

    function ExistLimitOrder: boolean;
    procedure Order(AType: TRequestType; ALast: Integer; ACount: double);

    property StateNormal: TState read FStateNormal write FStateNormal;
    property StateOverBought: TState read FStateOverBought write FStateOverBought;
    property StateOverSold: TState read FStateOverSold write FStateOverSold;
    property State[AMode: TDealMode]: TState write SetState;

    property Currency: string read FCurrency;
    property OnNewOrder: TOnJsonEvent read FOnNewOrder write FOnNewOrder;
    property OnCancelOrder: TOnStrEvent read FOnCancelOrder write FOnCancelOrder;
  end;

implementation

uses _dmTrader;

{ TState }

procedure TState.MarketSell(AInfo: TPriceInfo; LastOrder: TOrder);
var
  SellCount: double;
begin
  if FTrader.ExistLimitOrder then
  begin
    TGlobal.Obj.ApplicationMessage(msInfo, 'ExistLimitOrder');
    Exit;
  end;

  SellCount := AInfo.CalcSellCount(LastOrder);
  FTrader.Order(rtLimitSell, AInfo.Last, SellCount)
end;

procedure TState.MarketBuy(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  if FTrader.ExistLimitOrder then
  begin
    TGlobal.Obj.ApplicationMessage(msInfo, 'ExistLimitOrder');
    Exit;
  end;

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

constructor TTrader.Create(ACurrency: string);
begin
  FCurrency := ACurrency;
  FStateNormal := TStateNormal.Create(Self);
  FStateOverBought := TStateOverBought.Create(Self);
  FStateOverSold := TStateOverSold.Create(Self);

  FCoinone := TCoinone.Create(TOption.Obj.AccessToken, TOption.Obj.SecretKey);
  FShortState := FStateNormal;
  FLongState := FStateNormal;

  TGlobal.Obj.ApplicationMessage(msInfo, 'InitTrader', 'Currency=%s', [FCurrency]);
end;

destructor TTrader.Destroy;
begin
  FCoinone.Free;

  FStateNormal.Free;
  FStateOverBought.Free;
  FStateOverSold.Free;

  inherited;
end;

procedure TTrader.SetState(AMode: TDealMode; AState: TState);
var
  OldState: TState;
begin
  if AMode = dmLong then
  begin
    OldState := FLongState;
    FLongState := AState
  end
  else if AMode = dmShort then
  begin
    OldState := FShortState;
    FShortState := AState;
  end
  else
    raise Exception.Create('Unknown deal mode,' + Integer(AMode).ToString);

  TGlobal.Obj.ApplicationMessage(msDebug, 'ChangeState', '%s->%s',
    [OldState.ClassName, AState.ClassName]);
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
      Params.AddPair('currency', FCurrency);
      JSONObject := FCoinone.Order(rtMyCompleteOrders, Params);
    finally
      Params.Free;
    end;

    try
      Orders := JSONObject.GetJSONArray('completeOrders');
      LastOrder := Orders.Items[0] as TJSONObject;
      OrderLog := LastOrder.ToString;

      Result := TJson.JsonToRecord<TOrder>(LastOrder);
      Result.order_type := LastOrder.GetString('type');
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
    Result.AddPair('coin_code', UpperCase(FCurrency));
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
  MinOrderCount := TCoinone.MinOrderCount(FCurrency);
  if MinOrderCount > ACount then
    raise Exception.Create('Order Count Upper ' + MinOrderCount.ToString);

  Params := TJSONObject.Create;
  try
    Params.AddPair('price', Format('%d', [ALast]));
    Params.AddPair('qty', Format('%.4f', [ACount]));
    Params.AddPair('currency', FCurrency);

    TGlobal.Obj.ApplicationMessage(msInfo, 'Order', 'Type=%s,Params=%s',
      [TCoinone.RequestName(AType), Params.ToString]);

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
  finally
    Params.Free;
  end;

end;

procedure TTrader.Execute(APrice: Integer; Avail: double);
var
  LastOrder: TOrder;
  Option: TTraderOption;

  procedure Deal(AMode: TDealMode);
  var
    HighLow: THighLow;
    PriceInfo: TPriceInfo;
    Stoch: Integer;
    Point: double;
    Title: string;
    State: TState;
  begin
    if AMode = dmLong then
    begin
      Stoch := Option.LongStoch;
      Point := Option.LongPoint;
      State := FLongState;
      Title := 'LongTicker';
    end
    else if AMode = dmShort then
    begin
      Stoch := Option.ShortStoch;
      Point := Option.ShortPoint;
      State := FShortState;
      Title := 'ShortTicker';
    end
    else
      raise Exception.Create('Unknown deal mode,' + Integer(AMode).ToString);

    HighLow := dmTrader.GetHighLow(FCurrency, Stoch);
    PriceInfo.Last := APrice;
    PriceInfo.Avail := Avail;
    PriceInfo.SetStoch(HighLow);
    PriceInfo.SetRate(LastOrder.price.ToInteger);
    PriceInfo.SetState(Point);
    PriceInfo.Mode := AMode;

    TGlobal.Obj.ApplicationMessage(msDebug, Title, 'Coin=%s,%s,LastOrder={%s}',
      [FCurrency, PriceInfo.ToString, LastOrder.ToString]);
    if PriceInfo.Stoch > 0.8 then
      State.OverBought(PriceInfo, LastOrder)
    else if PriceInfo.Stoch < 0.2 then
      State.OverSold(PriceInfo, LastOrder)
    else
      State.Normal(PriceInfo, LastOrder);
  end;

begin
  LastOrder := GetLastOrder;
  Option := TGlobal.Obj.TraderOption;

  try
    Deal(dmLong);
  except
    on E: TLongPointException do
    begin
      TGlobal.Obj.ApplicationMessage(msDebug, E.Message);
      Exit;
    end;

    on E: TLongDealException do
    begin
      TGlobal.Obj.ApplicationMessage(msDebug, E.Message);
      Exit;
    end;

    on E: TLongOverException do
    begin
      TGlobal.Obj.ApplicationMessage(msDebug, E.Message);
      Exit;
    end;

    on E: Exception do
      raise Exception.Create('LongDeal,' + E.Message);
  end;

  try
    Deal(dmShort);
  except
    on E: Exception do
      raise Exception.Create('ShortDeal,' + E.Message);
  end;
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
    Params.AddPair('currency', FCurrency);
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
          Params.AddPair('currency', FCurrency);

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
begin
  if (AInfo.Mode = dmLong) and (AInfo.State <> psStable) then
    raise TLongPointException.Create('OverLongPoint');
end;

procedure TStateNormal.OverBought(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  FTrader.State[AInfo.Mode] := FTrader.StateOverBought;

  if AInfo.Mode = dmLong then
    raise TLongOverException.Create('InOverBought');
end;

procedure TStateNormal.OverSold(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  FTrader.State[AInfo.Mode] := FTrader.StateOverSold;

  if AInfo.Mode = dmLong then
    raise TLongOverException.Create('InOverSold');
end;

{ TStateOverBought }

procedure TStateOverBought.Normal(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  FTrader.State[AInfo.Mode] := FTrader.StateNormal;

  if AInfo.State = psIncrease then
  begin
    if (AInfo.Mode = dmShort) and (LastOrder.WasSold) then
      Exit;

    MarketSell(AInfo, LastOrder);

    if AInfo.Mode = dmLong then
      raise TLongDealException.Create('MarketSell');
  end;
end;

procedure TStateOverBought.OverBought(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  if (AInfo.Mode = dmLong) and (AInfo.Stoch > 0.9) then
    raise TLongOverException.Create('InVeryOverBought');
end;

procedure TStateOverBought.OverSold(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  Self.Normal(AInfo, LastOrder);
end;

{ TStateOverSold }

procedure TStateOverSold.Normal(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  FTrader.State[AInfo.Mode] := FTrader.StateNormal;

  if AInfo.State = psDecrease then
  begin
    if (AInfo.Mode = dmShort) and (LastOrder.WasBought) then
      Exit;

    MarketBuy(AInfo, LastOrder);

    if AInfo.Mode = dmLong then
      raise TLongDealException.Create('MarketBuy');
  end;
end;

procedure TStateOverSold.OverBought(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  Self.Normal(AInfo, LastOrder);
end;

procedure TStateOverSold.OverSold(AInfo: TPriceInfo; LastOrder: TOrder);
begin
  if (AInfo.Mode = dmLong) and (AInfo.Stoch < 0.1) then
    raise TLongOverException.Create('InVeryOverSold');
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
  LastValueCount: double;
  MinCount, MaxCount: double;
  Deal: double;
begin
  Deal := TGlobal.Obj.TraderOption.Deal;
  Result := Self.Avail * Deal;

  if ALastOrder.WasSold then
  begin
    LastValueCount := ALastOrder.GetValue / Self.Last;
    MaxCount := Self.Avail * (Deal * 2);
    MinCount := Self.Avail * Deal;
    TGlobal.Obj.ApplicationMessage(msInfo, 'CalcBuyCount',
      'LastValueCount=%0.4f,MaxCalc=%0.4f,MinCalc=%0.4f',
      [LastValueCount, MaxCount, MinCount]);

    // 최종거래 매도금액으로 구매 할 수있는 코인수가 ShortDeal MaxCount, MinCount 넘지않는경우  선택
    // 최종거래 매도금액으로 구매 할 수있는 코인수가 ShortDeal MaxCount, MinCount 넘는 경우 MinCount
    if (LastValueCount < MaxCount) and (LastValueCount > MinCount) then
      Result := LastValueCount
    else if LastValueCount < MinCount then
      // 연속매도 등의 이유로 매수 개수가 작은 경우 해당 매도 수를 포함해서 계산
      Result := (Self.Avail + ALastOrder.qty.ToDouble) * Deal
    else
      Result := MinCount;
  end;

  if Self.Last * Result > 1000000 then
    raise Exception.Create('Value Exception - Over 1,000,000KRW');

end;

function TPriceInfo.CalcSellCount(ALastOrder: TOrder): double;
var
  LastCount: double;
  MinCount, MaxCount: double;
  Deal: double;
begin
  Deal := TGlobal.Obj.TraderOption.Deal;
  Result := Self.Avail * Deal;

  if ALastOrder.WasBought then
  begin
    LastCount := ALastOrder.qty.ToDouble;
    MaxCount := Self.Avail * (Deal * 2);
    MinCount := Self.Avail * Deal;
    TGlobal.Obj.ApplicationMessage(msInfo, 'CalcSellCount',
      'LastOrder=%0.4f,MaxCalc=%0.4f,MinCalc=%0.4f', [LastCount, MaxCount, MinCount]);

    if (LastCount < MaxCount) and (LastCount > MinCount) then
      Result := LastCount
    else
      Result := MinCount;
  end;

  if Self.Last * Result > 1000000 then
    raise Exception.Create('Value Exception - Over 1,000,000KRW');

end;

procedure TPriceInfo.SetState(APoint: double);
begin
  if Self.Rate > APoint then
    Self.State := psIncrease
  else if Self.Rate < -APoint then
    Self.State := psDecrease
  else
    Self.State := psStable;
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
