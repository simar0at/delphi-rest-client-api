program fpcUnitTest;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner,
  BaseTestRest, TestHelloWorld, TestOldRttiMarshal, TestOldRttiUnmarshal,
  TestRestClient, TestPeople, TestHeader, TestRequestSerialization;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

