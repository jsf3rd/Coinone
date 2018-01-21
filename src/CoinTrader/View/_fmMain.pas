unit _fmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Winapi.Shellapi,
  Vcl.Controls, Vcl.Forms, Vcl.ActnList, ValueList, Vcl.Dialogs, System.Actions,
  Vcl.Menus, Vcl.AppEvnts, Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids,
  _dmDataProvider, VclTee.TeeGDIPlus, VclTee.TeEngine, VclTee.Series, VclTee.TeeProcs,
  VclTee.Chart, VclTee.DBChart, Vcl.ComCtrls, System.DateUtils, Vcl.Mask, JclSvcCtrl,
  Vcl.CheckLst, Common, JvExDBGrids, JvDBGrid;

type
  TfmMain = class(TForm)
    MainMenu: TMainMenu;
    File1: TMenuItem;
    ool1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    ApplicationEvents: TApplicationEvents;
    ActionList: TActionList;
    actAbout: TAction;
    actExit: TAction;
    actShowIni: TAction;
    actShowLog: TAction;
    actTestMenu: TAction;
    MenuTest: TMenuItem;
    Exit1: TMenuItem;
    ShowIniFile1: TMenuItem;
    ShowLog1: TMenuItem;
    grdMain: TDBGrid;
    Panel1: TPanel;
    Button1: TButton;
    actTick: TAction;
    chtMain: TDBChart;
    Series1: TLineSeries;
    Series2: TLineSeries;
    Panel2: TPanel;
    Panel3: TPanel;
    Series5: TLineSeries;
    PageControl: TPageControl;
    tsMain: TTabSheet;
    tsTrad: TTabSheet;
    dbgBalance: TDBGrid;
    Panel4: TPanel;
    actMarketASK: TAction;
    actMarketBID: TAction;
    Button4: TButton;
    actBalance: TAction;
    StatusBar: TStatusBar;
    GroupBox1: TGroupBox;
    Button2: TButton;
    Button3: TButton;
    edtKrwValue: TLabeledEdit;
    GroupBox2: TGroupBox;
    Button6: TButton;
    Button7: TButton;
    edtLimitCount: TLabeledEdit;
    edtLimitPrice: TLabeledEdit;
    actLimitASK: TAction;
    actLimitBID: TAction;
    Panel5: TPanel;
    Splitter1: TSplitter;
    pnlLimitOrderTitle: TPanel;
    Button5: TButton;
    actCancelOrder: TAction;
    Splitter: TSplitter;
    lblRecentOrder: TLabel;
    GroupBox3: TGroupBox;
    edtChartDay: TLabeledEdit;
    edtKrwView: TLabeledEdit;
    chtStoch: TDBChart;
    Series4: TLineSeries;
    edtStochHour: TLabeledEdit;
    tsPreference: TTabSheet;
    Series7: TPointSeries;
    Series3: TPointSeries;
    Series6: TPointSeries;
    Series8: TPointSeries;
    Splitter2: TSplitter;
    Panel6: TPanel;
    GroupBox4: TGroupBox;
    edtHost: TLabeledEdit;
    edtPort: TLabeledEdit;
    GroupBox5: TGroupBox;
    Button8: TButton;
    Button9: TButton;
    edtDataStatus: TLabeledEdit;
    Button10: TButton;
    Button11: TButton;
    edtCoreStatus: TLabeledEdit;
    actStartDataSvc: TAction;
    actStopDataSvc: TAction;
    ServiceStatusTimer: TTimer;
    actStartCoreSvc: TAction;
    actStopCoreSvc: TAction;
    edtUserID: TLabeledEdit;
    Button12: TButton;
    actSaveConfig: TAction;
    edtAccessToken: TLabeledEdit;
    edtSecretKey: TLabeledEdit;
    Series10: TLineSeries;
    dbgLimitOrder: TJvDBGrid;
    dbgRecentOrders: TJvDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actExitExecute(Sender: TObject);
    procedure actShowIniExecute(Sender: TObject);
    procedure actShowLogExecute(Sender: TObject);
    procedure actTestMenuExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure actTickExecute(Sender: TObject);
    procedure grdMainDblClick(Sender: TObject);
    procedure actBalanceExecute(Sender: TObject);
    procedure actMarketBIDExecute(Sender: TObject);
    procedure actMarketASKExecute(Sender: TObject);
    procedure btnAddKrwClick(Sender: TObject);
    procedure actLimitASKExecute(Sender: TObject);
    procedure actLimitBIDExecute(Sender: TObject);
    procedure dbgBalanceDblClick(Sender: TObject);
    procedure actCancelOrderExecute(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure edtLimitCountChange(Sender: TObject);
    procedure Panel3Resize(Sender: TObject);
    procedure ServiceStatusTimerTimer(Sender: TObject);
    procedure actStartDataSvcExecute(Sender: TObject);
    procedure actStopDataSvcExecute(Sender: TObject);
    procedure actStartCoreSvcExecute(Sender: TObject);
    procedure actStopCoreSvcExecute(Sender: TObject);
    procedure tsPreferenceShow(Sender: TObject);
    procedure actSaveConfigExecute(Sender: TObject);
    procedure Panel5Resize(Sender: TObject);

  private
    FOldDataStatus: TJclServiceState;
    FOldCoreStatus: TJclServiceState;
  published
    procedure rp_Terminate(APacket: TValueList);
    procedure rp_Init(APacket: TValueList);

    procedure rp_ErrorMessage(APacket: TValueList);
    procedure rp_LogMessage(APacket: TValueList);

    procedure rp_TickStamp(APacket: TValueList);
    procedure rp_KrwValue(APacket: TValueList);
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

uses JdcGlobal, ctGlobal, ctOption, JdcView, Core, System.UITypes;

procedure TfmMain.actAboutExecute(Sender: TObject);
begin
  MessageDlg(APPLICATION_TITLE + ' ' + FileVersion(Application.ExeName) + ' ' + COPY_RIGHT_SIGN
    + #13#10#13#10 + HOME_PAGE_URL, mtInformation, [mbOK], 0);
end;

procedure TfmMain.actMarketASKExecute(Sender: TObject);
var
  msg: string;
begin
  msg := dmDataProvider.mtBalance.FieldByName('coin').Text + ' - ' +
    FormatFloat('#,##0', StrToFloatDef(edtKrwValue.Text, 0)) + '원을 판매합니다.';
  if MessageDlg(msg, mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then
    Exit;

  if dmDataProvider.MarketAsk(StrToIntDef(edtKrwValue.Text, 0)) then
    MessageDlg('매도 주문 성공', mtInformation, [mbOK], 0)
  else
    MessageDlg('매도 주문 실패', mtError, [mbOK], 0)
end;

procedure TfmMain.actBalanceExecute(Sender: TObject);
begin
  dmDataProvider.Balance;
end;

procedure TfmMain.actMarketBIDExecute(Sender: TObject);
var
  msg: string;
begin
  msg := dmDataProvider.mtBalance.FieldByName('coin').Text + ' - ' +
    FormatFloat('#,##0', StrToFloatDef(edtKrwValue.Text, 0)) + '원을 구매합니다.';
  if MessageDlg(msg, mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then
    Exit;

  if dmDataProvider.MarketBid(StrToIntDef(edtKrwValue.Text, 0)) then
    MessageDlg('매수 주문 성공', mtInformation, [mbOK], 0)
  else
    MessageDlg('매수 주문 실패', mtError, [mbOK], 0)
end;

procedure TfmMain.actCancelOrderExecute(Sender: TObject);
begin
  dmDataProvider.CancelOrder;
end;

procedure TfmMain.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfmMain.actLimitASKExecute(Sender: TObject);
var
  msg: string;
begin
  msg := dmDataProvider.mtBalance.FieldByName('coin').Text + ' - ' +
    FormatFloat('#,##0', StrToFloatDef(edtLimitPrice.Text, 0)) + '원에 ' + edtLimitCount.Text +
    '개를 판매합니다.';
  if MessageDlg(msg, mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then
    Exit;

  if dmDataProvider.LimitAsk(StrToFloatDef(edtLimitPrice.Text, 0),
    StrToFloatDef(edtLimitCount.Text, 0)) then
    MessageDlg('매도 주문 성공', mtInformation, [mbOK], 0)
  else
    MessageDlg('매도 주문 실패', mtError, [mbOK], 0)
end;

procedure TfmMain.actLimitBIDExecute(Sender: TObject);
var
  msg: string;
begin
  msg := dmDataProvider.mtBalance.FieldByName('coin').Text + ' - ' +
    FormatFloat('#,##0', StrToFloatDef(edtLimitPrice.Text, 0)) + '원에 ' + edtLimitCount.Text +
    '개를 구매합니다.';
  if MessageDlg(msg, mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then
    Exit;

  if dmDataProvider.LimitBid(StrToFloatDef(edtLimitPrice.Text, 0),
    StrToFloatDef(edtLimitCount.Text, 0)) then
    MessageDlg('매수 주문 성공', mtInformation, [mbOK], 0)
  else
    MessageDlg('매수 주문 실패', mtError, [mbOK], 0)
end;

procedure TfmMain.actTickExecute(Sender: TObject);
begin
  dmDataProvider.Tick;
end;

procedure TfmMain.actSaveConfigExecute(Sender: TObject);
var
  ConnInfo: TConnInfo;
begin
  ConnInfo.StringValue := edtHost.Text;
  ConnInfo.IntegerValue := StrToIntDef(edtPort.Text, 80);
  TOption.Obj.ConnInfo := ConnInfo;
  TOption.Obj.UserID := edtUserID.Text;

  if edtAccessToken.Text <> 'AccessToken' then
    TOption.Obj.AccessToken := edtAccessToken.Text;

  if edtSecretKey.Text <> 'SecretKey' then
    TOption.Obj.SecretKey := edtSecretKey.Text;
end;

procedure TfmMain.actShowIniExecute(Sender: TObject);
begin
  ShellExecute(handle, 'open', PWideChar('notepad.exe'),
    PWideChar(TOption.Obj.IniFile.FileName), '', SW_SHOWNORMAL);
end;

procedure TfmMain.actShowLogExecute(Sender: TObject);
begin
  ShellExecute(handle, 'open', PWideChar('notepad.exe'), PWideChar(TGlobal.Obj.LogName), '',
    SW_SHOWNORMAL);
end;

procedure TfmMain.actStartCoreSvcExecute(Sender: TObject);
begin
  StartService(CORE_SERVICE_CODE, FOldCoreStatus, actStartCoreSvc);
end;

procedure TfmMain.actStartDataSvcExecute(Sender: TObject);
begin
  StartService(DATA_SERVICE_CODE, FOldDataStatus, actStartDataSvc);
end;

procedure TfmMain.actStopCoreSvcExecute(Sender: TObject);
begin
  StopService(CORE_SERVICE_CODE, FOldCoreStatus, actStopCoreSvc, Self.handle);
end;

procedure TfmMain.actStopDataSvcExecute(Sender: TObject);
begin
  StopService(DATA_SERVICE_CODE, FOldDataStatus, actStopDataSvc, Self.handle);
end;

procedure TfmMain.actTestMenuExecute(Sender: TObject);
begin
  MenuTest.Visible := not MenuTest.Visible;
end;

procedure TfmMain.ApplicationEventsException(Sender: TObject; E: Exception);
begin
  TGlobal.Obj.ApplicationMessage(msError, 'System Error', '%s', [E.Message]);
end;

procedure TfmMain.dbgBalanceDblClick(Sender: TObject);
begin
  dmDataProvider.LimitOrders;
  dmDataProvider.CompleteOrders(dmDataProvider.mtBalance.FieldByName('coin').AsString);

  dbgRecentOrders.ScrollBars := ssNone;
  dbgRecentOrders.ScrollBars := ssVertical;
end;

procedure TfmMain.edtLimitCountChange(Sender: TObject);
begin
  edtKrwView.Text := FormatFloat('#,##0', StrToFloatDef(edtLimitCount.Text, 0) *
    StrToFloatDef(edtLimitPrice.Text, 0));
end;

procedure TfmMain.btnAddKrwClick(Sender: TObject);
begin
  edtKrwValue.Text := (StrToIntDef(edtKrwValue.Text, 0) + (Sender as TButton).Tag *
    10000).ToString;
end;

procedure TfmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := false;
  if MessageDlg(APPLICATION_TITLE + '을(를) 종료하시겠습니까?', TMsgDlgType.mtConfirmation, mbYesNo, 0) = mrYes
  then
    TCore.Obj.Finalize;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  TGlobal.Obj.ExeName := Application.ExeName;
  TView.Obj.Add(Self);

  FOldDataStatus := ssContinuePending;
  FOldCoreStatus := ssContinuePending;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  TView.Obj.Remove(Self);
end;

procedure TfmMain.FormShow(Sender: TObject);
begin
  TCore.Obj.Initialize;
end;

procedure TfmMain.grdMainDblClick(Sender: TObject);

  procedure ResizeAxis(AChart: TDBChart; Axis: TChartAxis);
  var
    Diff, Max, Min: double;
  begin
    Axis.Automatic := true;
    AChart.Refresh;
    Max := Axis.Maximum;
    Min := Axis.Minimum;
    Diff := Max - Min;
    Axis.Automatic := false;
    Axis.Maximum := Max + Diff * 0.15;
    Axis.Minimum := Min - Diff * 0.15;
  end;

var
  StochHour: Integer;

begin
  chtMain.Title.Caption := dmDataProvider.mtTicker.FieldByName('coin').Text;

  StochHour := StrToIntDef(edtStochHour.Text, 7);
  if StochHour > 23 then
    StochHour := 23;
  edtStochHour.Text := StochHour.ToString;

  chtMain.SeriesList.ClearValues;
  chtStoch.SeriesList.ClearValues;

  dmDataProvider.ChartData(StrToIntDef(edtChartDay.Text, 2), StochHour);
  chtMain.RefreshData;
  ResizeAxis(chtMain, chtMain.LeftAxis);
  ResizeAxis(chtMain, chtMain.RightAxis);

  chtStoch.RefreshData;
  ResizeAxis(chtStoch, chtStoch.RightAxis);

  chtStoch.LeftAxis.Automatic := false;
  chtStoch.LeftAxis.Minimum := -100;
  chtStoch.LeftAxis.Maximum := chtMain.LeftAxis.Maximum;
  chtStoch.LeftAxis.Minimum := chtMain.LeftAxis.Minimum;

  chtStoch.TopAxis.Automatic := false;
  chtStoch.TopAxis.Maximum := chtStoch.BottomAxis.Maximum;
  chtStoch.TopAxis.Minimum := chtStoch.BottomAxis.Minimum;
end;

procedure TfmMain.PageControlChange(Sender: TObject);
begin
  ServiceStatusTimer.Enabled := false;

  if PageControl.ActivePageIndex = 0 then
    dmDataProvider.Tick
  else if PageControl.ActivePageIndex = 1 then
    dmDataProvider.Balance
  else if PageControl.ActivePageIndex = 2 then
    ServiceStatusTimer.Enabled := true;
end;

procedure TfmMain.Panel3Resize(Sender: TObject);
begin
  chtStoch.Height := round(Panel3.Height / 2);
end;

procedure TfmMain.Panel5Resize(Sender: TObject);
begin
  dbgRecentOrders.Width := round(Panel5.Width / 2) + 10;
  lblRecentOrder.Left := Splitter.Left;
end;

procedure TfmMain.rp_ErrorMessage(APacket: TValueList);
begin
  MessageDlg('오류 : ' + APacket.Values['Name'] + #13#10 + APacket.Values['Msg'],
    TMsgDlgType.mtError, [mbOK], 0);
end;

procedure TfmMain.rp_Init(APacket: TValueList);
var
  ClientInfo: TClientInfo;
begin
  Caption := TOption.Obj.AppName + ' ' + FileVersion(Application.ExeName);
  PageControl.ActivePageIndex := 0;

  ClientInfo := dmDataProvider.GetClientInfo;
  if (ClientInfo.Version <> FileVersion(TGlobal.Obj.ExeName)) and (ClientInfo.Url <> '') then
  begin
    if MessageDlg('-새버전 업데이트'#13#10 + ClientInfo.Version + ' 을 다운 받으시겠습니까?',
      TMsgDlgType.mtInformation, [mbOK, mbCancel], 0) = mrOk then
    begin
      ShellExecute(handle, 'open', PChar(ClientInfo.Url), nil, nil, SW_SHOWNORMAL);
      Application.Terminate;
      Exit;
    end;
  end;

  dmDataProvider.Init;
  dmDataProvider.Tick;
end;

procedure TfmMain.rp_KrwValue(APacket: TValueList);
var
  Value, rate: double;
begin
  Value := APacket.Doubles['msg'];
  StatusBar.Panels[1].Text := '평가액 : ' + FormatFloat('#,##0', Value);

  rate := (Value - dmDataProvider.YesterDayValue) / dmDataProvider.YesterDayValue * 100;
  StatusBar.Panels[2].Text := '전일대비 : ' + FormatFloat('0.00', rate);
end;

procedure TfmMain.rp_LogMessage(APacket: TValueList);
begin
  MessageDlg('알림 : ' + APacket.Values['Name'] + #13#10 + APacket.Values['Msg'],
    TMsgDlgType.mtInformation, [mbOK], 0);
end;

procedure TfmMain.rp_Terminate(APacket: TValueList);
begin
  Application.Terminate;
end;

procedure TfmMain.rp_TickStamp(APacket: TValueList);
begin
  StatusBar.Panels[0].Text := '갱신 : ' + APacket.Values['msg'];
end;

procedure TfmMain.ServiceStatusTimerTimer(Sender: TObject);
begin
  UpdateServiceStatus(DATA_SERVICE_CODE, FOldDataStatus, actStartDataSvc, actStopDataSvc,
    edtDataStatus);

  UpdateServiceStatus(CORE_SERVICE_CODE, FOldCoreStatus, actStartCoreSvc, actStopCoreSvc,
    edtCoreStatus);
end;

procedure TfmMain.tsPreferenceShow(Sender: TObject);
var
  ConnInfo: TConnInfo;
begin
  ConnInfo := TOption.Obj.ConnInfo;
  edtHost.Text := ConnInfo.StringValue;
  edtPort.Text := ConnInfo.IntegerValue.ToString;
  edtUserID.Text := TOption.Obj.UserID;

  edtAccessToken.Text := 'AccessToken';
  edtSecretKey.Text := 'SecretKey';
end;

end.
