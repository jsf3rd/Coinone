unit _dmTrader;

interface

uses
  System.SysUtils, System.Classes, IPPeerClient, Datasnap.DSClientRest, ServerMethodsClient,
  System.JSON, REST.JSON;

type
  TdmTrader = class(TDataModule)
    DSRestConnection: TDSRestConnection;
  private
    FInstanceOwner: Boolean;
    FsmDataProviderClient: TsmDataProviderClient;
    FsmDataLoaderClient: TsmDataLoaderClient;
    function GetsmDataProviderClient: TsmDataProviderClient;
    function GetsmDataLoaderClient: TsmDataLoaderClient;
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure OnTick(AValue: TJSONObject);

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
end;

destructor TdmTrader.Destroy;
begin
  FsmDataProviderClient.Free;
  FsmDataLoaderClient.Free;
  inherited;
end;

function TdmTrader.GetsmDataProviderClient: TsmDataProviderClient;
begin
  if FsmDataProviderClient = nil then
    FsmDataProviderClient := TsmDataProviderClient.Create(DSRestConnection, FInstanceOwner);
  Result := FsmDataProviderClient;
end;

procedure TdmTrader.OnTick(AValue: TJSONObject);
begin



  AValue.Free;
end;

function TdmTrader.GetsmDataLoaderClient: TsmDataLoaderClient;
begin
  if FsmDataLoaderClient = nil then
    FsmDataLoaderClient := TsmDataLoaderClient.Create(DSRestConnection, FInstanceOwner);
  Result := FsmDataLoaderClient;
end;

end.
