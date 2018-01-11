unit _dmTrader;

interface

uses
  System.SysUtils, System.Classes, IPPeerClient, Datasnap.DSClientRest, ServerMethodsClient,
  System.JSON, REST.JSON, CoinOne, CoinState, System.Generics.Collections,
  JdcGlobal.ClassHelper, Common, JdcGlobal, cbGlobal;

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
    function GetHighLow(ACoin: string): THigLow;
    { Private declarations }
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
  I: Integer;
begin
  Option := TJson.JsonToRecord<TTraderOption>(smDataProviderClient.GetTraderOption);

  for I := Low(Option.Coins) to High(Option.Coins) do
  begin
    FCoinTrader.Add(Coins[I], TTrader.Create(Coins[I], Option.TradePoint));
    TGlobal.Obj.ApplicationMessage(msDebug, 'CreateTrader', Coins[I]);
  end;
end;

function TdmTrader.GetHighLow(ACoin: string): THigLow;
var
  JSONObject: TJSONObject;
begin
  JSONObject := smDataProviderClient.HighLow(UpperCase(ACoin));
  Result := TJson.JsonToRecord<THigLow>(JSONObject);
  JSONObject.Free;
end;

procedure TdmTrader.OnTick(ATicker, ABalance: TJSONObject);
var
  MyTrader: TPair<String, TTrader>;
  Last: Integer;
  HighLow: THigLow;
  Balance: TJSONObject;
  Avail: double;
begin

  for MyTrader in FCoinTrader do
  begin
    HighLow := GetHighLow(MyTrader.Key);
    Last := ATicker.GetJSONObject(MyTrader.Key).GetString('last').ToInteger;
    Avail := ABalance.GetJSONObject(MyTrader.Key).GetString('avail').ToDouble;
    try
      MyTrader.Value.Tick(Last, HighLow, Avail);
    except
      on E: Exception do
        TGlobal.Obj.ApplicationMessage(msError, 'TraderTick', 'Coin=%s,E=%s',
          [MyTrader.Key, E.Message]);
    end;
  end;

  ATicker.Free;
end;

function TdmTrader.GetsmDataLoaderClient: TsmDataLoaderClient;
begin
  if FsmDataLoaderClient = nil then
    FsmDataLoaderClient := TsmDataLoaderClient.Create(DSRestConnection, FInstanceOwner);
  Result := FsmDataLoaderClient;
end;

end.
