unit CoinState;

interface

uses System.Classes, System.SysUtils, Coinone, cbOption, System.JSON, REST.JSON,
  JdcGlobal.ClassHelper, JdcGlobal, cbGlobal, System.Math, System.DateUtils, Common;

type
  TOnStrEvent = procedure(AParams: String) of object;
  TOnJsonEvent = procedure(AParams: TJSONObject) of object;

  TPriceInfo = record
    Last: Integer;
    State: TPriceState;
    Stoch: double;
    Avail: double;
    BuyPrice: Integer;
    Rate: double;
    function ToString: string;
    procedure SetStoch(AHighLow: THighLow);
    procedure CalcRate;
  private
  end;

  TTrader = class;

  TState = class abstract
  strict private
  strict protected
    FTrader: TTrader;
    procedure MarketSell(AInfo: TPriceInfo);
    procedure MarketBuy(AInfo: TPriceInfo);
    procedure Deal(AInfo: TPriceInfo);
  public
    procedure OverSold(AInfo: TPriceInfo); virtual;
    procedure UnderMiddle(AInfo: TPriceInfo); virtual;
    procedure OverMiddle(AInfo: TPriceInfo); virtual;
    procedure Normal(AInfo: TPriceInfo); virtual;
    constructor Create(ATrader: TTrader);
  end;

  TStateInit = class(TState)
  public
    procedure Normal(AInfo: TPriceInfo); override;
    procedure OverSold(AInfo: TPriceInfo); override;
  end;

  TStateNormal = class(TState)
  public
    procedure UnderMiddle(AInfo: TPriceInfo); override;
  end;

  TStateOverSold = class(TState)
  public
    procedure OverMiddle(AInfo: TPriceInfo); override;
  end;

  TState2ndNormal = class(TState)
  public
    procedure OverSold(AInfo: TPriceInfo); override;
  end;

  TState2ndOverSold = class(TState)
  public
    procedure UnderMiddle(AInfo: TPriceInfo); override;
    procedure OverMiddle(AInfo: TPriceInfo); override;
    procedure Normal(AInfo: TPriceInfo); override;
  end;

  TStateDeal = class(TState)
  public
    procedure UnderMiddle(AInfo: TPriceInfo); override;
    procedure OverMiddle(AInfo: TPriceInfo); override;
    procedure Normal(AInfo: TPriceInfo); override;
  end;

  TTrader = class
  strict private
    FState: TState;

    FStateInit: TState;
    FStateNormal: TState;
    FStateOverSold: TState;
    FStateDeal: TState;
    FState2ndNormal: TState;
    FState2ndOverSold: TState;

    procedure SetState(AState: TState);
  strict private
    FCoinone: TCoinone;
    FOption: TTraderOption;
    FHighPrice: Integer;

    FOnNewOrder: TOnJsonEvent;
    FOnCancelOrder: TOnStrEvent;

    function GetLastOrder: TOrder;
  public
    constructor Create(AOption: TTraderOption);
    destructor Destroy; override;

    procedure Execute(APrice: Integer; Avail: double);

    function ExistLimitOrder: boolean;
    function Order(AType: TRequestType; ALast: Integer; ACount: double): boolean;

    property StateInit: TState read FStateInit write FStateInit;
    property StateNormal: TState read FStateNormal write FStateNormal;
    property StateOverSold: TState read FStateOverSold write FStateOverSold;
    property StateDeal: TState read FStateDeal write FStateDeal;
    property State2ndNormal: TState read FState2ndNormal write FState2ndNormal;
    property State2ndOverSold: TState read FState2ndOverSold write FState2ndOverSold;

    property State: TState write SetState;

    property Option: TTraderOption read FOption;
    property HighPrice: Integer read FHighPrice write FHighPrice;
    property OnNewOrder: TOnJsonEvent read FOnNewOrder write FOnNewOrder;
    property OnCancelOrder: TOnStrEvent read FOnCancelOrder write FOnCancelOrder;
  end;

procedure _printLog(ACurrency, ATitle, AFormat: string; Args: array of const);

implementation

uses _dmTrader;

procedure _printLog(ACurrency, ATitle, AFormat: string; Args: array of const);
begin
  printLog(ChangeFileExt(TGlobal.Obj.ExeName, '_' + ACurrency + '.log'),
    Format(ATitle + ' - ' + AFormat, Args));
end;

{ TState }

