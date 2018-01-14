//
// Created by the DataSnap proxy generator.
// 2018-01-13 ¿ÀÈÄ 12:00:43
//

unit ServerMethodsClient;

interface

uses System.JSON, Datasnap.DSProxyRest, Datasnap.DSClientRest, Data.DBXCommon, Data.DBXClient, Data.DBXDataSnap, Data.DBXJSON, Datasnap.DSProxy, System.Classes, System.SysUtils, Data.DB, Data.SqlExpr, Data.DBXDBReaders, Data.DBXCDSReaders, Data.DBXJSONReflect;

type
  TsmDataProviderClient = class(TDSAdminRestClient)
  private
    FDSServerModuleCreateCommand: TDSRestCommand;
    FDSServerModuleDestroyCommand: TDSRestCommand;
    FAccountInfoCommand: TDSRestCommand;
    FAccountInfoCommand_Cache: TDSRestCommand;
    FOrderCommand: TDSRestCommand;
    FOrderCommand_Cache: TDSRestCommand;
    FPublicInfoCommand: TDSRestCommand;
    FPublicInfoCommand_Cache: TDSRestCommand;
    FDayCommand: TDSRestCommand;
    FDayCommand_Cache: TDSRestCommand;
    FTickCommand: TDSRestCommand;
    FTickCommand_Cache: TDSRestCommand;
    FHighLowCommand: TDSRestCommand;
    FHighLowCommand_Cache: TDSRestCommand;
    FTotalValueCommand: TDSRestCommand;
  public
    constructor Create(ARestConnection: TDSRestConnection); overload;
    constructor Create(ARestConnection: TDSRestConnection; AInstanceOwner: Boolean); overload;
    destructor Destroy; override;
    procedure DSServerModuleCreate(Sender: TObject);
    procedure DSServerModuleDestroy(Sender: TObject);
    function AccountInfo(AType: Integer; const ARequestFilter: string = ''): TJSONObject;
    function AccountInfo_Cache(AType: Integer; const ARequestFilter: string = ''): IDSRestCachedJSONObject;
    function Order(AType: Integer; AParams: TJSONObject; const ARequestFilter: string = ''): TJSONObject;
    function Order_Cache(AType: Integer; AParams: TJSONObject; const ARequestFilter: string = ''): IDSRestCachedJSONObject;
    function PublicInfo(AType: Integer; AParam: string; const ARequestFilter: string = ''): TJSONObject;
    function PublicInfo_Cache(AType: Integer; AParam: string; const ARequestFilter: string = ''): IDSRestCachedJSONObject;
    function Day(AParams: TJSONObject; const ARequestFilter: string = ''): TStream;
    function Day_Cache(AParams: TJSONObject; const ARequestFilter: string = ''): IDSRestCachedStream;
    function Tick(AParams: TJSONObject; const ARequestFilter: string = ''): TStream;
    function Tick_Cache(AParams: TJSONObject; const ARequestFilter: string = ''): IDSRestCachedStream;
    function HighLow(ACoin: string; APeriod: TDateTime; const ARequestFilter: string = ''): TJSONObject;
    function HighLow_Cache(ACoin: string; APeriod: TDateTime; const ARequestFilter: string = ''): IDSRestCachedJSONObject;
    function TotalValue(ADateTime: TDateTime; const ARequestFilter: string = ''): Double;
  end;

  TsmDataLoaderClient = class(TDSAdminRestClient)
  private
    FUploadTickerCommand: TDSRestCommand;
    FUploadDayCommand: TDSRestCommand;
  public
    constructor Create(ARestConnection: TDSRestConnection); overload;
    constructor Create(ARestConnection: TDSRestConnection; AInstanceOwner: Boolean); overload;
    destructor Destroy; override;
    function UploadTicker(AParams: TJSONValue; const ARequestFilter: string = ''): Boolean;
    function UploadDay(AParams: TJSONValue; const ARequestFilter: string = ''): Boolean;
  end;

