unit _dmTrader;

interface

uses
  System.SysUtils, System.Classes, IPPeerClient, Datasnap.DSClientRest, ServerMethodsClient,
  System.JSON, REST.JSON, CoinOne, CoinState, System.Generics.Collections,
  JdcGlobal.ClassHelper, Common, JdcGlobal, cbGlobal, cbOption, System.DateUtils;

type
  TdmTrader = class(TDataModule)
    DSRestConnection: TDSRestConnection;
  private
    FInstanceOwner: Boolean;
    FsmDataProviderClient: TsmDataProviderClient;
    FsmDataLoaderClient: TsmDataLoaderClient;

    FCoinTrader: TDictionary<String, TTrader>;

    function GetsmDataProviderClient: TsmDataProviderClient;
    function GetsmDataLoaderClient: TsmDataLoaderClient;
    function GetHighLow(ACoin: string; AHour: Integer): THighLow;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init;
    procedure OnTick(ATicker, ABalance: TJSONObject);

    property InstanceOwner: Boolean read FInstanceOwner write FInstanceOwner;
    property smDataProviderClient: TsmDataProviderClient read GetsmDataProviderClient
      write FsmDataProviderClient;
    property smDataLoaderClient: TsmDataLoaderClient read GetsmDataLoaderClient
      write FsmDataLoaderClient;

  end;

var
  dmTrader: TdmTrader;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

constructor TdmTrader.Create(AOwner: TComponent);
begin
  inherited;
  FInstanceOwner := True;
  FCoinTrader := TDictionary<String, TTrader>.Create;
end;

destructor TdmTrader.Destroy;
var
  MyTrader: TPair<String, TTrader>;
begin
  FsmDataProviderClient.Free;
  FsmDataLoaderClient.Free;

  for MyTrader in FCoinTrader do
  begin
    MyTrader.Value.Free;
  end;
  FCoinTrader.Free;

  inherited;
end;

function TdmTrader.GetsmDataProviderClient: TsmDataProviderClient;
begin
  if FsmDataProviderClient = nil then
    FsmDataProviderClient := TsmDataProviderClient.Create(DSRestConnection, FInstanceOwner);
  Result := FsmDataProviderClient;
end;

procedure TdmTrader.Init;
var
  Option: TTraderOption;
  MyCoin: TCoinInfo;
begin
  DSRestConnection.Host := TGlobal.Obj.ConnInfo.StringValue;
  DSRestConnection.Port := TGlobal.Obj.ConnInfo.IntegerValue;

  Option := TJson.JsonToRecord<TTraderOption>(TOption.Obj.TraderOption);

  for MyCoin in Option.Coins do
  begin
    if (MyCoin.Oper <> OPER_ENABLE) and (MyCoin.Oper <> OPER_TEST) then
    begin
      TGlobal.Obj.ApplicationMessage(msDebug, 'Disabled', MyCoin.ToString);
      Continue;
    end;

    FCoinTrader.Add(MyCoin.Currency, TTrader.Create(MyCoin));
  end;
end;

function TdmTrader.GetHighLow(ACoin: string; AHour: Integer): THighLow;
var
  JSONObject: TJSONObject;
  DateTime: TDateTime;
begin
  try
    DateTime := IncHour(Now, -AHour);
    JSONObject := smDataProviderClient.HighLow(UpperCase(ACoin), DateTime);
    Result := TJson.JsonToRecord<THighLow>(JSONObject);
  except
    on E: Exception do
      raise Exception.Create('GetHighLow,' + E.Message);
  end;
end;

procedure TdmTrader.OnTick(ATicker, ABalance: TJSONObject);
var
  MyTrader: TPair<String, TTrader>;
  Last: Integer;
  HighLow: THighLow;
  Avail: double;
begin
  try
    for MyTrader in FCoinTrader do
    begin
      try
        HighLow := GetHighLow(MyTrader.Key, MyTrader.Value.CoinInfo.StochHour);
      except
        on E: Exception do
        begin
          TGlobal.Obj.ApplicationMessage(msError, 'GetHighLow', 'Coin=%s,E=%s',
            [MyTrader.Key, E.Message]);
          Continue;
        end;
      end;

      try
        Last := ATicker.GetJSONObject(MyTrader.Key).GetString('last').ToInteger;
      except
        on E: Exception do
        begin
          TGlobal.Obj.ApplicationMessage(msError, 'LastPrice', 'Coin=%s,E=%s',
            [MyTrader.Key, E.Message]);
          Continue;
        end;
      end;

      try
        Avail := ABalance.GetJSONObject(MyTrader.Key).GetString('avail').ToDouble;
      except
        on E: Exception do
        begin
          TGlobal.Obj.ApplicationMessage(msError, 'BalanceAvail', 'Coin=%s,E=%s',
            [MyTrader.Key, E.Message]);
          Continue;
        end;
      end;

      try
        MyTrader.Value.Tick(Last, HighLow, Avail);
      except
        on E: Exception do
        begin
          TGlobal.Obj.ApplicationMessage(msError, 'TraderTick', 'Coin=%s,E=%s',
            [MyTrader.Key, E.Message]);
          Continue;
        end;
      end;
    end;
  except
    on E: Exception do
      raise Exception.Create('TdmTrader.OnTick - ' + E.Message);
  end;
end;

function TdmTrader.GetsmDataLoaderClient: TsmDataLoaderClient;
begin
  if FsmDataLoaderClient = nil then
    FsmDataLoaderClient := TsmDataLoaderClient.Create(DSRestConnection, FInstanceOwner);
  Result := FsmDataLoaderClient;
end;

end.
