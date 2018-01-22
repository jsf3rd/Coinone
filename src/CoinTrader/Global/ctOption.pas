unit ctOption;

interface

uses
  Classes, SysUtils, ctGlobal, System.IniFiles, Registry, Winapi.Windows, JclSysInfo,
  JdcGlobal, IdGlobal, Common;

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
    function GetConnInfo: TConninfo;
    procedure SetConnInfo(const Value: TConninfo);
    procedure SetAccessToken(const Value: string);
    procedure SetSecretKey(const Value: string);
    function GetUseCloudLog: boolean;
    procedure SetUseCloudLog(const Value: boolean);
    function GetChartDay: Integer;
    procedure SetChartDay(const Value: Integer);
    function GetStochHour: Integer;
    procedure SetStochHour(const Value: Integer);
  public
    class function Obj: TOption;

    destructor Destroy; override;

    property IniFile: TCustomIniFile read FIniFile;
    property AppName: string read GetAppName write SetAppName;

    property AccessToken: string read GetAccessToken write SetAccessToken;
    property SecretKey: string read GetSecretKey write SetSecretKey;

    property ConnInfo: TConninfo read GetConnInfo write SetConnInfo;
    property UserID: string read GetUserID write SetUserID;

    property UseCloudLog: boolean read GetUseCloudLog write SetUseCloudLog;

    property ChartDay: Integer read GetChartDay write SetChartDay;
    property StochHour: Integer read GetStochHour write SetStochHour;
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
  result := DecodeKey(FIniFile.ReadString('Auth', 'AccessToken', 'AccessToken'));
end;

function TOption.GetAppName: string;
begin
  result := FIniFile.ReadString('Config', 'AppName', APPLICATION_TITLE);
end;

function TOption.GetChartDay: Integer;
begin
  result := FIniFile.ReadInteger('Config', 'ChartDay', 2);
end;

function TOption.GetConnInfo: TConninfo;
begin
  result.StringValue := FIniFile.ReadString('DataSnap', 'Host', '127.0.0.1');
  result.IntegerValue := FIniFile.ReadInteger('DataSnap', 'Port', 80);
end;

function TOption.GetSecretKey: string;
begin
  result := DecodeKey(FIniFile.ReadString('Auth', 'SecretKey', 'SecretKey'));
end;

function TOption.GetStochHour: Integer;
begin
  result := FIniFile.ReadInteger('Config', 'StochHour', 7);
end;

function TOption.GetUseCloudLog: boolean;
begin
  result := FIniFile.ReadBool('Config', 'UseCloudLog', false);
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

procedure TOption.SetAccessToken(const Value: string);
begin
  FIniFile.WriteString('Auth', 'AccessToken', EncodeKey(Value));
end;

procedure TOption.SetAppName(const Value: string);
begin
  FIniFile.WriteString('Config', 'AppName', Value);
end;

procedure TOption.SetChartDay(const Value: Integer);
begin
  FIniFile.WriteInteger('Config', 'ChartDay', Value);
end;

procedure TOption.SetConnInfo(const Value: TConninfo);
begin
  FIniFile.WriteString('DataSnap', 'Host', Value.StringValue);
  FIniFile.WriteInteger('DataSnap', 'Port', Value.IntegerValue);
end;

procedure TOption.SetSecretKey(const Value: string);
begin
  FIniFile.WriteString('Auth', 'SecretKey', EncodeKey(Value));
end;

procedure TOption.SetStochHour(const Value: Integer);
begin
  FIniFile.WriteInteger('Config', 'StochHour', Value);
end;

procedure TOption.SetUseCloudLog(const Value: boolean);
begin
  FIniFile.ReadBool('Config', 'UseCloudLog', Value);
end;

procedure TOption.SetUserID(const Value: string);
begin
  FIniFile.WriteString('Config', 'UserID', Value);
  TGlobal.Obj.UserID := Value;
end;

end.