const
  TsmDataProvider_DSServerModuleCreate: array [0..0] of TDSRestParameterMetaData =
  (
    (Name: 'Sender'; Direction: 1; DBXType: 37; TypeName: 'TObject')
  );

  TsmDataProvider_DSServerModuleDestroy: array [0..0] of TDSRestParameterMetaData =
  (
    (Name: 'Sender'; Direction: 1; DBXType: 37; TypeName: 'TObject')
  );

  TsmDataProvider_AccountInfo: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'AType'; Direction: 1; DBXType: 6; TypeName: 'Integer'),
    (Name: ''; Direction: 4; DBXType: 37; TypeName: 'TJSONObject')
  );

  TsmDataProvider_AccountInfo_Cache: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'AType'; Direction: 1; DBXType: 6; TypeName: 'Integer'),
    (Name: ''; Direction: 4; DBXType: 26; TypeName: 'String')
  );

  TsmDataProvider_Order: array [0..2] of TDSRestParameterMetaData =
  (
    (Name: 'AType'; Direction: 1; DBXType: 6; TypeName: 'Integer'),
    (Name: 'AParams'; Direction: 1; DBXType: 37; TypeName: 'TJSONObject'),
    (Name: ''; Direction: 4; DBXType: 37; TypeName: 'TJSONObject')
  );

  TsmDataProvider_Order_Cache: array [0..2] of TDSRestParameterMetaData =
  (
    (Name: 'AType'; Direction: 1; DBXType: 6; TypeName: 'Integer'),
    (Name: 'AParams'; Direction: 1; DBXType: 37; TypeName: 'TJSONObject'),
    (Name: ''; Direction: 4; DBXType: 26; TypeName: 'String')
  );

  TsmDataProvider_PublicInfo: array [0..2] of TDSRestParameterMetaData =
  (
    (Name: 'AType'; Direction: 1; DBXType: 6; TypeName: 'Integer'),
    (Name: 'AParam'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: ''; Direction: 4; DBXType: 37; TypeName: 'TJSONObject')
  );

  TsmDataProvider_PublicInfo_Cache: array [0..2] of TDSRestParameterMetaData =
  (
    (Name: 'AType'; Direction: 1; DBXType: 6; TypeName: 'Integer'),
    (Name: 'AParam'; Direction: 1; DBXType: 26; TypeName: 'string'),
    (Name: ''; Direction: 4; DBXType: 26; TypeName: 'String')
  );

  TsmDataProvider_Day: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'AParams'; Direction: 1; DBXType: 37; TypeName: 'TJSONObject'),
    (Name: ''; Direction: 4; DBXType: 33; TypeName: 'TStream')
  );

  TsmDataProvider_Day_Cache: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'AParams'; Direction: 1; DBXType: 37; TypeName: 'TJSONObject'),
    (Name: ''; Direction: 4; DBXType: 26; TypeName: 'String')
  );

  TsmDataProvider_Tick: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'AParams'; Direction: 1; DBXType: 37; TypeName: 'TJSONObject'),
    (Name: ''; Direction: 4; DBXType: 33; TypeName: 'TStream')
  );

  TsmDataProvider_Tick_Cache: array [0..1] of TDSRestParameterMetaData =
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

  TsmDataProvider_TotalValue: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'ADateTime'; Direction: 1; DBXType: 11; TypeName: 'TDateTime'),
    (Name: ''; Direction: 4; DBXType: 7; TypeName: 'Double')
  );

  TsmDataLoader_UploadTicker: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'AParams'; Direction: 1; DBXType: 37; TypeName: 'TJSONValue'),
    (Name: ''; Direction: 4; DBXType: 4; TypeName: 'Boolean')
  );

  TsmDataLoader_UploadDay: array [0..1] of TDSRestParameterMetaData =
  (
    (Name: 'AParams'; Direction: 1; DBXType: 37; TypeName: 'TJSONValue'),
    (Name: ''; Direction: 4; DBXType: 4; TypeName: 'Boolean')
  );

implementation

