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
    qryUploadDay: TFDQuery;
  private
  public
    function UploadTicker(AParams: TJSONValue): boolean;
    function UploadDay(AParams: TJSONValue): boolean;
  end;

implementation

uses _ServerContainer;

{$R *.dfm}
{ TsmDataLoader }

function TsmDataLoader.UploadDay(AParams: TJSONValue): boolean;
begin
  try
    result := ServerContainer.ExecQuery(qryUploadDay, AParams as TJSONArray, 'UploadDay');
  except
    on E: Exception do
    begin
      result := false;
      TGlobal.Obj.ApplicationMessage(msError, 'UploadDay', E.Message);
    end;
  end;
end;

function TsmDataLoader.UploadTicker(AParams: TJSONValue): boolean;
begin
  try
    result := ServerContainer.ExecQuery(qryUploadTicker, AParams as TJSONArray,
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