procedure TState.MarketSell(AInfo: TPriceInfo);
begin
  if FTrader.ExistLimitOrder then
  begin
    TGlobal.Obj.ApplicationMessage(msInfo, 'ExistLimitOrder');
    Exit;
  end;

  FTrader.Order(rtLimitSell, AInfo.Last, AInfo.Avail);
end;

procedure TState.OverMiddle(AInfo: TPriceInfo);
begin
  Deal(AInfo);
end;

procedure TState.Normal(AInfo: TPriceInfo);
begin
  Deal(AInfo);
end;

procedure TState.OverSold(AInfo: TPriceInfo);
begin
  Deal(AInfo);
end;

procedure TState.UnderMiddle(AInfo: TPriceInfo);
begin
  Deal(AInfo);
end;

procedure TState.Deal(AInfo: TPriceInfo);
var
  MaxRate, DiffRate: double;
begin
  if AInfo.BuyPrice = 0 then
    Exit;

  if FTrader.HighPrice = 0 then
    FTrader.HighPrice := AInfo.Last;

  MaxRate := (FTrader.HighPrice - AInfo.BuyPrice) / AInfo.BuyPrice;

  if (FTrader.HighPrice = AInfo.BuyPrice) or (AInfo.Last = AInfo.BuyPrice) then
    DiffRate := AInfo.Last / FTrader.HighPrice
  else if FTrader.HighPrice = AInfo.Last then
    DiffRate := 1
  else
    DiffRate := abs(AInfo.Rate / MaxRate);

  if ((DiffRate < 0.9) and (MaxRate > 0.05)) // 최대수익이 5% 이상인 경우 최대수익대비 90% 미만일경우 Deal
    or ((DiffRate < 0.8) and (MaxRate > 0.03)) //
    or ((DiffRate < 0.7) and (MaxRate > 0.025)) // 현재수익이 2% 이상인 경우 최대수익대비 75% 미만일경우 Deal
  then
  begin
    _printLog(FTrader.Option.Currency, 'PlusDeal', 'Max=%.3f,DiffRate=%.3f',
      [MaxRate, DiffRate]);
    MarketSell(AInfo);
  end
  else if AInfo.Rate < -0.02 then
  begin
    _printLog(FTrader.Option.Currency, 'MinusDeal', 'Max=%.3f,DiffRate=%.3f',
      [MaxRate, DiffRate]);
    MarketSell(AInfo);
  end
  else if FTrader.HighPrice < AInfo.Last then
    FTrader.HighPrice := AInfo.Last;
end;

procedure TState.MarketBuy(AInfo: TPriceInfo);
begin
  if FTrader.ExistLimitOrder then
  begin
    TGlobal.Obj.ApplicationMessage(msInfo, 'ExistLimitOrder');
    Exit;
  end;

  FTrader.Order(rtLimitBuy, AInfo.Last, FTrader.Option.BuyCount);
  FTrader.HighPrice := 0;
end;

constructor TState.Create(ATrader: TTrader);
begin
  FTrader := ATrader;
end;

{ TTrader }

constructor TTrader.Create(AOption: TTraderOption);
begin
  FOption := AOption;
  FStateInit := TStateInit.Create(Self);
  FStateNormal := TStateNormal.Create(Self);
  FStateDeal := TStateDeal.Create(Self);
  FStateOverSold := TStateOverSold.Create(Self);
  FState2ndNormal := TState2ndNormal.Create(Self);
  FState2ndOverSold := TState2ndOverSold.Create(Self);

  FCoinone := TCoinone.Create(TOption.Obj.AccessToken, TOption.Obj.SecretKey);
  FState := FStateInit;

  FHighPrice := 0;
  TGlobal.Obj.ApplicationMessage(msInfo, 'InitTrader', FOption.ToString);
end;

destructor TTrader.Destroy;
begin
  FCoinone.Free;

  FStateNormal.Free;
  FStateOverSold.Free;
  FStateDeal.Free;
  FState2ndNormal.Free;
  FState2ndOverSold.Free;

  inherited;
end;

procedure TTrader.SetState(AState: TState);
var
  OldState: TState;
begin
  OldState := FState;
  FState := AState;

  _printLog(FOption.Currency, 'ChangeState', '%s->%s', [OldState.ClassName, AState.ClassName]);
end;

