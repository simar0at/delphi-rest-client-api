unit TestRestUtils;

interface

uses {$IFNDEF FPC}DUnitX.TestFramework, DUnitX.DUnitCompatibility, {$ELSE}fpcunit, testregistry {$ENDIF};

type
  TTestRestUtils = class(TTestCase)
  published
    procedure TestBase64Encode;
    procedure TestBase64Decode;
  end;

implementation

uses
  RestUtils;

{ TTestRestUtils }

procedure TTestRestUtils.TestBase64Decode;
begin
  CheckEquals('dXNlcjpwYXNzd29yZA==', TRestUtils.Base64Encode('user:password'));
end;

procedure TTestRestUtils.TestBase64Encode;
begin
  CheckEquals('user:password', TRestUtils.Base64Decode('dXNlcjpwYXNzd29yZA=='));
end;

initialization
  RegisterTest(TTestRestUtils{$IFNDEF FPC}.Suite{$ENDIF});

end.
