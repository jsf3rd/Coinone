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
    function GetUseTickLoader: boolean;
    procedure SetUseTickLoader(const Value: boolean);
    function GetConnInfo: TConninfo;
    procedure SetConnInfo(const Value: TConninfo);
    function GetUserID: string;
    procedure SetUserID(const Value: string);
    function GetCoinInfo(ACurrency: string): TCoinInfo;
    procedure SetCoinInfo(ACurrency: string; const Value: TCoinInfo);
  public
    class function Obj: TOption;
    destructor Destroy; override;

    property AccessToken: string read GetAccessToken;
    property SecretKey: string read GetSecretKey;

    property CoinInfo[ACurrency: string]: TCoinInfo read GetCoinInfo write SetCoinInfo;
    property UseTickLoader: boolean read GetUseTickLoader write SetUseTickLoader;
    property ConnInfo: TConninfo read GetConnInfo write SetConnInfo;
    property UserID: string read GetUserID write SetUserID;

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
  result := FIniFile.ReadString('Auth', 'AccessToken', '');
end;

function TOption.GetCoinInfo(ACurrency: string): TCoinInfo;
begin
  result := TJson.JsonToRecord<TCoinInfo>(FIniFile.ReadString('TraderOption', ACurrency, ''));
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

function TOption.GetUserID: string;
begin
  result := FIniFile.ReadString('Config', 'UserID', GetLocalUserName);
end;

function TOption.GetUseTickLoader: boolean;
begin
  result := FIniFile.ReadBool('Config', 'UploaderTicker', False);
end;

class function TOption.Obj: TOption;
begin
  if MyObj = nil then
  begin
    MyObj := TOption.Create;
  end;
  result := MyObj;
end;

procedure TOption.SetCoinInfo(ACurrency: string; const Value: TCoinInfo);
begin
  FIniFile.WriteString('TraderOption', ACurrency, TJson.RecordToJsonString(Value));
end;

procedure TOption.SetConnInfo(const Value: TConninfo);
begin
  FIniFile.WriteString('DataSnap', 'Host', Value.StringValue);
  FIniFile.WriteInteger('DataSnap', 'Port', Value.IntegerValue);
end;

procedure TOption.SetUserID(const Value: string);
begin
  FIniFile.WriteString('Config', 'UserID', Value);
end;

procedure TOption.SetUseTickLoader(const Value: boolean);
begin
  FIniFile.WriteBool('Config', 'UploadTicker', Value);
end;

end.
