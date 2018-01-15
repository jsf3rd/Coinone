//
// Created by the DataSnap proxy generator.
// 2018-01-15 ¿ÀÈÄ 11:40:00
//

unit ClientClassesUnit;

interface

uses System.JSON, Datasnap.DSProxyRest, Datasnap.DSClientRest, Data.DBXCommon, Data.DBXClient, Data.DBXDataSnap, Data.DBXJSON, Datasnap.DSProxy, System.Classes, System.SysUtils, Data.DB, Data.SqlExpr, Data.DBXDBReaders, Data.DBXCDSReaders, Data.DBXJSONReflect;

type
  TsmDataProviderClient = class(TDSAdminRestClient)
  private
    FTickerCommand: TDSRestCommand;
    FTickerCommand_Cache: TDSRestCommand;
    FOrdersCommand: TDSRestCommand;
    FOrdersCommand_Cache: TDSRestCommand;
    FHighLowCommand: TDSRestCommand;
    FHighLowCommand_Cache: TDSRestCommand;
  public
    constructor Create(ARestConnection: TDSRestConnection); overload;
    constructor Create(ARestConnection: TDSRestConnection; AInstanceOwner: Boolean); overload;
    destructor Destroy; override;
    function Ticker(AParams: TJSONObject; const ARequestFilter: string = ''): TStream;
    function Ticker_Cache(AParams: TJSONObject; const ARequestFilter: string = ''): IDSRestCachedStream;
    function Orders(AParams: TJSONObject; const ARequestFilter: string = ''): TStream;
    function Orders_Cache(AParams: TJSONObject; const ARequestFilter: string = ''): IDSRestCachedStream;
    function HighLow(ACoin: string; APeriod: TDateTime; const ARequestFilter: string = ''): TJSONObject;
    function HighLow_Cache(ACoin: string; APeriod: TDateTime; const ARequestFilter: string = ''): IDSRestCachedJSONObject;
  end;

  TsmDataLoaderClient = class(TDSAdminRestClient)
  private
    FUploadTickerCommand: TDSRestCommand;
    FUploadOrderCommand: TDSRestCommand;
    FDeleteOrderCommand: TDSRestCommand;
  public
    constructor Create(ARestConnection: TDSRestConnection); overload;
    constructor Create(ARestConnection: TDSRestConnection; AInstanceOwner: Boolean); overload;
    destructor Destroy; override;
    function UploadTicker(AParams: TJSONValue; const ARequestFilter: string = ''): Boolean;
    function UploadOrder(AParams: TJSONValue; const ARequestFilter: string = ''): Boolean;
    function DeleteOrder(AID: string; const ARequestFilter: string = ''): Boolean;
  end;

const
  TsmDataProvider_Ticker: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'AParams'; Direction: 1; DBXType: 37; TypeName: 'TJSONObject'),
    (Name: ''; Direction: 4; DBXType: 33; TypeName: 'TStream')
  );

  TsmDataProvider_Ticker_Cache: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'AParams'; Direction: 1; DBXType: 37; TypeName: 'TJSONObject'),
    (Name: ''; Direction: 4; DBXType: 26; TypeName: 'String')
  );

  TsmDataProvider_Orders: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'AParams'; Direction: 1; DBXType: 37; TypeName: 'TJSONObject'),
    (Name: ''; Direction: 4; DBXType: 33; TypeName: 'TStream')
  );

  TsmDataProvider_Orders_Cache: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'AParams'; Direction: 1; DBXType: 37; TypeName: 'TJSONObject'),
    (Name: ''; Direction: 4; DBXType: 26; TypeName: 'String')
  );

  TsmDataProvider_HighLow: array [0..2] of TDSRestParameterMetaData =
  (
    (Name: 'ACoin'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'APeriod'; Direction: 1; DBXType: 11; TypeName: 'TDateTime'),
    (Name: ''; Direction: 4; DBXType: 37; TypeName: 'TJSONObject')
  );

  TsmDataProvider_HighLow_Cache: array [0..2] of TDSRestParameterMetaData =
  (
    (Name: 'ACoin'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: 'APeriod'; Direction: 1; DBXType: 11; TypeName: 'TDateTime'),
    (Name: ''; Direction: 4; DBXType: 26; TypeName: 'String')
  );

  TsmDataLoader_UploadTicker: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'AParams'; Direction: 1; DBXType: 37; TypeName: 'TJSONValue'),
    (Name: ''; Direction: 4; DBXType: 4; TypeName: 'Boolean')
  );

  TsmDataLoader_UploadOrder: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'AParams'; Direction: 1; DBXType: 37; TypeName: 'TJSONValue'),
    (Name: ''; Direction: 4; DBXType: 4; TypeName: 'Boolean')
  );

  TsmDataLoader_DeleteOrder: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'AID'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: ''; Direction: 4; DBXType: 4; TypeName: 'Boolean')
  );

