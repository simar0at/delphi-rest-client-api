program UnitTest;

{$mode objfpc}{$H+}

uses
  {$IFDEF MSWINDOWS} Windows, {$ENDIF}
  {$IFDEF UNIX} cthreads, {$ENDIF}
  SysUtils, Interfaces, Forms, idetester_console, idetester_form,
  idetester_runtime, extctrls, testregistry, idetester_console_gui,
  commontestbase, TestHeader, TestHelloWorld, TestOldRttiMarshal,
  TestOldRttiUnmarshal, TestPeople, TestRegister, TestRequestSerialization,
  TestResponseHandler, TestRestClient, TestRestUtils, TestSerializer;

type

  { TTestStarter }

  TTestStarter = class
    procedure doStartTests(Sender: TObject);
    procedure doStartTestsIDE(Sender: TObject);
  end;

{$R *.res}

var
  testApp : TIdeTesterConsoleRunner;
  startTests: TTimer;
  testStarter: TTestStarter;

procedure RegisterTests;
begin
  if not getCommandLineParam('testRoot', TestRoot) then
    TestRoot := getCurrentDir;
  //.RegisterTests;
  //.RegisterTests;
end;

{ TTestStarter }

procedure TTestStarter.doStartTests(Sender: TObject);
begin
  startTests.Enabled := False;
  testApp.Flags := testApp.Flags+[AppDestroying];
  testApp.DoTestRun(GetTestRegistry);
  testApp.Terminate;
  {$ifdef LCLCOCOA}
  // Cocoa Application.Terminate is a NOOP
  Halt(0);
  {$endif}
end;

procedure TTestStarter.doStartTestsIDE(Sender: TObject);
begin
  startTests.Enabled := False;
  Application.Flags := Application.Flags+[AppDestroying];
  RunIDETestsCmdLine;
  Application.Terminate;
  {$ifdef LCLCOCOA}
  // Cocoa Application.Terminate is a NOOP
  Halt(0);
  {$endif}
end;

begin
  {$if Declared(UseHeapTrace)}
  if FileExists('heap.trc') then
    DeleteFile('heap.trc');
  SetHeapTraceOutput('heap.trc');
  GlobalSkipIfNoLeaks := True;
  {$ifend}
  startTests := nil;
  testStarter := nil;
  RegisterTests;
  if (ParamStr(1) = '-ci') then
  begin
    testApp := TIdeTesterConsoleRunner.Create(nil);
    testApp.Initialize;
    testApp.Title := 'GUI Demo Tests';
    startTests := TTimer.Create(nil);
    testStarter := TTestStarter.Create;
    startTests.OnTimer := @testStarter.doStartTests;
    startTests.Interval := 200;
    startTests.Enabled := true;
    testApp.Run;
    if Assigned(startTests) then startTests.Free;
    if Assigned(testStarter) then testStarter.Free;
    testApp.Free;
  end
  else
  begin
  Application.Scaled:=True;
    Application.Initialize;
    if IsRunningIDETests then
    begin
      startTests := TTimer.Create(nil);
      testStarter := TTestStarter.Create;
      startTests.OnTimer := @testStarter.doStartTestsIDE;
      startTests.Interval := 200;
      startTests.Enabled := true;
    end
    else begin
      {$IFDEF MSWINDOWS} FreeConsole; {$ENDIF}
      Application.CreateForm(TIdeTesterForm, IdeTesterForm);
      IdeTesterForm.caption := 'GUI Demo Tests';
      {$IFDEF LINUX} IdeTesterForm.setThreadModeMainThread; {$ENDIF}
    end;
    Application.Run;
    if Assigned(startTests) then startTests.Free;
    if Assigned(testStarter) then testStarter.Free;
    Application.Free;
  end;
end.

