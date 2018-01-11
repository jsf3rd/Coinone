unit _dmDataLoader;

interface

uses
  System.SysUtils, System.Classes, Data.DBXDataSnap, IPPeerClient,
  Data.DBXCommon, Data.DbxHTTPLayer, Data.DB, Data.SqlExpr, ServerMethodsClient, Coinone,
  System.JSON, REST.JSON, System.DateUtils, System.Generics.Collections, JdcGlobal.ClassHelper,
  cbGlobal, JdcGlobal, Common, Datasnap.DSClientRest, _dmTrader, System.Threading;

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
    procedure DataModuleCreate(Sender: TObject);
  private
    FInstanceOwner: Boolean;
    FsmDataProviderClient: TsmDataProviderClient;
    FsmDataLoaderClient: TsmDataLoaderClient;

    FCoinone: TCoinone;
    FDay, FMinute: Byte;

    function GetsmDataProviderClient: TsmDataProviderClient;
    function GetsmDataLoaderClient: TsmDataLoaderClient;

    function CreateTickParams(ATime: TDateTime; ATicks: TJSONObject): TJSONValue;
    function CreateDayParams(ATicks: TJSONObject): TJSONValue;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property InstanceOwner: Boolean read FInstanceOwner write FInstanceOwner;
    property smDataProviderClient: TsmDataProviderClient read GetsmDataProviderClient
      write FsmDataProviderClient;
    property smDataLoaderClient: TsmDataLoaderClient read GetsmDataLoaderClient
      write FsmDataLoaderClient;

    procedure Tick;
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
  FDay := 0;
  FMinute := 0;
end;

function TdmDataLoader.CreateDayParams(ATicks: TJSONObject): TJSONValue;
var
  _Tick, JSONObject, _Balance: TJSONObject;
  TickStamp: TDateTime;
  Day: TDay;
  I: Integer;
  DailyBalance, JSONArray: TJSONArray;
begin
  JSONArray := TJSONArray.Create;

  TickStamp := UnixToDateTime(ATicks.GetString('timestamp').ToInteger);
  TickStamp := IncHour(TickStamp, 9);
  TickStamp := IncDay(TickStamp, -1);
  TickStamp := RecodeTime(TickStamp, 0, 0, 0, 0);

  JSONObject := FCoinone.AccountInfo(rtDailyBalance);
  DailyBalance := JSONObject.GetValue('dailyBalance') as TJSONArray;
  _Balance := DailyBalance.Items[0] as TJSONObject;

  for I := Low(Coins) to High(Coins) do
  begin
    if Coins[I] = 'krw' then
    begin
      Day.volume := 0;
      Day.first_price := 1;
      Day.last_price := 1;
      Day.high_price := 1;
      Day.low_price := 1;
    end
    else
    begin
      _Tick := ATicks.GetValue(Coins[I]) as TJSONObject;
      Day.volume := _Tick.GetString('yesterday_volume').ToDouble;
      Day.first_price := _Tick.GetString('yesterday_first').ToDouble;
      Day.last_price := _Tick.GetString('yesterday_last').ToDouble;
      Day.high_price := _Tick.GetString('yesterday_high').ToDouble;
      Day.low_price := _Tick.GetString('yesterday_low').ToDouble;
    end;

    Day.day_stamp := TickStamp;
    Day.coin_code := UpperCase(Coins[I]);
    Day.amount := _Balance.GetString(Coins[I]).ToDouble;

    JSONArray.Add(TJson.RecordToJsonObject(Day));
  end;

  JSONObject.Free;

  result := JSONArray;
end;

function TdmDataLoader.CreateTickParams(ATime: TDateTime; ATicks: TJSONObject): TJSONValue;
var
  _Tick: TJSONObject;
  Ticker: TTicker;
  I: Integer;
  JSONArray: TJSONArray;
begin
  JSONArray := TJSONArray.Create;

  for I := Low(Coins) to High(Coins) do
  begin
    if Coins[I] = 'krw' then
      Continue;

    _Tick := ATicks.GetValue(Coins[I]) as TJSONObject;
    Ticker.volume := _Tick.GetString('volume').ToDouble;
    Ticker.yesterday_volume := _Tick.GetString('yesterday_volume').ToDouble;
    Ticker.price := _Tick.GetString('last').ToDouble;
    Ticker.yesterday_last := _Tick.GetString('yesterday_last').ToDouble;
    Ticker.tick_stamp := ATime;
    Ticker.coin_code := UpperCase(Coins[I]);
    JSONArray.Add(TJson.RecordToJsonObject(Ticker));
  end;

  result := JSONArray;
end;

procedure TdmDataLoader.DataModuleCreate(Sender: TObject);
begin
  FCoinone := TCoinone.Create(ACCESS_TOKEN, SECRET_KEY);
end;

destructor TdmDataLoader.Destroy;
begin
  FCoinone.Free;
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

procedure TdmDataLoader.Tick;
var
  JSONObject: TJSONObject;
  Params: TJSONValue;
  _Day, _Minute: Integer;
  TickStamp: TDateTime;
begin
  JSONObject := FCoinone.PublicInfo(rtTicker, 'currency=all');
  try
    TickStamp := UnixToDateTime(JSONObject.GetString('timestamp').ToInteger);
    TickStamp := RecodeSecond(TickStamp, 0);
    TickStamp := IncHour(TickStamp, 9);

    Params := CreateTickParams(TickStamp, JSONObject);

    _Minute := MinuteOf(TickStamp);
    if (_Minute <> FMinute) and (_Minute mod 5 = 0) then
    begin
      // 5분마다 저장
      if smDataLoaderClient.UploadTicker(Params) then
        FMinute := _Minute;
    end;

    _Day := DayOf(TickStamp);
    if FDay <> _Day then
    begin
      FDay := _Day;
      Params := CreateDayParams(JSONObject);
      smDataLoaderClient.UploadDay(Params);
    end;

    TTask.Run(
      procedure
      begin
        try
          dmTrader.OnTick(JSONObject.Clone as TJSONObject);
        except
          on E: Exception do
            TGlobal.Obj.ApplicationMessage(msError, 'dmTrader.OnTick', E.Message);
        end;
      end);

  finally
    JSONObject.Free;
  end;
end;

function TdmDataLoader.GetsmDataLoaderClient: TsmDataLoaderClient;
begin
  if FsmDataLoaderClient = nil then
    FsmDataLoaderClient := TsmDataLoaderClient.Create(DSRestConnection, FInstanceOwner);

  result := FsmDataLoaderClient;
end;

end.