implementation

function TsmDataProviderClient.Ticker(AParams: TJSONObject; const ARequestFilter: string): TStream;
begin
  if FTickerCommand = nil then
  begin
    FTickerCommand := FConnection.CreateCommand;
    FTickerCommand.RequestType := 'POST';
    FTickerCommand.Text := 'TsmDataProvider."Ticker"';
    FTickerCommand.Prepare(TsmDataProvider_Ticker);
  end;
  FTickerCommand.Parameters[0].Value.SetJSONValue(AParams, FInstanceOwner);
  FTickerCommand.Execute(ARequestFilter);
  Result := FTickerCommand.Parameters[1].Value.GetStream(FInstanceOwner);
end;

function TsmDataProviderClient.Ticker_Cache(AParams: TJSONObject; const ARequestFilter: string): IDSRestCachedStream;
begin
  if FTickerCommand_Cache = nil then
  begin
    FTickerCommand_Cache := FConnection.CreateCommand;
    FTickerCommand_Cache.RequestType := 'POST';
    FTickerCommand_Cache.Text := 'TsmDataProvider."Ticker"';
    FTickerCommand_Cache.Prepare(TsmDataProvider_Ticker_Cache);
  end;
  FTickerCommand_Cache.Parameters[0].Value.SetJSONValue(AParams, FInstanceOwner);
  FTickerCommand_Cache.ExecuteCache(ARequestFilter);
  Result := TDSRestCachedStream.Create(FTickerCommand_Cache.Parameters[1].Value.GetString);
end;

function TsmDataProviderClient.Orders(AParams: TJSONObject; const ARequestFilter: string): TStream;
begin
  if FOrdersCommand = nil then
  begin
    FOrdersCommand := FConnection.CreateCommand;
    FOrdersCommand.RequestType := 'POST';
    FOrdersCommand.Text := 'TsmDataProvider."Orders"';
    FOrdersCommand.Prepare(TsmDataProvider_Orders);
  end;
  FOrdersCommand.Parameters[0].Value.SetJSONValue(AParams, FInstanceOwner);
  FOrdersCommand.Execute(ARequestFilter);
  Result := FOrdersCommand.Parameters[1].Value.GetStream(FInstanceOwner);
end;

function TsmDataProviderClient.Orders_Cache(AParams: TJSONObject; const ARequestFilter: string): IDSRestCachedStream;
begin
  if FOrdersCommand_Cache = nil then
  begin
    FOrdersCommand_Cache := FConnection.CreateCommand;
    FOrdersCommand_Cache.RequestType := 'POST';
    FOrdersCommand_Cache.Text := 'TsmDataProvider."Orders"';
    FOrdersCommand_Cache.Prepare(TsmDataProvider_Orders_Cache);
  end;
  FOrdersCommand_Cache.Parameters[0].Value.SetJSONValue(AParams, FInstanceOwner);
  FOrdersCommand_Cache.ExecuteCache(ARequestFilter);
  Result := TDSRestCachedStream.Create(FOrdersCommand_Cache.Parameters[1].Value.GetString);
end;

function TsmDataProviderClient.HighLow(ACoin: string; APeriod: TDateTime; const ARequestFilter: string): TJSONObject;
begin
  if FHighLowCommand = nil then
  begin
    FHighLowCommand := FConnection.CreateCommand;
    FHighLowCommand.RequestType := 'GET';
    FHighLowCommand.Text := 'TsmDataProvider.HighLow';
    FHighLowCommand.Prepare(TsmDataProvider_HighLow);
  end;
  FHighLowCommand.Parameters[0].Value.SetWideString(ACoin);
  FHighLowCommand.Parameters[1].Value.AsDateTime := APeriod;
  FHighLowCommand.Execute(ARequestFilter);
  Result := TJSONObject(FHighLowCommand.Parameters[2].Value.GetJSONValue(FInstanceOwner));
end;

