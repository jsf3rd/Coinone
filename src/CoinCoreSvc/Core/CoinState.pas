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
    LowStoch: double;
    HighStoch: double;
    Avail: double;
    BuyPrice: Integer;
    Rate: double;
    function ToString: string;
    procedure SetLowStoch(AHighLow: THighLow);
    procedure SetHighStoch(AHighLow: THighLow);
    procedure CalcRate;
  private
  end;

  TTrader = class;

  TState = class abstract
  strict protected
    FTrader: TTrader;
    procedure MarketSell(AInfo: TPriceInfo);
    procedure MarketBuy(AInfo: TPriceInfo);
    procedure Deal(AInfo: TPriceInfo);
  public
    procedure OverSold(AInfo: TPriceInfo); virtual;
    procedure OverBought(AInfo: TPriceInfo); virtual;
    procedure Normal(AInfo: TPriceInfo); virtual;
    constructor Create(ATrader: TTrader);
  end;

  TStateInit = class(TState)
  public
    procedure Normal(AInfo: TPriceInfo); override;
    procedure OverBought(AInfo: TPriceInfo); override;
    procedure OverSold(AInfo: TPriceInfo); override;
  end;

  TStateNormal = class(TState)
  public
    procedure OverBought(AInfo: TPriceInfo); override;
    procedure OverSold(AInfo: TPriceInfo); override;
  end;

  TStateOverSold = class(TState)
  public
    procedure Normal(AInfo: TPriceInfo); override;
  end;

  TStateOverBought = class(TState)
  public
    procedure Normal(AInfo: TPriceInfo); override;
  end;

  TTrader = class
  strict private
    FState: TState;

    FStateInit: TState;
    FStateNormal: TState;
    FStateOverSold: TState;
    FStateOverBought: TState;

    procedure SetState(AState: TState);
  strict private
    FCoinone: TCoinone;
    FOption: TTraderOption;
    FHighPrice: Integer;
    FMinusDeal: boolean;

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
    property StateOverBought: TState read FStateOverBought write FStateOverBought;

    property State: TState write SetState;

    property Option: TTraderOption read FOption;
    property HighPrice: Integer read FHighPrice write FHighPrice;
    property MinusDeal: boolean read FMinusDeal write FMinusDeal;
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

procedure TState.Normal(AInfo: TPriceInfo);
begin
  if AInfo.BuyPrice > 0 then
    Deal(AInfo);
end;

procedure TState.OverSold(AInfo: TPriceInfo);
begin
  if AInfo.BuyPrice > 0 then
    Deal(AInfo);
end;

procedure TState.OverBought(AInfo: TPriceInfo);
begin
  if AInfo.BuyPrice > 0 then
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

  if ((DiffRate < 0.95) and (MaxRate > 0.05)) // 최대수익이 5% 이상인 경우 최대수익대비 95% 미만일경우 Deal
    or ((DiffRate < 0.9) and (MaxRate > 0.04)) //
    or ((DiffRate < 0.85) and (MaxRate > 0.03)) //
    or ((DiffRate < 0.75) and (AInfo.Rate > 0.02)) // 현재수익이 2% 이상인 경우 최대수익대비 75% 미만일경우 Deal
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

    if True then

    FTrader.MinusDeal := true;
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
  FStateOverBought := TStateOverBought.Create(Self);
  FStateOverSold := TStateOverSold.Create(Self);

  FCoinone := TCoinone.Create(TOption.Obj.AccessToken, TOption.Obj.SecretKey);
  FState := FStateInit;

  FHighPrice := 0;
  FMinusDeal := False;

  TGlobal.Obj.ApplicationMessage(msInfo, 'InitTrader', FOption.ToString);
end;

destructor TTrader.Destroy;
begin
  FCoinone.Free;

  FStateNormal.Free;
  FStateOverBought.Free;

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
  MinOrderCount: double;
