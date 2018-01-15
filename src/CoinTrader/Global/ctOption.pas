unit ctOption;

interface

uses
  Classes, SysUtils, ctGlobal, System.IniFiles, Registry, Winapi.Windows, JclSysInfo;

type
  TOption = class
  private
    FIniFile: TCustomIniFile;
    constructor Create;
    function GetAppName: string;
    procedure SetAppName(const Value: string);
    function GetAccessToken: string;
    function GetSecretKey: string;
    function GetUserID: string;
    procedure SetUserID(const Value: string);
  public
    class function Obj: TOption;

    destructor Destroy; override;

    property IniFile: TCustomIniFile read FIniFile;
    property AppName: string read GetAppName write SetAppName;

    property AccessToken: string read GetAccessToken;
    property SecretKey: string read GetSecretKey;

    property UserID: string read GetUserID write SetUserID;
  end;

implementation

var
  MyObj: TOption = nil;

  { TOption }

constructor TOption.Create;
var
  FileName: string;
begin
  // IniFile...
  FileName := ChangeFileExt(TGlobal.Obj.ExeName, '.ini');
  FIniFile := TIniFile.Create(FileName);

  // FIniFile := TMemIniFile.Create(FileName);

  // Registry...
  // FileName:= ''SOFTWARE\PlayIoT\' + PROJECT_CODE;
  // FIniFile := TRegistryIniFile.Create(FileName);
  // TRegistryIniFile(FIniFile).RegIniFile.RootKey := HKEY_CURRENT_USER;
end;

destructor TOption.Destroy;
begin
  if Assigned(FIniFile) then
    FIniFile.Free;

  inherited;
end;

function TOption.GetAccessToken: string;
begin
  result := FIniFile.ReadString('Auth', 'AccessToken', '');
end;

function TOption.GetAppName: string;
begin
  result := FIniFile.ReadString('Config', 'AppName', APPLICATION_TITLE);
end;

function TOption.GetSecretKey: string;
begin
  result := FIniFile.ReadString('Auth', 'SecretKey', '');
end;

function TOption.GetUserID: string;
begin
  result := FIniFile.ReadString('Config', 'UserID', GetLocalUserName);
end;

class function TOption.Obj: TOption;
begin
  if MyObj = nil then
  begin
    MyObj := TOption.Create;
  end;
  result := MyObj;
end;

procedure TOption.SetAppName(const Value: string);
begin
  FIniFile.WriteString('Config', 'AppName', Value);
end;

procedure TOption.SetUserID(const Value: string);
begin
  FIniFile.WriteString('Config', 'UserID', Value);
end;

end.