procedure TsmDataProviderClient.DSServerModuleCreate(Sender: TObject);
begin
  if FDSServerModuleCreateCommand = nil then
  begin
    FDSServerModuleCreateCommand := FConnection.CreateCommand;
    FDSServerModuleCreateCommand.RequestType := 'POST';
    FDSServerModuleCreateCommand.Text := 'TsmDataProvider."DSServerModuleCreate"';
    FDSServerModuleCreateCommand.Prepare(TsmDataProvider_DSServerModuleCreate);
  end;
  if not Assigned(Sender) then
    FDSServerModuleCreateCommand.Parameters[0].Value.SetNull
  else
  begin
    FMarshal := TDSRestCommand(FDSServerModuleCreateCommand.Parameters[0].ConnectionHandler).GetJSONMarshaler;
    try
      FDSServerModuleCreateCommand.Parameters[0].Value.SetJSONValue(FMarshal.Marshal(Sender), True);
      if FInstanceOwner then
        Sender.Free
    finally
      FreeAndNil(FMarshal)
    end
    end;
  FDSServerModuleCreateCommand.Execute;
end;

procedure TsmDataProviderClient.DSServerModuleDestroy(Sender: TObject);
begin
  if FDSServerModuleDestroyCommand = nil then
  begin
    FDSServerModuleDestroyCommand := FConnection.CreateCommand;
    FDSServerModuleDestroyCommand.RequestType := 'POST';
    FDSServerModuleDestroyCommand.Text := 'TsmDataProvider."DSServerModuleDestroy"';
    FDSServerModuleDestroyCommand.Prepare(TsmDataProvider_DSServerModuleDestroy);
  end;
  if not Assigned(Sender) then
    FDSServerModuleDestroyCommand.Parameters[0].Value.SetNull
  else
  begin
    FMarshal := TDSRestCommand(FDSServerModuleDestroyCommand.Parameters[0].ConnectionHandler).GetJSONMarshaler;
    try
      FDSServerModuleDestroyCommand.Parameters[0].Value.SetJSONValue(FMarshal.Marshal(Sender), True);
      if FInstanceOwner then
        Sender.Free
    finally
      FreeAndNil(FMarshal)
    end
    end;
  FDSServerModuleDestroyCommand.Execute;
end;

function TsmDataProviderClient.AccountInfo(AType: Integer; const ARequestFilter: string): TJSONObject;
begin
  if FAccountInfoCommand = nil then
  begin
    FAccountInfoCommand := FConnection.CreateCommand;
    FAccountInfoCommand.RequestType := 'GET';
    FAccountInfoCommand.Text := 'TsmDataProvider.AccountInfo';
    FAccountInfoCommand.Prepare(TsmDataProvider_AccountInfo);
  end;
  FAccountInfoCommand.Parameters[0].Value.SetInt32(AType);
  FAccountInfoCommand.Execute(ARequestFilter);
  Result := TJSONObject(FAccountInfoCommand.Parameters[1].Value.GetJSONValue(FInstanceOwner));
end;

function TsmDataProviderClient.AccountInfo_Cache(AType: Integer; const ARequestFilter: string): IDSRestCachedJSONObject;
begin
  if FAccountInfoCommand_Cache = nil then
  begin
    FAccountInfoCommand_Cache := FConnection.CreateCommand;
    FAccountInfoCommand_Cache.RequestType := 'GET';
    FAccountInfoCommand_Cache.Text := 'TsmDataProvider.AccountInfo';
    FAccountInfoCommand_Cache.Prepare(TsmDataProvider_AccountInfo_Cache);
  end;
  FAccountInfoCommand_Cache.Parameters[0].Value.SetInt32(AType);
  FAccountInfoCommand_Cache.ExecuteCache(ARequestFilter);
  Result := TDSRestCachedJSONObject.Create(FAccountInfoCommand_Cache.Parameters[1].Value.GetString);
end;

function TsmDataProviderClient.Order(AType: Integer; AParams: TJSONObject; const ARequestFilter: string): TJSONObject;
begin
  if FOrderCommand = nil then
  begin
    FOrderCommand := FConnection.CreateCommand;
    FOrderCommand.RequestType := 'POST';
    FOrderCommand.Text := 'TsmDataProvider."Order"';
    FOrderCommand.Prepare(TsmDataProvider_Order);
  end;
  FOrderCommand.Parameters[0].Value.SetInt32(AType);
  FOrderCommand.Parameters[1].Value.SetJSONValue(AParams, FInstanceOwner);
  FOrderCommand.Execute(ARequestFilter);
  Result := TJSONObject(FOrderCommand.Parameters[2].Value.GetJSONValue(FInstanceOwner));
