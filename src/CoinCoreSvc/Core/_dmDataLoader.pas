unit _dmDataLoader;

interface

uses
  System.SysUtils, System.Classes, Data.DBXDataSnap, IPPeerClient,
  Data.DBXCommon, Data.DbxHTTPLayer, Data.DB, Data.SqlExpr, ServerMethodsClient, Coinone,
  System.JSON, REST.JSON, System.DateUtils, System.Generics.Collections, JdcGlobal.ClassHelper,
  JdcGlobal, cbGlobal, Common, Datasnap.DSClientRest, _dmTrader, System.Threading, cbOption;

type
  TDay = record
    volume: double;
    first_price: double;
    last_price: double;
    high_price: double;
    low_price: double;
    day_stamp: TDateTime;
    coin_code: string;
    amount: double;
  end;

  TTicker = record
    volume: double;
    yesterday_volume: double;
    price: double;
    yesterday_last: double;
    tick_stamp: TDateTime;
    coin_code: string;
  end;

  TdmDataLoader = class(TDataModule)
    DSRestConnection: TDSRestConnection;
  private
    FInstanceOwner: Boolean;
    FsmDataProviderClient: TsmDataProviderClient;
    FsmDataLoaderClient: TsmDataLoaderClient;

    FCoinone: TCoinone;

    function GetsmDataProviderClient: TsmDataProviderClient;
    function GetsmDataLoaderClient: TsmDataLoaderClient;

    function CreateTickParams(ATime: TDateTime; ATicker: TJSONObject): TJSONArray;
    procedure UploadTicker(Ticker: TJSONObject);
    procedure ExecuteTrader(Ticker: TJSONObject);
  public
    procedure UploadOrderRate(ATime: TDateTime); // TODO

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property InstanceOwner: Boolean read FInstanceOwner write FInstanceOwner;
    property smDataProviderClient: TsmDataProviderClient read GetsmDataProviderClient
      write FsmDataProviderClient;
    property smDataLoaderClient: TsmDataLoaderClient read GetsmDataLoaderClient
      write FsmDataLoaderClient;

    procedure OnTicker;
    procedure Init;
  end;

var
  dmDataLoader: TdmDataLoader;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

constructor TdmDataLoader.Create(AOwner: TComponent);
begin
  inherited;
  FInstanceOwner := True;
end;

function TdmDataLoader.CreateTickParams(ATime: TDateTime; ATicker: TJSONObject): TJSONArray;
var
  _Tick: TJSONObject;
  Ticker: TTicker;
  I: Integer;
begin
  result := TJSONArray.Create;

  for I := Low(Coins) to High(Coins) do
  begin
    if Coins[I] = 'krw' then
      Continue;

    _Tick := ATicker.GetJSONObject(Coins[I]);
    Ticker.volume := _Tick.GetString('volume').ToDouble;
    Ticker.yesterday_volume := _Tick.GetString('yesterday_volume').ToDouble;
    Ticker.price := _Tick.GetString('last').ToDouble;
    Ticker.yesterday_last := _Tick.GetString('yesterday_last').ToDouble;
    Ticker.tick_stamp := ATime;
    Ticker.coin_code := UpperCase(Coins[I]);
    result.Add(TJson.RecordToJsonObject(Ticker));
  end;
end;

destructor TdmDataLoader.Destroy;
begin
  if Assigned(FCoinone) then
    FreeAndNil(FCoinone);

  FsmDataProviderClient.Free;
  FsmDataLoaderClient.Free;
  inherited;
end;

function TdmDataLoader.GetsmDataProviderClient: TsmDataProviderClient;
begin
  if FsmDataProviderClient = nil then
    FsmDataProviderClient := TsmDataProviderClient.Create(DSRestConnection, FInstanceOwner);

  result := FsmDataProviderClient;
end;

procedure TdmDataLoader.Init;
begin
  DSRestConnection.Host := TGlobal.Obj.ConnInfo.StringValue;
  DSRestConnection.Port := TGlobal.Obj.ConnInfo.IntegerValue;

  try
    if TGlobal.Obj.UseUploadTicker then
      TGlobal.Obj.ApplicationMessage(msDebug, 'Init UploadTicker.');

    FCoinone := TCoinone.Create(TOption.Obj.AccessToken, TOption.Obj.SecretKey);
  except
    on E: Exception do
    begin
      TGlobal.Obj.ApplicationMessage(msError, 'Coninone', E.Message);
      raise;
    end;
  end;
end;

procedure TdmDataLoader.ExecuteTrader(Ticker: TJSONObject);
var
  Balance: TJSONObject;
begin
  Balance := FCoinone.AccountInfo(rtBalance);
  try
    dmTrader.Execute(Ticker, Balance);
  finally
    Balance.Free;
  end;
end;

procedure TdmDataLoader.UploadOrderRate(ATime: TDateTime);
  function SumQty(JSONArray: TJSONArray): double;
  var
    MyElem: TJSONValue;
  begin
    result := 0;
    for MyElem in JSONArray do
      result := result + (MyElem as TJSONObject).GetString('qty').ToDouble;
  end;

var
  OrderBook: TJSONObject;
  I: Integer;
  bid, ask: TJSONArray;
  bidQty, askQty: double;
  Rate: double;
begin
  for I := Low(Coins) to High(Coins) do
  begin
    OrderBook := FCoinone.PublicInfo(rtOrderbook, 'currency=' + Coins[I]);
    bid := OrderBook.GetJSONArray('bid');
    bidQty := SumQty(bid);
    ask := OrderBook.GetJSONArray('ask');
    askQty := SumQty(ask);
    Rate := askQty / bidQty;
    TGlobal.Obj.ApplicationMessage(msDebug, 'UploadOrderRate', Rate.ToString);
  end;
end;

procedure TdmDataLoader.UploadTicker(Ticker: TJSONObject);
var
  TickStamp: TDateTime;
  Params: TJSONValue;
  _Minute: Integer;
begin
  TickStamp := UnixToDateTime(Ticker.GetString('timestamp').ToInteger);
  TickStamp := RecodeSecond(TickStamp, 0);
  TickStamp := IncHour(TickStamp, 9);
  _Minute := MinuteOf(TickStamp);

  if (_Minute mod 5 = 0) then
  begin
    // UploadOrderRate(TickStamp);
    Params := CreateTickParams(TickStamp, Ticker);
    smDataLoaderClient.UploadTicker(Params);
  end;
end;

procedure TdmDataLoader.OnTicker;
var
  Ticker: TJSONObject;
begin
  Ticker := FCoinone.PublicInfo(rtTicker, 'currency=all');
  try
    if TGlobal.Obj.UseUploadTicker then
    begin
      UploadTicker(Ticker);
    end;

    if dmTrader.Count > 0 then
      ExecuteTrader(Ticker);
  finally
    Ticker.Free;
  end;
end;

function TdmDataLoader.GetsmDataLoaderClient: TsmDataLoaderClient;
begin
  if FsmDataLoaderClient = nil then
    FsmDataLoaderClient := TsmDataLoaderClient.Create(DSRestConnection, FInstanceOwner);

  result := FsmDataLoaderClient;
end;

end.
