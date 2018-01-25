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

    procedure OnNewOrder(AParams: TJSONObject);
    procedure OnCancelOrder(AID: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init;
    procedure Execute(ATicker, ABalance: TJSONObject);

    function Count: Integer;
    function GetHighLow(ACoin: string; AHour: Integer): THighLow;

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

function TdmTrader.Count: Integer;
begin
  result := FCoinTrader.Count;
end;

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
  result := FsmDataProviderClient;
end;

procedure TdmTrader.Init;
var
  Currency: TStrings;
  MyCurrency: string;
  MyTrader: TTrader;

begin
  DSRestConnection.Host := TGlobal.Obj.ConnInfo.StringValue;
  DSRestConnection.Port := TGlobal.Obj.ConnInfo.IntegerValue;

  Currency := TStringList.Create;
  try
    Currency.CommaText := TGlobal.Obj.TraderOption.Currency;
    for MyCurrency in Currency do
    begin
      MyTrader := TTrader.Create(MyCurrency);
      MyTrader.OnNewOrder := OnNewOrder;
      MyTrader.OnCancelOrder := OnCancelOrder;
      FCoinTrader.Add(MyCurrency, MyTrader);
    end;
  finally
    Currency.Free;
  end;
end;

procedure TdmTrader.OnCancelOrder(AID: string);
begin
  try
    smDataLoaderClient.DeleteOrder(AID)
  except
    on E: Exception do
      TGlobal.Obj.ApplicationMessage(msError, 'OnCancelOrder', E.Message);
  end;
end;

procedure TdmTrader.OnNewOrder(AParams: TJSONObject);
begin
  try
    smDataLoaderClient.UploadOrder(AParams.Clone as TJSONValue)
  except
    on E: Exception do
      TGlobal.Obj.ApplicationMessage(msError, 'UploadOrder', E.Message);
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
    result := TJson.JsonToRecord<THighLow>(JSONObject);
  except
    on E: Exception do
      raise Exception.Create('GetHighLow,' + E.Message);
  end;
end;

procedure TdmTrader.Execute(ATicker, ABalance: TJSONObject);
var
  MyTrader: TTrader;
  Last: Integer;
  Avail: double;
begin
  for MyTrader in FCoinTrader.Values do
  begin
    try
      Last := ATicker.GetJSONObject(MyTrader.Currency).GetString('last').ToInteger;
      Avail := ABalance.GetJSONObject(MyTrader.Currency).GetString('avail').ToDouble;

      MyTrader.Execute(Last, Avail);
    except
      on E: Exception do
        TGlobal.Obj.ApplicationMessage(msError, 'Execute', E.Message);
    end;
  end;
end;

function TdmTrader.GetsmDataLoaderClient: TsmDataLoaderClient;
begin
  if FsmDataLoaderClient = nil then
    FsmDataLoaderClient := TsmDataLoaderClient.Create(DSRestConnection, FInstanceOwner);
  result := FsmDataLoaderClient;
end;

end.
