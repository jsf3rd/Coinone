unit Core;

interface

uses Classes, SysUtils, System.IOUtils, Generics.Collections, Generics.Defaults,
  System.Threading, System.DateUtils, cbGlobal, _dmDataLoader, _dmTrader;

type
  TCore = class
  private
    FIsInitialized: boolean;
    FIsfinalized: boolean;

    FTickerTask: TThread;

    FStandSec: Integer;

    constructor Create;
  public
    class function Obj: TCore;

    procedure Initialize; // TCore에서 사용하는 객체들에 대한 초기화.
    procedure Finalize; // TCore에서 사용하는 객체들에 대한 종료 처리.

    procedure Start; // 작업 시작.
  end;

implementation

uses cbOption, JdcGlobal.ClassHelper, JdcGlobal;

var
  MyObj: TCore = nil;

  { TCore }
constructor TCore.Create;
begin
  // TODO : Init Core..
  FIsInitialized := false;
  FIsfinalized := false;
end;

procedure TCore.Finalize;
begin
  if FIsfinalized then
    Exit;
  FIsfinalized := true;

  // Terminate Threads...
  FTickerTask.Terminate;
  FTickerTask.WaitFor;
  FreeAndNil(FTickerTask);

  TGlobal.Obj.Finalize;
end;

procedure TCore.Initialize;
begin
  if FIsfinalized then
    Exit;
  if FIsInitialized then
    Exit;
  FIsInitialized := true;

  TGlobal.Obj.Initialize;

  dmDataLoader.Init;
  dmTrader.Init;

  FStandSec := Random(40);

  // Create Threads...
  FTickerTask := TThread.CreateAnonymousThread(
    procedure
    var
      Immediate: boolean;
    begin

      Immediate := false;
      while not TThread.CurrentThread.CheckTerminated do
      begin
        Sleep(100);

        if Immediate or ((SecondOf(Now) = FStandSec) and (MinuteOf(Now) mod 10 = 0)) then
        begin
          try
            Immediate := false;
            dmDataLoader.OnTicker;
          except
            on E: Exception do
            begin
              Immediate := true;
              TGlobal.Obj.ApplicationMessage(msError, 'OnTicker', E.Message);
              Sleep(2000);
            end;
          end;
          Sleep(1000);
        end;
      end;
    end);
  FTickerTask.FreeOnTerminate := false;

end;

class function TCore.Obj: TCore;
begin
  if MyObj = nil then
    MyObj := TCore.Create;
  result := MyObj;
end;

procedure TCore.Start;
begin
  try
    FTickerTask.Start;
  except
    on E: Exception do
      TGlobal.Obj.ApplicationMessage(msError, 'TCoreStart', E.Message);
  end;

end;

initialization

MyObj := TCore.Create;

end.
