unit BaseTestRest;

interface

uses RestClient, {$IFNDEF FPC}TestFramework, {$ELSE}fpcunit, testregistry, {$ENDIF}HttpConnection, {$IFNDEF FPC}TestExtensions, {$ENDIF}TypInfo;

{$I DelphiRest.inc}

type
  {$IFNDEF FPC}
  IBaseTestRest = interface(ITest)
  ['{519FE812-AC27-484D-9C4B-C7195E0068C4}']
    procedure SetHttpConnectionType(AHttpConnectionType: THttpConnectionType);
  end;
  {$ENDIF}

  TBaseTestSuite = class(TTestSuite)
  private
    FHttpConnectionType: THttpConnectionType;
  public
    constructor Create(ATest: TTestCaseClass; AHttpConnectionType: THttpConnectionType);
  end;

  TBaseTestRest = class(TTestCase{$IFNDEF FPC}, IBaseTestRest{$ENDIF})
  private
    FRestClient: TRestClient;
    FHttpConnectionType: THttpConnectionType;
  protected
    procedure FreeAndNilRestClient;
    procedure SetUp; override;
    procedure TearDown; override;
  public
    procedure SetHttpConnectionType(AHttpConnectionType: THttpConnectionType);

    constructor CreateWith(const ATestName: AnsiString; const ATestSuiteName: AnsiString);{$IFDEF FPC} override;{$ENDIF}

    property RestClient: TRestClient read FRestClient;

    class procedure RegisterTest;
  end;

const
  CONTEXT_PATH = 'http://localhost:8080/java-rest-server/rest/';

implementation

uses
  SysUtils;

{ TBaseTestRest }

constructor TBaseTestRest.CreateWith(const ATestName: AnsiString; const ATestSuiteName: AnsiString);
begin
  {$IFDEF FPC}
  inherited;
  {$ELSE}
  inherited Create(ATestName);
  {$ENDIF}
end;


procedure TBaseTestRest.FreeAndNilRestClient;
begin
  FreeAndNil(FRestClient);
end;

class procedure TBaseTestRest.RegisterTest;
begin
  {$IFDEF USE_INDY}
  //TestFramework.RegisterTest('Indy', TRepeatedTest.Create(TBaseTestSuite.Create(Self, hctIndy), 100));
  {$IFNDEF FPC}TestFramework.{$ELSE}testregistry.{$ENDIF}RegisterTest('Indy', TBaseTestSuite.Create(Self, hctIndy));
  {$ENDIF}
  {$IFDEF USE_WIN_HTTP}
  //TestFramework.RegisterTest('WinHTTP', TRepeatedTest.Create(TBaseTestSuite.Create(Self, hctWinHttp), 100));
  {$IFNDEF FPC}TestFramework.{$ELSE}testregistry.{$ENDIF}RegisterTest('WinHTTP', TBaseTestSuite.Create(Self, hctWinHttp));
  {$ENDIF}
  {$IFDEF USE_WIN_INET}
  //TestFramework.RegisterTest('WinInet', TRepeatedTest.Create(TBaseTestSuite.Create(Self, hctWinInet), 100));
  {$IFNDEF FPC}TestFramework.{$ELSE}testregistry.{$ENDIF}RegisterTest('WinInet', TBaseTestSuite.Create(Self, hctWinInet));
  {$ENDIF}
end;

procedure TBaseTestRest.SetHttpConnectionType(AHttpConnectionType: THttpConnectionType);
begin
  FHttpConnectionType := AHttpConnectionType;
end;

procedure TBaseTestRest.SetUp;
begin
  inherited;
  FRestClient := TRestClient.Create(nil);
// AV in Delphi XE2
  FRestClient.EnabledCompression := False;
  FRestClient.ConnectionType := FHttpConnectionType;
end;

procedure TBaseTestRest.TearDown;
begin
  FreeAndNilRestClient;
  inherited;
end;

{ TBaseTestSuite }

constructor TBaseTestSuite.Create(ATest: TTestCaseClass; AHttpConnectionType: THttpConnectionType);
var
  i: Integer;
begin
  inherited Create(ATest);
  FHttpConnectionType := AHttpConnectionType;

  {$IFNDEF FPC}
  for i := 0 to Tests.Count-1 do
  begin
    (Tests[i] as IBaseTestRest).SetHttpConnectionType(FHttpConnectionType);
  end;
  {$ELSE}
  for i := 0 to ChildTestCount-1 do
  begin
    TBaseTestRest(Test[i]).SetHttpConnectionType(FHttpConnectionType);
  end;
  {$ENDIF}
end;

end.
