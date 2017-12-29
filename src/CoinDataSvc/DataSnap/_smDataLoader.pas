unit _smDataLoader;

interface

uses
  System.SysUtils, System.Classes, Datasnap.DSServer,
  Datasnap.DSProviderDataModuleAdapter, System.JSON,
  REST.JSON, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TsmDataLoader = class(TDSServerModule)
    qryUplaodTicker: TFDQuery;
  private
  public
    function UploadTicker(AParams: TJSONObject): boolean;
  end;

implementation

uses _ServerContainer;

{$R *.dfm}
{ TsmDataLoader }

function TsmDataLoader.UploadTicker(AParams: TJSONObject): boolean;
begin
  result := ServerContainer.ExecQuery(qryUplaodTicker, AParams, 'UploadTicker');
end;

end.
