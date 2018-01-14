unit _smDataProvider;

interface

uses System.SysUtils, System.Classes, System.Json, System.StrUtils,
  Datasnap.DSServer, Datasnap.DSProviderDataModuleAdapter, Coinone, Common, REST.Json,
  _ServerContainer, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, cdGlobal, JdcGlobal,
  FireDAC.Stan.StorageBin, System.DateUtils, Data.SqlTimSt, JdcGlobal.ClassHelper, cdOption,
  JdcGlobal.DSCommon;

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
    function HighLow(ACoin: string; APeriod: TDateTime): TJSONObject;

    function TotalValue(ADateTime: TDateTime): Double;
  end;

implementation

{$R *.dfm}

function TsmDataProvider.AccountInfo(AType: Integer): TJSONObject;
var
  ExecTime: TDateTime;
begin
  try
    ExecTime := Now;
    result := FCoinone.AccountInfo(TRequestType(AType));
    TGlobal.Obj.ApplicationMessage(msDebug, 'AccountInfo', 'Command=%s,ExecTime=%s',
      [TCoinone.RequestName(AType), FormatDateTime('NN: SS.zzz ', Now - ExecTime)]);
  except
    on E: Exception do
    begin
      TGlobal.Obj.ApplicationMessage(msError, 'AccountInfo', E.Message);
      result := nil;
    end;
  end;
end;

function TsmDataProvider.Day(AParams: TJSONObject): TStream;
begin
  try
    result := ServerContainer.OpenInstantQuery(qryDay, AParams, 'Day');
  except
    on E: Exception do
    begin
      result := nil;
      TGlobal.Obj.ApplicationMessage(msError, 'Day', E.Message);
    end;
  end;
end;

procedure TsmDataProvider.DSServerModuleCreate(Sender: TObject);
begin
  FCoinone := TCoinone.Create(TOption.Obj.AccessToken, TOption.Obj.SecretKey);
end;

procedure TsmDataProvider.DSServerModuleDestroy(Sender: TObject);
begin
  FCoinone.Free;
end;

function TsmDataProvider.HighLow(ACoin: string; APeriod: TDateTime): TJSONObject;
var
  ExecTime: TDateTime;
  Conn: TFDConnection;
begin
  try
    Conn := ServerContainer.GetIdleConnection;
    try

      qryHighLow.Connection := Conn;
      qryHighLow.ParamByName('coin_code').AsString := ACoin;
      qryHighLow.ParamByName('begin_time').AsSQLTimeStamp := DateTimeToSQLTimeStamp(APeriod);
      qryHighLow.ParamByName('end_time').AsSQLTimeStamp := DateTimeToSQLTimeStamp(Now);

      ExecTime := Now;
      qryHighLow.Open;
      TGlobal.Obj.ApplicationMessage(msDebug, 'HighLow', 'Period=%s,ExecTime=%s',
        [APeriod.FormatWithoutMSec, FormatDateTime('NN: SS.zzz ', Now - ExecTime)]);

      result := qryHighLow.ToJSON;
    finally
      Conn.Free;
    end;
  except
    on E: Exception do
    begin
      result := TJSONObject.Create;
      TGlobal.Obj.ApplicationMessage(msError, 'HighLow', E.Message);
    end;
  end;
end;

function TsmDataProvider.Order(AType: Integer; AParams: TJSONObject): TJSONObject;
var
  ExecTime: TDateTime;
begin
  try
    ExecTime := Now;
    result := FCoinone.Order(TRequestType(AType), AParams);
    TGlobal.Obj.ApplicationMessage(msDebug, 'Order', 'Command=%s,Params=%s,ExecTime=%s',
      [TCoinone.RequestName(AType), AParams.ToString, FormatDateTime('NN: SS.zzz ',
      Now - ExecTime)]);
  except
    on E: Exception do
    begin
      TGlobal.Obj.ApplicationMessage(msError, 'Order', E.Message);
      result := nil;
    end;
  end;
end;

function TsmDataProvider.PublicInfo(AType: Integer; AParam: string): TJSONObject;
var
  ExecTime: TDateTime;
begin
  try
    ExecTime := Now;
    result := FCoinone.PublicInfo(TRequestType(AType), AParam);
    TGlobal.Obj.ApplicationMessage(msDebug, 'PublicInfo', 'Command=%s,Param=%s,ExecTime=%s',
      [TCoinone.RequestName(AType), AParam, FormatDateTime('NN: SS.zzz ', Now - ExecTime)]);
  except
    on E: Exception do
    begin
      TGlobal.Obj.ApplicationMessage(msError, 'PublicInfo', E.Message);
      result := nil;
    end;
  end;
end;

function TsmDataProvider.Tick(AParams: TJSONObject): TStream;
begin
  try
    result := ServerContainer.OpenInstantQuery(qryTick, AParams, 'Tick');
  except
    on E: Exception do
    begin
      TGlobal.Obj.ApplicationMessage(msError, 'Tick', E.Message);
      result := nil;
    end;
  end;
end;

function TsmDataProvider.TotalValue(ADateTime: TDateTime): Double;
var
  Conn: TFDConnection;
begin
  Conn := ServerContainer.GetIdleConnection;
  try
    qryTotalValue.Close;
    qryTotalValue.Connection := Conn;
    qryTotalValue.ParamByName('day_stamp').AsSQLTimeStamp := DateTimeToSQLTimeStamp(ADateTime);
    qryTotalValue.Open;
    result := qryTotalValue.FieldByName('krw').AsFloat;
  finally
    Conn.Free;
  end;

end;

end.
