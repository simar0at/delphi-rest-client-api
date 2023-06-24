unit commontestbase;

{$mode ObjFPC}{$H+}

interface

uses
  FPCUnit, Classes, SysUtils;

var
  TestRoot : String;

type
  { TCommonTestSuiteCase }
  TCommonTestSuiteCase = class (TTestCase)
  protected
    FName : String;
    function GetTestName: string; override;
  public
    constructor Create(name : String);
    procedure TestCase(name : String); virtual;
  published
    procedure Test;
  end;

  { TCommonTestSuite }
  TCommonTestSuite = class (TTestSuite)
  public
    constructor Create; override;
    procedure Run(AResult: TTestResult); override;
    procedure RunTest(ATest: TTest; AResult: TTestResult); override;
    procedure SetUp; virtual;
    procedure SetUpEach; virtual;
    procedure TearDownEach; virtual;
    procedure TearDown; virtual;
  end;

function getCommandLineParam(name : String; var res : String) : boolean;

implementation

{ TCommonTestSuite }

constructor TCommonTestSuite.Create;
begin
  inherited Create;
end;

procedure TCommonTestSuite.Run(AResult: TTestResult);
begin
  SetUp;
  inherited Run(AResult);
  TearDown;
end;

procedure TCommonTestSuite.RunTest(ATest: TTest; AResult: TTestResult);
begin
  SetUpEach;
  inherited RunTest(ATest, AResult);
  TearDownEach;
end;

procedure TCommonTestSuite.SetUp;
begin

end;

procedure TCommonTestSuite.SetUpEach;
begin

end;

procedure TCommonTestSuite.TearDownEach;
begin

end;

procedure TCommonTestSuite.TearDown;
begin

end;

{ TCommonTestSuiteCase }

function TCommonTestSuiteCase.GetTestName: string;
begin
  Result := FName;
end;

constructor TCommonTestSuiteCase.Create(name: String);
begin
  inherited CreateWith('Test', name);

  FName := name;
end;

procedure TCommonTestSuiteCase.TestCase(name: String);
begin
  Fail('Override the base class method!')
end;

procedure TCommonTestSuiteCase.Test;
begin
  TestCase(FName);
end;

function getCommandLineParam(name : String; var res : String) : boolean;
var
  i : integer;
begin
  result := false;
  for i := 1 to paramCount - 1 do
  begin
    if paramStr(i) = '-'+name then
    begin
      res := paramStr(i+1);
      exit(true);
    end;
  end;
end;

end.

