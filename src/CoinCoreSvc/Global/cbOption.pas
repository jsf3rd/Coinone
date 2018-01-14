unit cbOption;

interface

uses
  Classes, SysUtils, System.IniFiles, Registry, JdcGlobal,
  Winapi.Windows, cbGlobal;

type
  TOption = class
  private
    FIniFile: TCustomIniFile;
    constructor Create;

  private
    function GetAccessToken: string;
    function GetSecretKey: string;
    function GetTraderOption: string;
    procedure SetTraderOption(const Value: string);
    function GetUseTickLoader: boolean;
    procedure SetUseTickLoader(const Value: boolean);
    function GetConnInfo: TConninfo;
    procedure SetConnInfo(const Value: TConninfo);
  public
    class function Obj: TOption;
    destructor Destroy; override;

    property AccessToken: string read GetAccessToken;
    property SecretKey: string read GetSecretKey;

    property TraderOption: string read GetTraderOption write SetTraderOption;
    property UseTickLoader: boolean read GetUseTickLoader write SetUseTickLoader;
    property ConnInfo: TConninfo read GetConnInfo write SetConnInfo;
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

function TOption.GetConnInfo: TConninfo;
begin
  result.StringValue := FIniFile.ReadString('DataSnap', 'Host', '127.0.0.1');
  result.IntegerValue := FIniFile.ReadInteger('DataSnap', 'Port', 80);
end;

function TOption.GetSecretKey: string;
begin
  result := FIniFile.ReadString('Auth', 'SecretKey', '');
end;

function TOption.GetTraderOption: string;
begin
  result := FIniFile.ReadString('Config', 'TraderOption', '');
end;

function TOption.GetUseTickLoader: boolean;
begin
  result := FIniFile.ReadBool('Config', 'UseTickLoader', False);
end;

class function TOption.Obj: TOption;
begin
  if MyObj = nil then
  begin
    MyObj := TOption.Create;
  end;
  result := MyObj;
end;

procedure TOption.SetConnInfo(const Value: TConninfo);
begin
  FIniFile.WriteString('DataSnap', 'Host', Value.StringValue);
  FIniFile.WriteInteger('DataSnap', 'Port', Value.IntegerValue);
end;

procedure TOption.SetTraderOption(const Value: string);
begin
  FIniFile.WriteString('Config', 'TraderOption', Value);
end;

procedure TOption.SetUseTickLoader(const Value: boolean);
begin
  FIniFile.WriteBool('Config', 'UseTickLoader', Value);
end;

end.
