unit _smDataProvider;

interface

uses System.SysUtils, System.Classes, System.Json, System.StrUtils,
  Datasnap.DSServer, Datasnap.DSProviderDataModuleAdapter, Common, REST.Json,
  _ServerContainer, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, cdGlobal, JdcGlobal,
  FireDAC.Stan.StorageBin, System.DateUtils, Data.SqlTimSt, JdcGlobal.ClassHelper, cdOption,
  JdcGlobal.DSCommon;

type
  TsmDataProvider = class(TDSServerModule)
    qryTicker: TFDQuery;
    FDStanStorageBinLink: TFDStanStorageBinLink;
    qryHighLow: TFDQuery;
    qryOrder: TFDQuery;
  public
    function Ticker(AParams: TJSONObject): TStream;
    function Orders(AParams: TJSONObject): TStream;
    function HighLow(ACoin: string; APeriod: TDateTime): TJSONObject;

    function GetClientInfo: TJSONObject;
  end;

implementation

{$R *.dfm}

function TsmDataProvider.GetClientInfo: TJSONObject;
begin
  try
    result := TJSON.RecordToJsonObject(TOption.Obj.ClientInfo);
  except
    on E: Exception do
    begin
      result := TJSONObject.Create;
      TGlobal.Obj.ApplicationMessage(msError, 'GetClientInfo', E.Message);
    end;
  end;
end;

function TsmDataProvider.HighLow(ACoin: string; APeriod: TDateTime): TJSONObject;
var
  Conn: TFDConnection;
begin
  try
    Conn := ServerContainer.GetIdleConnection;
    try
      qryHighLow.Connection := Conn;
      qryHighLow.ParamByName('coin_code').AsString := ACoin;
      qryHighLow.ParamByName('begin_time').AsSQLTimeStamp := DateTimeToSQLTimeStamp(APeriod);
      qryHighLow.ParamByName('end_time').AsSQLTimeStamp := DateTimeToSQLTimeStamp(Now);
      qryHighLow.Open;
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

function TsmDataProvider.Orders(AParams: TJSONObject): TStream;
begin
  try
    result := ServerContainer.OpenInstantQuery(qryOrder, AParams, 'Orders');
  except
    on E: Exception do
    begin
      TGlobal.Obj.ApplicationMessage(msError, 'Orders', E.Message);
      result := nil;
    end;
  end;
end;

function TsmDataProvider.Ticker(AParams: TJSONObject): TStream;
var
  MyQuery: TFDQuery;
  sql: string;
begin
  sql := qryTicker.sql.Text;
  sql := sql.Replace('%short_period%', 'interval ' + AParams.GetString('short_period')
    .QuotedString, [rfReplaceAll, rfIgnoreCase]);
  sql := sql.Replace('%long_period%', 'interval ' + AParams.GetString('long_period')
    .QuotedString, [rfReplaceAll, rfIgnoreCase]);

  MyQuery := qryTicker.Clone;
  try
    MyQuery.sql.Text := sql;
    try
      result := ServerContainer.OpenQuery(MyQuery, AParams, 'Ticker');
    except
      on E: Exception do
      begin
        TGlobal.Obj.ApplicationMessage(msError, 'Ticker', ',E=' + E.Message);
        result := nil;
      end;
    end;
  finally
    MyQuery.Free;
  end;
end;

end.
