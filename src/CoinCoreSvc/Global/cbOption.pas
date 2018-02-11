unit cbOption;

interface

uses
  Classes, SysUtils, System.IniFiles, Registry, JdcGlobal,
  Winapi.Windows, cbGlobal, JclSysInfo, Common, JdcGlobal.ClassHelper, REST.JSON, System.JSON;

type
  TOption = class
  private
    FIniFile: TCustomIniFile;
    constructor Create;

  private
    function GetAccessToken: string;
    function GetSecretKey: string;
    function GetUseUploadTicker: boolean;
    procedure SetUseUploadTicker(const Value: boolean);
    function GetConnInfo: TConninfo;
    procedure SetConnInfo(const Value: TConninfo);
    function GetUserID: string;
    procedure SetUserID(const Value: string);
    function GetTraderOption(ACurrency: string): TTraderOption;
    function GetUseCloudLog: boolean;
    procedure SetUseCloudLog(const Value: boolean);
  public
    class function Obj: TOption;
    destructor Destroy; override;

    property AccessToken: string read GetAccessToken;
    property SecretKey: string read GetSecretKey;

    property TraderOption[ACurrency: string]: TTraderOption read GetTraderOption;
    property UseUploadTicker: boolean read GetUseUploadTicker write SetUseUploadTicker;
    property ConnInfo: TConninfo read GetConnInfo write SetConnInfo;
    property UserID: string read GetUserID write SetUserID;
    property UseCloudLog: boolean read GetUseCloudLog write SetUseCloudLog;

    property IniFile: TCustomIniFile read FIniFile;

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
  result := DecodeKey(FIniFile.ReadString('Auth', 'AccessToken', ''));
end;

function TOption.GetTraderOption(ACurrency: string): TTraderOption;
var
  Str: string;
begin
  Str := FIniFile.ReadString('TraderOption', ACurrency, '');
  result := TJson.JsonToRecord<TTraderOption>(Str);
end;

function TOption.GetConnInfo: TConninfo;
begin
  result.StringValue := FIniFile.ReadString('DataSnap', 'Host', '127.0.0.1');
  result.IntegerValue := FIniFile.ReadInteger('DataSnap', 'Port', 80);
end;

function TOption.GetSecretKey: string;
begin
  result := DecodeKey(FIniFile.ReadString('Auth', 'SecretKey', ''));
end;

function TOption.GetUseCloudLog: boolean;
begin
  result := FIniFile.ReadBool('Config', 'UseCloudLog', false);
end;

function TOption.GetUserID: string;
begin
  result := FIniFile.ReadString('Config', 'UserID', GetLocalUserName);
end;

function TOption.GetUseUploadTicker: boolean;
begin
  result := FIniFile.ReadBool('Config', 'UseUploadTicker', false);
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

procedure TOption.SetUseCloudLog(const Value: boolean);
begin
  FIniFile.WriteBool('Config', 'UseCloudLog', Value);
end;

procedure TOption.SetUserID(const Value: string);
begin
  FIniFile.WriteString('Config', 'UserID', Value);
end;

procedure TOption.SetUseUploadTicker(const Value: boolean);
begin
  FIniFile.WriteBool('Config', 'UseUploadTicker', Value);
end;

end.
