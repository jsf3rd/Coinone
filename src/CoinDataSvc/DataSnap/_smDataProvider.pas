unit _smDataProvider;

interface

uses System.SysUtils, System.Classes, System.Json, System.StrUtils,
  Datasnap.DSServer, Datasnap.DSProviderDataModuleAdapter, Coinone, Common, REST.Json,
  _ServerContainer, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, cdGlobal, JdcGlobal,
  FireDAC.Stan.StorageBin, System.DateUtils, Data.SqlTimSt, JdcGlobal.ClassHelper;

type
  TsmDataProvider = class(TDSServerModule)
    qryDay: TFDQuery;
    qryTick: TFDQuery;
    FDStanStorageBinLink: TFDStanStorageBinLink;
    qryHighLow: TFDQuery;
    qryTotalValue: TFDQuery;
    procedure DSServerModuleCreate(Sender: TObject);
    procedure DSServerModuleDestroy(Sender: TObject);
  private
    FCoinone: TCoinone;
  public
    function AccountInfo(AType: Integer): TJSONObject;
    function Order(AType: Integer; AParams: TJSONObject): TJSONObject;
    function PublicInfo(AType: Integer; AParam: string): TJSONObject;

    function Day(AParams: TJSONObject): TStream;
    function Tick(AParams: TJSONObject): TStream;
    function HighLow(AParams: TJSONObject): TStream;

    function TotalValue(DateTime: Double): Double;
  end;

implementation

{$R *.dfm}

function TsmDataProvider.AccountInfo(AType: Integer): TJSONObject;
begin
  try
    result := FCoinone.AccountInfo(TRequestType(AType));
  except
    on E: Exception do
      TGlobal.Obj.ApplicationMessage(msError, 'AccountInfo', E.Message);
  end;
end;

function TsmDataProvider.Day(AParams: TJSONObject): TStream;
begin
  try
    result := ServerContainer.OpenInstantQuery(qryDay, AParams, 'Day');
  except
    on E: Exception do
      TGlobal.Obj.ApplicationMessage(msError, 'Day', E.Message);
  end;
end;

procedure TsmDataProvider.DSServerModuleCreate(Sender: TObject);
begin
  FCoinone := TCoinone.Create(ACCESS_TOKEN, SECRET_KEY);
end;

procedure TsmDataProvider.DSServerModuleDestroy(Sender: TObject);
begin
  FCoinone.Free;
end;

function TsmDataProvider.HighLow(AParams: TJSONObject): TStream;
begin
  try
    result := ServerContainer.OpenInstantQuery(qryHighLow, AParams, 'HighLow');
  except
    on E: Exception do
      TGlobal.Obj.ApplicationMessage(msError, 'HighLow', E.Message);
  end;
end;

function TsmDataProvider.Order(AType: Integer; AParams: TJSONObject): TJSONObject;
begin
  try
    result := FCoinone.Order(TRequestType(AType), AParams);
  except
    on E: Exception do
      TGlobal.Obj.ApplicationMessage(msError, 'Order', E.Message);
  end;
end;

function TsmDataProvider.PublicInfo(AType: Integer; AParam: string): TJSONObject;
begin
  try
    result := FCoinone.PublicInfo(TRequestType(AType), AParam);
  except
    on E: Exception do
      TGlobal.Obj.ApplicationMessage(msError, 'PublicInfo', E.Message);
  end;
end;

function TsmDataProvider.Tick(AParams: TJSONObject): TStream;
begin
  try
    result := ServerContainer.OpenInstantQuery(qryTick, AParams, 'Tick');
  except
    on E: Exception do
      TGlobal.Obj.ApplicationMessage(msError, 'Tick', E.Message);
  end;

end;

function TsmDataProvider.TotalValue(DateTime: Double): Double;
var
  Conn: TFDConnection;
begin
  Conn := ServerContainer.GetIdleConnection;
  try
    qryTotalValue.Close;
    qryTotalValue.Connection := Conn;
    qryTotalValue.ParamByName('day_stamp').AsSQLTimeStamp := DateTimeToSQLTimeStamp(DateTime);
    qryTotalValue.Open;
    result := qryTotalValue.FieldByName('krw').AsFloat;
  finally
    Conn.Free;
  end;

end;

end.
