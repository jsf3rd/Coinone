unit cdGlobal;

interface

uses
  Classes, SysUtils, IOUtils, JdcGlobal, common;

const
  SERVICE_NAME = 'Coin Data Service Application';
  SERVICE_DESCRIPTION = '코인 데이터를 기록하는 작업을 수행합니다.';

type
  TGlobal = class(TGlobalAbstract)
  protected
    procedure SetExeName(const Value: String); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    class function Obj: TGlobal;

    procedure Initialize; override;
    procedure Finalize; override;
  end;

implementation

uses cdOption;

var
  MyObj: TGlobal = nil;

  { TGlobal }

constructor TGlobal.Create;
begin
  inherited;

  FProjectCode := PROJECT_CODE;
  FAppCode := DATA_SERVICE_CODE;

  // TODO : after Create
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
  // FLogName := GetEnvironmentVariable('LOCALAPPDATA') + '\playIoT\' +
  // ExtractFileName(FLogName);

  if not TDirectory.Exists(ExtractFilePath(FLogName)) then
    TDirectory.CreateDirectory(ExtractFilePath(FLogName));

  FUseCloudLog := TOption.Obj.UseCloudLog;
  // FLogServer.StringValue := LOG_SERVER;
end;

initialization

MyObj := TGlobal.Create;

end.
