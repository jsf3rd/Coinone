unit cbOption;

interface

uses
  Classes, SysUtils, System.IniFiles, Registry,
  Winapi.Windows, cbGlobal;

type
  TOption = class
  private
    FIniFile: TCustomIniFile;
    constructor Create;

  private
    function GetAccessToken: string;
    function GetSecretKey: string;
  public
    class function Obj: TOption;
    destructor Destroy; override;

    property AccessToken: string read GetAccessToken;
    property SecretKey: string read GetSecretKey;
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
  FileName := ChangeFileExt(TGlobal.Obj.LogName, '.ini');
  FIniFile := TIniFile.Create(FileName);

  // FIniFile := TMemIniFile.Create(FileName);

  // Registry...
  // FileName:= 'SOFTWARE\PlayIoT\' + PROJECT_CODE;
  // FIniFile := TRegistryIniFile.Create(FileName);
  // TRegistryIniFile(FIniFile).RegIniFile.RootKey := HKEY_LOCAL_MACHINE;
  // TRegistryIniFile(FIniFile).RegIniFile.OpenKey(FIniFile.FileName, True);
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

function TOption.GetSecretKey: string;
begin
  result := FIniFile.ReadString('Auth', 'SecretKey', '');
end;

class function TOption.Obj: TOption;
begin
  if MyObj = nil then
  begin
    MyObj := TOption.Create;
  end;
  result := MyObj;
end;

end.
