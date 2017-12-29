//
// Created by the DataSnap proxy generator.
// 2017-12-28 ¿ÀÈÄ 8:12:15
//

unit ServerMethodsClient;

interface

uses System.JSON, Data.DBXCommon, Data.DBXClient, Data.DBXDataSnap, Data.DBXJSON,
  Datasnap.DSProxy, System.Classes, System.SysUtils, Data.DB, Data.SqlExpr, Data.DBXDBReaders,
  Data.DBXCDSReaders, Data.DBXJSONReflect;

type
  TsmDataProviderClient = class(TDSAdminClient)
  private
    FEchoStringCommand: TDBXCommand;
    FReverseStringCommand: TDBXCommand;
  public
    constructor Create(ADBXConnection: TDBXConnection); overload;
    constructor Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean); overload;
    destructor Destroy; override;
    function EchoString(Value: string): string;
    function ReverseString(Value: string): string;
  end;

  TsmDataLoaderClient = class(TDSAdminClient)
  private
    FUploadTickerCommand: TDBXCommand;
  public
    constructor Create(ADBXConnection: TDBXConnection); overload;
    constructor Create(ADBXConnection: TDBXConnection; AInstanceOwner: Boolean); overload;
    destructor Destroy; override;
    function UploadTicker(AParams: TJSONObject): Boolean;
  end;

implementation

function TsmDataProviderClient.EchoString(Value: string): string;
begin
  if FEchoStringCommand = nil then
  begin
    FEchoStringCommand := FDBXConnection.CreateCommand;
    FEchoStringCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FEchoStringCommand.Text := 'TsmDataProvider.EchoString';
    FEchoStringCommand.Prepare;
  end;
  FEchoStringCommand.Parameters[0].Value.SetWideString(Value);
  FEchoStringCommand.ExecuteUpdate;
  Result := FEchoStringCommand.Parameters[1].Value.GetWideString;
end;

function TsmDataProviderClient.ReverseString(Value: string): string;
begin
  if FReverseStringCommand = nil then
  begin
    FReverseStringCommand := FDBXConnection.CreateCommand;
    FReverseStringCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FReverseStringCommand.Text := 'TsmDataProvider.ReverseString';
    FReverseStringCommand.Prepare;
  end;
  FReverseStringCommand.Parameters[0].Value.SetWideString(Value);
  FReverseStringCommand.ExecuteUpdate;
  Result := FReverseStringCommand.Parameters[1].Value.GetWideString;
end;

constructor TsmDataProviderClient.Create(ADBXConnection: TDBXConnection);
begin
  inherited Create(ADBXConnection);
end;

constructor TsmDataProviderClient.Create(ADBXConnection: TDBXConnection;
  AInstanceOwner: Boolean);
begin
  inherited Create(ADBXConnection, AInstanceOwner);
end;

destructor TsmDataProviderClient.Destroy;
begin
  FEchoStringCommand.DisposeOf;
  FReverseStringCommand.DisposeOf;
  inherited;
end;

function TsmDataLoaderClient.UploadTicker(AParams: TJSONObject): Boolean;
begin
  if FUploadTickerCommand = nil then
  begin
    FUploadTickerCommand := FDBXConnection.CreateCommand;
    FUploadTickerCommand.CommandType := TDBXCommandTypes.DSServerMethod;
    FUploadTickerCommand.Text := 'TsmDataLoader.UploadTicker';
    FUploadTickerCommand.Prepare;
  end;
  FUploadTickerCommand.Parameters[0].Value.SetJSONValue(AParams, FInstanceOwner);
  FUploadTickerCommand.ExecuteUpdate;
  Result := FUploadTickerCommand.Parameters[1].Value.GetBoolean;
end;

constructor TsmDataLoaderClient.Create(ADBXConnection: TDBXConnection);
begin
  inherited Create(ADBXConnection);
end;

constructor TsmDataLoaderClient.Create(ADBXConnection: TDBXConnection;
  AInstanceOwner: Boolean);
begin
  inherited Create(ADBXConnection, AInstanceOwner);
end;

destructor TsmDataLoaderClient.Destroy;
begin
  FUploadTickerCommand.DisposeOf;
  inherited;
end;

end.