end;

function TsmDataProviderClient.Order_Cache(AType: Integer; AParams: TJSONObject; const ARequestFilter: string): IDSRestCachedJSONObject;
begin
  if FOrderCommand_Cache = nil then
  begin
    FOrderCommand_Cache := FConnection.CreateCommand;
    FOrderCommand_Cache.RequestType := 'POST';
    FOrderCommand_Cache.Text := 'TsmDataProvider."Order"';
    FOrderCommand_Cache.Prepare(TsmDataProvider_Order_Cache);
  end;
  FOrderCommand_Cache.Parameters[0].Value.SetInt32(AType);
  FOrderCommand_Cache.Parameters[1].Value.SetJSONValue(AParams, FInstanceOwner);
  FOrderCommand_Cache.ExecuteCache(ARequestFilter);
  Result := TDSRestCachedJSONObject.Create(FOrderCommand_Cache.Parameters[2].Value.GetString);
end;

function TsmDataProviderClient.PublicInfo(AType: Integer; AParam: string; const ARequestFilter: string): TJSONObject;
begin
  if FPublicInfoCommand = nil then
  begin
    FPublicInfoCommand := FConnection.CreateCommand;
    FPublicInfoCommand.RequestType := 'GET';
    FPublicInfoCommand.Text := 'TsmDataProvider.PublicInfo';
    FPublicInfoCommand.Prepare(TsmDataProvider_PublicInfo);
  end;
  FPublicInfoCommand.Parameters[0].Value.SetInt32(AType);
  FPublicInfoCommand.Parameters[1].Value.SetWideString(AParam);
  FPublicInfoCommand.Execute(ARequestFilter);
  Result := TJSONObject(FPublicInfoCommand.Parameters[2].Value.GetJSONValue(FInstanceOwner));
end;

function TsmDataProviderClient.PublicInfo_Cache(AType: Integer; AParam: string; const ARequestFilter: string): IDSRestCachedJSONObject;
begin
  if FPublicInfoCommand_Cache = nil then
  begin
    FPublicInfoCommand_Cache := FConnection.CreateCommand;
    FPublicInfoCommand_Cache.RequestType := 'GET';
    FPublicInfoCommand_Cache.Text := 'TsmDataProvider.PublicInfo';
    FPublicInfoCommand_Cache.Prepare(TsmDataProvider_PublicInfo_Cache);
  end;
  FPublicInfoCommand_Cache.Parameters[0].Value.SetInt32(AType);
  FPublicInfoCommand_Cache.Parameters[1].Value.SetWideString(AParam);
  FPublicInfoCommand_Cache.ExecuteCache(ARequestFilter);
  Result := TDSRestCachedJSONObject.Create(FPublicInfoCommand_Cache.Parameters[2].Value.GetString);
end;

function TsmDataProviderClient.Day(AParams: TJSONObject; const ARequestFilter: string): TStream;
begin
  if FDayCommand = nil then
  begin
    FDayCommand := FConnection.CreateCommand;
    FDayCommand.RequestType := 'POST';
    FDayCommand.Text := 'TsmDataProvider."Day"';
    FDayCommand.Prepare(TsmDataProvider_Day);
  end;
  FDayCommand.Parameters[0].Value.SetJSONValue(AParams, FInstanceOwner);
  FDayCommand.Execute(ARequestFilter);
  Result := FDayCommand.Parameters[1].Value.GetStream(FInstanceOwner);
end;

function TsmDataProviderClient.Day_Cache(AParams: TJSONObject; const ARequestFilter: string): IDSRestCachedStream;
begin
  if FDayCommand_Cache = nil then
  begin
    FDayCommand_Cache := FConnection.CreateCommand;
    FDayCommand_Cache.RequestType := 'POST';
    FDayCommand_Cache.Text := 'TsmDataProvider."Day"';
    FDayCommand_Cache.Prepare(TsmDataProvider_Day_Cache);
  end;
  FDayCommand_Cache.Parameters[0].Value.SetJSONValue(AParams, FInstanceOwner);
  FDayCommand_Cache.ExecuteCache(ARequestFilter);
  Result := TDSRestCachedStream.Create(FDayCommand_Cache.Parameters[1].Value.GetString);