function TTrader.Order(AType: TRequestType; ALast: Integer; ACount: double): boolean;
  function GetKrw: Integer;
  var
    JsonObject, _Balance: TJSONObject;
  begin
    JsonObject := FCoinone.AccountInfo(rtBalance);
    _Balance := JsonObject.GetJSONObject('krw');
    result := _Balance.GetString('avail').ToInteger;
  end;

  function CreateNewOrderParams(AID: String): TJSONObject;
  begin
    result := TJSONObject.Create;
    result.AddPair('order_id', '{' + AID + '}');
    result.AddPair('coin_code', UpperCase(FOption.Currency));
    result.AddPair('order_stamp', Now.ToISO8601);
    result.AddPair('user_id', TGlobal.Obj.UserID);
    result.AddPair('price', ALast);
    result.AddPair('qty', ACount);

    if AType = rtLimitBuy then
      result.AddPair('order_type', 'bid')
    else
      result.AddPair('order_type', 'ask');
  end;

var
  Params, res, DSParams: TJSONObject;
  MinOrderCount, BuyValue: double;
  krw: Integer;
  LCount: string;
begin
  result := False;
  MinOrderCount := TCoinone.MinOrderCount(FOption.Currency);
  if MinOrderCount > ACount then
    raise Exception.Create('Order Count Upper ' + MinOrderCount.ToString);

  if AType = rtLimitBuy then
  begin
    BuyValue := ALast * ACount;
    krw := GetKrw;
    if BuyValue < krw then
      LCount := Format('%.3f', [ACount - 0.0004])
    else if krw > 100000 then
      LCount := Format('%.3f', [(krw / ALast) - 0.0004])
    else
    begin
      _printLog(FOption.Currency, 'Order', 'lack of balance,coin=%s,order=%.0f,krw=%d',
        [FOption.Currency, BuyValue, krw]);
      Exit;
    end;
  end
  else
    LCount := Format('%.3f', [ACount - 0.0004]);

  Params := TJSONObject.Create;
  try
    Params.AddPair('price', Format('%d', [ALast]));
    Params.AddPair('qty', LCount); // 소수점 3자리에서 버림
    Params.AddPair('currency', FOption.Currency);

    _printLog(FOption.Currency, 'Order', 'Type=%s,Params=%s',
      [TCoinone.RequestName(AType), Params.ToString]);

    res := FCoinone.Order(AType, Params);
    try
      if res.GetString('result') = RES_SUCCESS then
      begin
        result := true;
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
  HighLow: THighLow;
  PriceInfo: TPriceInfo;
  LastOrder: TOrder;
begin
  LastOrder := GetLastOrder;
  if LastOrder.order_type = 'bid' then
    PriceInfo.BuyPrice := LastOrder.price.ToInteger
  else
  begin
    PriceInfo.BuyPrice := 0;
    FHighPrice := 0;
  end;

  try
    PriceInfo.Last := APrice;
    PriceInfo.CalcRate;

    PriceInfo.Avail := Avail;

    HighLow := dmTrader.GetHighLow(FOption.Currency, Option.Stoch);
    PriceInfo.SetStoch(HighLow);

    _printLog(FOption.Currency, 'Ticker', 'Coin=%s,%s,HighPrice=%d',
      [FOption.Currency, PriceInfo.ToString, FHighPrice]);

    if PriceInfo.Stoch <= 0 then
      FState.OverSold(PriceInfo)
    else if PriceInfo.Stoch < 0.2 then
      FState.UnderMiddle(PriceInfo)
    else if PriceInfo.Stoch > 0.4 then
      FState.OverMiddle(PriceInfo)
    else
      FState.Normal(PriceInfo);
  except
    on E: Exception do
      raise Exception.Create('Execute,' + E.Message);
  end;
end;

function TTrader.ExistLimitOrder: boolean;
var
  JsonObject, Params: TJSONObject;
  _MyOrder, res: TJSONObject;
  Orders: TJSONArray;
  I: Integer;
  DateTime: TDateTime;
