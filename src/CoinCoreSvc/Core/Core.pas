unit Core;

interface

uses Classes, SysUtils, System.IOUtils, Generics.Collections, Generics.Defaults,
  System.Threading, System.DateUtils, cbGlobal, _dmDataLoader;

type
  TCore = class
  private
    FIsInitialized: boolean;
    FIsfinalized: boolean;

    FTickerTask: TThread;

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

  // const
  // Coins: array [0 .. 8] of string = ();

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

  // Create Threads...
  FTickerTask := TThread.CreateAnonymousThread(
    procedure
    begin
      while not TThread.CurrentThread.CheckTerminated do
      begin
        Sleep(100);

        if Secondof(Now) = 0 then
        begin
          try
            dmDataLoader.Tick;
          except
            on E: Exception do
              TGlobal.Obj.ApplicationMessage(msError, 'Tick', E.Message);
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
  FTickerTask.Start;
end;

initialization

MyObj := TCore.Create;

end.