function TsmDataProviderClient.HighLow_Cache(ACoin: string; APeriod: TDateTime; const ARequestFilter: string): IDSRestCachedJSONObject;
begin
  if FHighLowCommand_Cache = nil then
  begin
    FHighLowCommand_Cache := FConnection.CreateCommand;
    FHighLowCommand_Cache.RequestType := 'GET';
    FHighLowCommand_Cache.Text := 'TsmDataProvider.HighLow';
    FHighLowCommand_Cache.Prepare(TsmDataProvider_HighLow_Cache);
  end;
  FHighLowCommand_Cache.Parameters[0].Value.SetWideString(ACoin);
  FHighLowCommand_Cache.Parameters[1].Value.AsDateTime := APeriod;
  FHighLowCommand_Cache.ExecuteCache(ARequestFilter);
  Result := TDSRestCachedJSONObject.Create(FHighLowCommand_Cache.Parameters[2].Value.GetString);
end;

constructor TsmDataProviderClient.Create(ARestConnection: TDSRestConnection);
begin
  inherited Create(ARestConnection);
end;

constructor TsmDataProviderClient.Create(ARestConnection: TDSRestConnection; AInstanceOwner: Boolean);
begin
  inherited Create(ARestConnection, AInstanceOwner);
end;

destructor TsmDataProviderClient.Destroy;
begin
  FTickerCommand.DisposeOf;
  FTickerCommand_Cache.DisposeOf;
  FOrdersCommand.DisposeOf;
  FOrdersCommand_Cache.DisposeOf;
  FHighLowCommand.DisposeOf;
  FHighLowCommand_Cache.DisposeOf;
  inherited;
end;

function TsmDataLoaderClient.UploadTicker(AParams: TJSONValue; const ARequestFilter: string): Boolean;
begin
  if FUploadTickerCommand = nil then
  begin
    FUploadTickerCommand := FConnection.CreateCommand;
    FUploadTickerCommand.RequestType := 'POST';
    FUploadTickerCommand.Text := 'TsmDataLoader."UploadTicker"';
    FUploadTickerCommand.Prepare(TsmDataLoader_UploadTicker);
  end;
  FUploadTickerCommand.Parameters[0].Value.SetJSONValue(AParams, FInstanceOwner);
  FUploadTickerCommand.Execute(ARequestFilter);
  Result := FUploadTickerCommand.Parameters[1].Value.GetBoolean;
end;

function TsmDataLoaderClient.UploadOrder(AParams: TJSONValue; const ARequestFilter: string): Boolean;
begin
  if FUploadOrderCommand = nil then
  begin
    FUploadOrderCommand := FConnection.CreateCommand;
    FUploadOrderCommand.RequestType := 'POST';
    FUploadOrderCommand.Text := 'TsmDataLoader."UploadOrder"';
    FUploadOrderCommand.Prepare(TsmDataLoader_UploadOrder);
  end;
  FUploadOrderCommand.Parameters[0].Value.SetJSONValue(AParams, FInstanceOwner);
  FUploadOrderCommand.Execute(ARequestFilter);
  Result := FUploadOrderCommand.Parameters[1].Value.GetBoolean;
end;

function TsmDataLoaderClient.DeleteOrder(AID: string; const ARequestFilter: string): Boolean;
begin
  if FDeleteOrderCommand = nil then
  begin
    FDeleteOrderCommand := FConnection.CreateCommand;
    FDeleteOrderCommand.RequestType := 'GET';
    FDeleteOrderCommand.Text := 'TsmDataLoader.DeleteOrder';
    FDeleteOrderCommand.Prepare(TsmDataLoader_DeleteOrder);
  end;
  FDeleteOrderCommand.Parameters[0].Value.SetWideString(AID);
  FDeleteOrderCommand.Execute(ARequestFilter);
  Result := FDeleteOrderCommand.Parameters[1].Value.GetBoolean;
end;

constructor TsmDataLoaderClient.Create(ARestConnection: TDSRestConnection);
begin
  inherited Create(ARestConnection);
end;

constructor TsmDataLoaderClient.Create(ARestConnection: TDSRestConnection; AInstanceOwner: Boolean);
begin
  inherited Create(ARestConnection, AInstanceOwner);
end;

destructor TsmDataLoaderClient.Destroy;
begin
  FUploadTickerCommand.DisposeOf;
  FUploadOrderCommand.DisposeOf;
  FDeleteOrderCommand.DisposeOf;
  inherited;
end;

end.

