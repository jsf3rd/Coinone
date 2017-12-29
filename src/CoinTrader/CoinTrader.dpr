program CoinTrader;

uses
  Vcl.Forms,
  _fmMain in 'View\_fmMain.pas' {fmMain},
  Core in 'Core\Core.pas',
  ctGlobal in 'Global\ctGlobal.pas',
  ctOption in 'Global\ctOption.pas',
  Coinone in '..\common\Coinone.pas',
  Common in '..\common\Common.pas';

{$R *.res}

begin
  {
    // 중복 실행을 막으려면 활성화 하시오.
    if not JclAppInstances.CheckInstance(1) then
    begin
    MessageBox(0, '프로그램이 이미 실행중입니다.', '확인', MB_ICONEXCLAMATION);
    JclAppInstances.SwitchTo(0);
    JclAppInstances.KillInstance;
    end;
  }

  Application.Initialize;
  Application.Title := APPLICATION_TITLE;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;

end.