begin
  result := False;
  MinOrderCount := TCoinone.MinOrderCount(FOption.Currency);
  if MinOrderCount > ACount then
    raise Exception.Create('Order Count Upper ' + MinOrderCount.ToString);

  Params := TJSONObject.Create;
  try
    Params.AddPair('price', Format('%d', [ALast]));
    Params.AddPair('qty', Format('%.3f', [ACount - 0.0004])); // 소수점 3자리에서 버림
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
    PriceInfo.SetLowStoch(HighLow);
    HighLow := dmTrader.GetHighLow(FOption.Currency, Option.Stoch * 3);
    PriceInfo.SetHighStoch(HighLow);

    _printLog(FOption.Currency, 'Ticker', 'Coin=%s,%s,HighPrice=%d',
      [FOption.Currency, PriceInfo.ToString, FHighPrice]);

    if FMinusDeal and (PriceInfo.LowStoch > 0.5) then
      FMinusDeal := False;

    if FMinusDeal then
      Exit;

    if PriceInfo.LowStoch <= 0 then
      FState.OverSold(PriceInfo)
    else if PriceInfo.HighStoch > 0.75 then
      FState.OverBought(PriceInfo)
    else
      FState.Normal(PriceInfo);
  except
    on E: Exception do
      raise Exception.Create('Execute,' + E.Message);
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
    Params.AddPair('currency', FOption.Currency);
    JSONObject := FCoinone.Order(rtMyLimitOrders, Params);
  finally
    Params.Free;
  end;

  try
    Orders := JSONObject.GetJSONArray('limitOrders');
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
    JSONObject.Free;
  end;
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
      Params.AddPair('currency', FOption.Currency);
      JSONObject := FCoinone.Order(rtMyCompleteOrders, Params);
    finally
      Params.Free;
    end;

    try
      Orders := JSONObject.GetJSONArray('completeOrders');
      LastOrder := Orders.Items[0] as TJSONObject;
      OrderLog := LastOrder.ToString;

      result := TJson.JsonToRecord<TOrder>(LastOrder);
      result.order_type := LastOrder.GetString('type');
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

{ TPriceInfo }

procedure TPriceInfo.CalcRate;
begin
  if Self.BuyPrice = 0 then
    Self.Rate := 0
  else
    Self.Rate := (Self.Last - Self.BuyPrice) / Self.BuyPrice;
end;

procedure TPriceInfo.SetHighStoch(AHighLow: THighLow);
begin
  if AHighLow.high_price = AHighLow.low_price then
    raise Exception.Create('high_price = low_price, ' + AHighLow.low_price.ToString);

  Self.HighStoch := (Self.Last - AHighLow.low_price) /
    (AHighLow.high_price - AHighLow.low_price);
end;

procedure TPriceInfo.SetLowStoch(AHighLow: THighLow);
begin
  if AHighLow.high_price = AHighLow.low_price then
    raise Exception.Create('high_price = low_price, ' + AHighLow.low_price.ToString);

  Self.LowStoch := (Self.Last - AHighLow.low_price) /
    (AHighLow.high_price - AHighLow.low_price);
end;

function TPriceInfo.ToString: string;
begin
  result := Format('Last=%d,LowStoch=%.3f,HighStoch=%.3f,Avail=%.4f,BuyPrice=%d,Rate=%.3f',
    [Self.Last, Self.LowStoch, Self.HighStoch, Self.Avail, Self.BuyPrice, Self.Rate]);
end;

{ TStateNormal }

procedure TStateNormal.OverBought(AInfo: TPriceInfo);
begin
  if AInfo.BuyPrice = 0 then
    MarketBuy(AInfo);
  FTrader.State := FTrader.StateOverBought;
end;

procedure TStateNormal.OverSold(AInfo: TPriceInfo);
begin
  FTrader.State := FTrader.StateOverSold;
end;

{ TStateOverSold }

procedure TStateOverSold.Normal(AInfo: TPriceInfo);
begin
  if AInfo.BuyPrice = 0 then
    MarketBuy(AInfo);

  FTrader.State := FTrader.StateNormal;
end;

{ TStateInit }

procedure TStateInit.Normal(AInfo: TPriceInfo);
begin
  FTrader.State := FTrader.StateNormal;
end;

procedure TStateInit.OverBought(AInfo: TPriceInfo);
begin
  FTrader.State := FTrader.StateOverBought;
end;

procedure TStateInit.OverSold(AInfo: TPriceInfo);
begin
  FTrader.State := FTrader.StateOverSold;
end;

{ TStateOverBought }

procedure TStateOverBought.Normal(AInfo: TPriceInfo);
begin
  FTrader.State := FTrader.StateNormal;
end;

end.