begin
  Params := TJSONObject.Create;
  try
    Params.AddPair('currency', FOption.Currency);
    JsonObject := FCoinone.Order(rtMyLimitOrders, Params);
  finally
    Params.Free;
  end;

  try
    Orders := JsonObject.GetJSONArray('limitOrders');
    result := Orders.Count > 0;

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
          Params.AddPair('currency', FOption.Currency);

          try

            res := FCoinone.Order(rtCancelOrder, Params);
            try
              // DB 이력 삭제
              // if res.GetString('result') = RES_SUCCESS then
              // OnCancelOrder('{' + _MyOrder.GetString('orderId') + ' } ');
            finally
              res.Free;
            end;

            _printLog(FOption.Currency, 'CancelOrder', 'RegTime=%s,Type=%s',
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
    JsonObject.Free;
  end;
end;

function TTrader.GetLastOrder: TOrder;
var
  Params, JsonObject, LastOrder: TJSONObject;
  Orders: TJSONArray;
  OrderLog: string;
begin
  try
    Params := TJSONObject.Create;
    try
      Params.AddPair('currency', FOption.Currency);
      JsonObject := FCoinone.Order(rtMyCompleteOrders, Params);
    finally
      Params.Free;
    end;

    try
      Orders := JsonObject.GetJSONArray('completeOrders');
      LastOrder := Orders.Items[0] as TJSONObject;
      OrderLog := LastOrder.ToString;

      result := TJson.JsonToRecord<TOrder>(LastOrder);
      result.order_type := LastOrder.GetString('type');
    finally
      JsonObject.Free;
    end;
  except
    on E: Exception do
    begin
      raise Exception.Create('GetLastOrder,' + E.Message);
    end;
  end;

end;

{ TPriceInfo }

procedure TPriceInfo.CalcRate;
begin
  if Self.BuyPrice = 0 then
    Self.Rate := 0
  else
    Self.Rate := (Self.Last - Self.BuyPrice) / Self.BuyPrice;
end;

procedure TPriceInfo.SetStoch(AHighLow: THighLow);
begin
  if AHighLow.high_price = AHighLow.low_price then
    raise Exception.Create('high_price = low_price, ' + AHighLow.low_price.ToString);

  Self.Stoch := (Self.Last - AHighLow.low_price) / (AHighLow.high_price - AHighLow.low_price);
end;

function TPriceInfo.ToString: string;
begin
  result := Format('Last=%d,Stoch=%.3f,Avail=%.4f,BuyPrice=%d,Rate=%.3f',
    [Self.Last, Self.Stoch, Self.Avail, Self.BuyPrice, Self.Rate]);
end;

{ TStateNormal }

procedure TStateNormal.UnderMiddle(AInfo: TPriceInfo);
begin
  FTrader.State := FTrader.StateOverSold;
end;

{ TStateOverSold }

procedure TStateOverSold.OverMiddle(AInfo: TPriceInfo);
begin
  FTrader.State := FTrader.State2ndNormal;
end;

{ TStateInit }

procedure TStateInit.Normal(AInfo: TPriceInfo);
begin
  FTrader.State := FTrader.StateNormal;
end;

procedure TStateInit.OverSold(AInfo: TPriceInfo);
begin
  FTrader.State := FTrader.StateOverSold;
end;

{ TStateDeal }

procedure TStateDeal.Normal(AInfo: TPriceInfo);
begin
  inherited;

  if AInfo.BuyPrice = 0 then
    FTrader.State := FTrader.StateNormal;
end;

procedure TStateDeal.OverMiddle(AInfo: TPriceInfo);
begin
  inherited;

  if AInfo.BuyPrice = 0 then
    FTrader.State := FTrader.StateNormal;
end;

procedure TStateDeal.UnderMiddle(AInfo: TPriceInfo);
begin
  inherited;

  if AInfo.BuyPrice = 0 then
    FTrader.State := FTrader.StateNormal;
end;

{ TState2ndOverSold }

procedure TState2ndOverSold.Normal(AInfo: TPriceInfo);
begin
  if AInfo.BuyPrice = 0 then
    MarketBuy(AInfo);

  FTrader.State := FTrader.StateDeal;
end;

procedure TState2ndOverSold.OverMiddle(AInfo: TPriceInfo);
begin
  if AInfo.BuyPrice = 0 then
    MarketBuy(AInfo);

  FTrader.State := FTrader.StateDeal;
end;

procedure TState2ndOverSold.UnderMiddle(AInfo: TPriceInfo);
begin
  if AInfo.BuyPrice = 0 then
    MarketBuy(AInfo);

  FTrader.State := FTrader.StateDeal;
end;

{ TState2ndNormal }

procedure TState2ndNormal.OverSold(AInfo: TPriceInfo);
begin
  FTrader.State := FTrader.State2ndOverSold;
end;

end.
