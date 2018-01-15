unit cbGlobal;

interface

uses
  Classes, SysUtils, IOUtils, JdcGlobal, Common;

const
  SERVICE_CODE = 'CoinCoreSvc';
  SERVICE_NAME = 'Coin Currency Data Uploader Service Application';
  SERVICE_DESCRIPTION = '분석을 위한 초기 데이터를 수집 합니다.';

type
  TGlobal = class(TGlobalAbstract)
  private
    FUseTickLoader: boolean;
    FConnInfo: TConnInfo;
    FUserID: string;
  protected
    procedure SetExeName(const Value: String); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    class function Obj: TGlobal;

    procedure Initialize; override;
    procedure Finalize; override;

    property UseTickLoader: boolean read FUseTickLoader write FUseTickLoader;
    property ConnInfo: TConnInfo read FConnInfo write FConnInfo;
    property UserID: string read FUserID write FUserID;
  end;

  THighLow = record
    high_price: integer;
    low_price: integer;
  end;

implementation

uses cbOption;

var
  MyObj: TGlobal = nil;

  { TGlobal }

constructor TGlobal.Create;
begin
  inherited;

  FProjectCode := PROJECT_CODE;
  FAppCode := SERVICE_CODE;

  // TODO : after create
end;

destructor TGlobal.Destroy;
begin
  // TODO : before Finalize

  inherited;
end;

procedure TGlobal.Finalize;
begin
  if FIsfinalized then
    Exit;
  FIsfinalized := true;

  // Todo :

  inherited;
end;

procedure TGlobal.Initialize;
begin
  if FIsfinalized then
    Exit;
  if FIsInitialized then
    Exit;
  FIsInitialized := true;

  inherited;

  FUseTickLoader := TOption.Obj.UseTickLoader;
  FConnInfo := TOption.Obj.ConnInfo;
  FUserID := TOption.Obj.UserID;

  // Todo :
  // FLogServer.StringValue := 'log.iccs.co.kr';
end;

class function TGlobal.Obj: TGlobal;
begin
  if MyObj = nil then
    MyObj := TGlobal.Create;
  result := MyObj;
end;

procedure TGlobal.SetExeName(const Value: String);
begin
  FExeName := Value;
  FLogName := ChangeFileExt(FExeName, '.log');

  if not TDirectory.Exists(ExtractFilePath(FLogName)) then
    TDirectory.CreateDirectory(ExtractFilePath(FLogName));
end;

initialization

MyObj := TGlobal.Create;

end.
