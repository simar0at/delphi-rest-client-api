program UnitTest;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ENDIF }
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  TestHelloWorld in 'TestHelloWorld.pas',
  TestPeople in 'TestPeople.pas',
  BaseTestRest in 'BaseTestRest.pas',
  TestHeader in 'TestHeader.pas',
  TestResponseHandler in 'TestResponseHandler.pas',
  Person in 'Person.pas',
  DataSetUtils in '..\src\DataSetUtils.pas',
  RestClient in '..\src\RestClient.pas',
  HttpConnection in '..\src\HttpConnection.pas',
  HttpConnectionFactory in '..\src\HttpConnectionFactory.pas',
  WinHttp_TLB in '..\lib\WinHttp_TLB.pas',
  TestRegister in 'TestRegister.pas',
  TestRestClient in 'TestRestClient.pas',
  Wcrypt2 in '..\lib\Wcrypt2.pas',
  TestOldRttiMarshal in 'TestOldRttiMarshal.pas',
  OldRttiMarshal in '..\src\OldRttiMarshal.pas',
  TestOldRttiUnmarshal in 'TestOldRttiUnmarshal.pas',
  OldRttiUnMarshal in '..\src\OldRttiUnMarshal.pas',
  JsonListAdapter in '..\src\JsonListAdapter.pas',
  TestDbxJsonUnMarshal in 'TestDbxJsonUnMarshal.pas',
  DbxJsonUnMarshal in '..\src\DbxJsonUnMarshal.pas',
  TestDBXJsonUtils in 'TestDBXJsonUtils.pas',
  TestDbxJsonMarshal in 'TestDbxJsonMarshal.pas',
  TestRestUtils in 'TestRestUtils.pas',
  TestSuperobject in 'TestSuperobject.pas',
  RestException in '..\src\RestException.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  exit;
{$ENDIF}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //tell the runner how we will log things
    //Log to the console window
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);
    runner.FailsOnNoAsserts := False; //When true, Assertions must be made during tests;

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
