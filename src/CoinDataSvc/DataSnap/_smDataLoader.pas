unit _smDataLoader;

interface

uses
  System.SysUtils, System.Classes, Datasnap.DSServer,
  Datasnap.DSProviderDataModuleAdapter, System.JSON,
  REST.JSON, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, JdcGlobal, cdGlobal;

type
  TsmDataLoader = class(TDSServerModule)
    qryUploadTicker: TFDQuery;
    qryUploadOrder: TFDQuery;
    qryDeleteOrder: TFDQuery;
  private
  public
    function UploadTicker(AParams: TJSONValue): boolean;
    function UploadOrder(AParams: TJSONValue): boolean;
    function DeleteOrder(AID: String): boolean;
  end;

implementation

uses _ServerContainer;

{$R *.dfm}
{ TsmDataLoader }

function TsmDataLoader.DeleteOrder(AID: String): boolean;
var
  Params: TJSONObject;
begin
  Params := TJSONObject.Create;
  try
    Params.AddPair('order_id', AID);
    try
      result := ServerContainer.ExecInstantQuery(qryDeleteOrder, Params, 'DeleteOrder');
    except
      on E: Exception do
      begin
        result := false;
        TGlobal.Obj.ApplicationMessage(msError, 'DeleteOrder', E.Message);
      end;
    end;
  finally
    Params.Free;
  end;
end;

function TsmDataLoader.UploadOrder(AParams: TJSONValue): boolean;
begin
  try
    result := ServerContainer.ExecInstantQuery(qryUploadOrder, AParams as TJSONObject,
      'UploadOrder');
  except
    on E: Exception do
    begin
      result := false;
      TGlobal.Obj.ApplicationMessage(msError, 'UploadOrder', E.Message);
    end;
  end;
end;

function TsmDataLoader.UploadTicker(AParams: TJSONValue): boolean;
begin
  try
    result := ServerContainer.ExecInstantQuery(qryUploadTicker, AParams as TJSONArray,
      'UploadTicker');
  except
    on E: Exception do
    begin
      result := false;
      TGlobal.Obj.ApplicationMessage(msError, 'UploadTicker', E.Message);
    end;
  end;
end;

end.
