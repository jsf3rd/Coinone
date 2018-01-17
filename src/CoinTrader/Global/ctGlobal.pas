unit ctGlobal;

interface

uses
  Classes, SysUtils, IOUtils, JdcGlobal, Common;

const
  APPLICATION_CODE = 'CoinTrader';
  APPLICATION_TITLE = 'Coin Trader';
  APPLICATION_VERSION = 'v1.0';
  COPY_RIGHT_SIGN = '¨Ï 2017 playIoT';
  HOME_PAGE_URL = 'http://www.playIoT.biz';

  LOCAL_SERVER = '\\localhost';

type
  TGlobal = class(TGlobalAbstract)
  strict private
    FUserID: string;
  protected
    procedure SetExeName(const Value: String); override;
  public
    constructor Create; override;
    destructor Destroy; override;

    class function Obj: TGlobal;

    procedure ApplicationMessage(const AType: TMessageType; const ATitle: String;
      const AMessage: String = ''); override;

    procedure Initialize; override;
    procedure Finalize; override;

    property UserID: string read FUserID write FUserID;
  end;

implementation

uses ctOption, JdcView, JdcGlobal.ClassHelper;

var
  MyObj: TGlobal = nil;

  { TGlobal }

procedure TGlobal.ApplicationMessage(const AType: TMessageType; const ATitle: String;
  const AMessage: String);
begin
  inherited;

  case AType of
    msDebug:
      _ApplicationMessage(MESSAGE_TYPE_DEBUG, ATitle, AMessage, [moCloudMessage]);
    msError:
      TView.Obj.sp_ErrorMessage(ATitle, AMessage);
    msInfo:
      TView.Obj.sp_LogMessage(ATitle, AMessage);
  end;
end;

constructor TGlobal.Create;
begin
  inherited;

  FProjectCode := PROJECT_CODE;
  FAppCode := APPLICATION_CODE;

  // TOTO : after create
end;

destructor TGlobal.Destroy;
begin

  // TOTO : before Finalize

  inherited;
end;

procedure TGlobal.Finalize;
begin
  if FIsfinalized then
    Exit;
  FIsfinalized := true;

  // Todo :

  ApplicationMessage(msDebug, 'Stop', 'StartTime=' + FStartTime.ToString);
end;

procedure TGlobal.Initialize;
begin
  if FIsfinalized then
    Exit;
  if FIsInitialized then
    Exit;
  FIsInitialized := true;

  FUseCloudLog := TOption.Obj.UseCloudLog;
  FStartTime := now;
  // FLogServer.StringValue := 'log.iccs.co.kr';

  FUserID := TOption.Obj.UserID;

{$IFDEF WIN32}
  ApplicationMessage(msDebug, 'Start', '(x86)' + FExeName);
{$ENDIF}
{$IFDEF WIN64}
  ApplicationMessage(mtDebug, 'Start', '(x64)' + FxeName);
{$ENDIF}
  // Todo :
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
  FLogName := GetEnvironmentVariable('LOCALAPPDATA') + '\playIoT\' + ExtractFileName(FLogName);

  if not TDirectory.Exists(ExtractFilePath(FLogName)) then
    TDirectory.CreateDirectory(ExtractFilePath(FLogName));
end;

initialization

MyObj := TGlobal.Create;

end.
