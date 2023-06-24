unit BaseTestRest;

interface

uses RestClient, {$IFNDEF FPC}DUnitX.TestFramework,DUnitX.DUnitCompatibility,Classes,{$ELSE}fpcunit, testregistry, {$ENDIF}HttpConnection, TypInfo;

{$I DelphiRest.inc}

type
  {$IFNDEF FPC}
  TTestCaseClass = class of TTestCase;
  IBaseTestRest = interface
  ['{519FE812-AC27-484D-9C4B-C7195E0068C4}']
    procedure SetHttpConnectionType(AHttpConnectionType: THttpConnectionType);
  end;

  TTestSuite = class
  private
    FTests: TInterfaceList;
  public
    property Tests: TInterfaceList read FTests;
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
  {$IFNDEF FPC}
  {$IFNDEF AUTOREFCOUNT}
    [Volatile] FRefCount: Integer;
  {$ENDIF}
  {$ENDIF}
    FRestClient: TRestClient;
    FHttpConnectionType: THttpConnectionType;
  protected
    procedure FreeAndNilRestClient;
    procedure SetUp; override;
    procedure TearDown; override;
  public
    procedure SetHttpConnectionType(AHttpConnectionType: THttpConnectionType);

    constructor CreateWith(const ATestName: AnsiString; const ATestSuiteName: AnsiString);{$IFDEF FPC} override;{$ENDIF}
  {$IFNDEF FPC}
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    procedure Fail(const msg: string);
  {$ENDIF}
    property RestClient: TRestClient read FRestClient;

    class procedure RegisterTest;
  end;

const
  CONTEXT_PATH = 'http://localhost:8080/java-rest-server/rest/';

implementation

uses
  SysUtils
  {$IFDEF WINDOWS}, ActiveX{$ENDIF};

{ TBaseTestRest }

constructor TBaseTestRest.CreateWith(const ATestName: AnsiString; const ATestSuiteName: AnsiString);
begin
  inherited;
end;

procedure TBaseTestRest.FreeAndNilRestClient;
begin
  FreeAndNil(FRestClient);
end;

class procedure TBaseTestRest.RegisterTest;
begin
  {$IFDEF USE_INDY}
  //TestFramework.RegisterTest('Indy', TRepeatedTest.Create(TBaseTestSuite.Create(Self, hctIndy), 100));
  {$IFDEF FPC}testregistry.RegisterTest('Indy', TBaseTestSuite.Create(Self, hctIndy));{$ENDIF}
  {$ENDIF}
  {$IFDEF USE_WIN_HTTP}
  CoInitializeEx(nil,COINIT_MULTITHREADED);
  //TestFramework.RegisterTest('WinHTTP', TRepeatedTest.Create(TBaseTestSuite.Create(Self, hctWinHttp), 100));
  {$IFDEF FPC}testregistry.RegisterTest('WinHTTP', TBaseTestSuite.Create(Self, hctWinHttp));{$ENDIF}
  {$ENDIF}
  {$IFDEF USE_WIN_INET}
  //TestFramework.RegisterTest('WinInet', TRepeatedTest.Create(TBaseTestSuite.Create(Self, hctWinInet), 100));
  {$IFDEF FPC}testregistry.RegisterTest('WinInet', TBaseTestSuite.Create(Self, hctWinInet));{$ENDIF}
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

{$IFNDEF FPC}
function TBaseTestRest.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TBaseTestRest._AddRef: Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  Result := AtomicIncrement(FRefCount);
{$ELSE}
  Result := __ObjAddRef;
{$ENDIF}
end;

function TBaseTestRest._Release: Integer;
begin
{$IFNDEF AUTOREFCOUNT}
  Result := AtomicDecrement(FRefCount);
  if Result = 0 then
  begin
    Destroy;
  end;
{$ELSE}
  Result := __ObjRelease;
{$ENDIF}
end;

procedure TBaseTestRest.Fail(const msg: string);
begin
  Check(False, msg);
end;
{$ENDIF}

{ TBaseTestSuite }

constructor TBaseTestSuite.Create(ATest: TTestCaseClass; AHttpConnectionType: THttpConnectionType);
var
  i: Integer;
begin
  inherited Create{$IFDEF FPC}(ATest){$ENDIF};
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
