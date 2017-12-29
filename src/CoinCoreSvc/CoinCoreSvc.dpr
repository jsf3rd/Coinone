program CoinCoreSvc;

uses
  Vcl.SvcMgr,
  _ServiceMain in '_ServiceMain.pas' {ServiceMain: TService} ,
  cbGlobal in 'Global\cbGlobal.pas',
  cbOption in 'Global\cbOption.pas',
  Core in 'Core\Core.pas',
  Coinone in '..\common\Coinone.pas',
  Common in '..\common\Common.pas',
  _dmDataLoader in 'Core\_dmDataLoader.pas' {dmDataLoader: TDataModule} ,
  ServerMethodsClient in 'Core\ServerMethodsClient.pas';

{$R *.RES}

begin
  // Windows 2003 Server requires StartServiceCtrlDispatcher to be
  // called before CoRegisterClassObject, which can be called indirectly
  // by Application.Initialize. TServiceApplication.DelayInitialize allows
  // Application.Initialize to be called from TService.Main (after
  // StartServiceCtrlDispatcher has been called).
  //
  // Delayed initialization of the Application object may affect
  // events which then occur prior to initialization, such as
  // TService.OnCreate. It is only recommended if the ServiceApplication
  // registers a class object with OLE and is intended for use with
  // Windows 2003 Server.
  //
  // Application.DelayInitialize := True;
  //
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TServiceMain, ServiceMain);
  Application.CreateForm(TdmDataLoader, dmDataLoader);
  Application.Run;

end.
