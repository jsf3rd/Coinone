unit _dmDataLoader;

interface

uses
  System.SysUtils, System.Classes, Data.DBXDataSnap, IPPeerClient, Data.DBXCommon,
  Data.DbxHTTPLayer, Data.DB, Data.SqlExpr, System.JSON, REST.JSON, Coinone;

type
  TTicker = record
    volume: double;
    yesterday_volume: double;
    now_price: double;
    tick_time: TDateTime;
    coin_code: string;
  end;

  TdmDataLoader = class(TDataModule)
    SQLConnection: TSQLConnection;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FCoinone: TCoinone;
  public
    procedure Tick;
  end;

var
  dmDataLoader: TdmDataLoader;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}
{ TdmDataLoader }

procedure TdmDataLoader.DataModuleCreate(Sender: TObject);
begin
  FCoinone := TCoinone.Create('34d16954-b16e-498f-af7c-21e51c9e019c',
    '2a71d4d8-7a37-409d-8228-90cd08868c47');
end;

procedure TdmDataLoader.DataModuleDestroy(Sender: TObject);
begin
  FCoinone.Free;
end;

procedure TdmDataLoader.Tick;
var
  JSONObject: TJSONObject;
begin
  JSONObject := FCoinone.PublicInfo(rtTicker, 'currency=all');
  try

  finally
    JSONObject.Free;
  end;
end;

end.