end;

function TsmDataProviderClient.Tick(AParams: TJSONObject; const ARequestFilter: string): TStream;
begin
  if FTickCommand = nil then
  begin
    FTickCommand := FConnection.CreateCommand;
    FTickCommand.RequestType := 'POST';
    FTickCommand.Text := 'TsmDataProvider."Tick"';
    FTickCommand.Prepare(TsmDataProvider_Tick);
  end;
  FTickCommand.Parameters[0].Value.SetJSONValue(AParams, FInstanceOwner);
  FTickCommand.Execute(ARequestFilter);
  Result := FTickCommand.Parameters[1].Value.GetStream(FInstanceOwner);
end;

function TsmDataProviderClient.Tick_Cache(AParams: TJSONObject; const ARequestFilter: string): IDSRestCachedStream;
begin
  if FTickCommand_Cache = nil then
  begin
    FTickCommand_Cache := FConnection.CreateCommand;
    FTickCommand_Cache.RequestType := 'POST';
    FTickCommand_Cache.Text := 'TsmDataProvider."Tick"';
    FTickCommand_Cache.Prepare(TsmDataProvider_Tick_Cache);
  end;
  FTickCommand_Cache.Parameters[0].Value.SetJSONValue(AParams, FInstanceOwner);
  FTickCommand_Cache.ExecuteCache(ARequestFilter);
  Result := TDSRestCachedStream.Create(FTickCommand_Cache.Parameters[1].Value.GetString);
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

function TsmDataProviderClient.TotalValue(ADateTime: TDateTime; const ARequestFilter: string): Double;
begin
  if FTotalValueCommand = nil then
  begin
    FTotalValueCommand := FConnection.CreateCommand;
    FTotalValueCommand.RequestType := 'GET';
    FTotalValueCommand.Text := 'TsmDataProvider.TotalValue';
    FTotalValueCommand.Prepare(TsmDataProvider_TotalValue);
  end;
  FTotalValueCommand.Parameters[0].Value.AsDateTime := ADateTime;
  FTotalValueCommand.Execute(ARequestFilter);
  Result := FTotalValueCommand.Parameters[1].Value.GetDouble;
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
  FDSServerModuleCreateCommand.DisposeOf;
  FDSServerModuleDestroyCommand.DisposeOf;
  FAccountInfoCommand.DisposeOf;
  FAccountInfoCommand_Cache.DisposeOf;
  FOrderCommand.DisposeOf;
  FOrderCommand_Cache.DisposeOf;
  FPublicInfoCommand.DisposeOf;
  FPublicInfoCommand_Cache.DisposeOf;
  FDayCommand.DisposeOf;
  FDayCommand_Cache.DisposeOf;
  FTickCommand.DisposeOf;
  FTickCommand_Cache.DisposeOf;
  FHighLowCommand.DisposeOf;
  FHighLowCommand_Cache.DisposeOf;
  FTotalValueCommand.DisposeOf;
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

function TsmDataLoaderClient.UploadDay(AParams: TJSONValue; const ARequestFilter: string): Boolean;
begin
  if FUploadDayCommand = nil then
  begin
    FUploadDayCommand := FConnection.CreateCommand;
    FUploadDayCommand.RequestType := 'POST';
    FUploadDayCommand.Text := 'TsmDataLoader."UploadDay"';
    FUploadDayCommand.Prepare(TsmDataLoader_UploadDay);
  end;
  FUploadDayCommand.Parameters[0].Value.SetJSONValue(AParams, FInstanceOwner);
  FUploadDayCommand.Execute(ARequestFilter);
  Result := FUploadDayCommand.Parameters[1].Value.GetBoolean;
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
  FUploadDayCommand.DisposeOf;
  inherited;
end;

end.

