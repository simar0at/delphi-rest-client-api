unit TestResponseHandler;

interface

{$I DelphiRest.inc}

uses BaseTestRest, Classes;

type
  TTestResponseHandler = class(TBaseTestRest)
  private
    FResponse: String;

    procedure HandleResponse(ResponseContent: TStream);
  published
    {$IFDEF SUPPORTS_ANONYMOUS_METHODS}
    procedure TestResponseHandlerAnonymous;
    {$ENDIF}
    procedure TestResponseHandler;
  end;

implementation

uses SysUtils;

{ TTestResponseHandler }

{$IFDEF SUPPORTS_ANONYMOUS_METHODS}
procedure TTestResponseHandler.TestResponseHandlerAnonymous;
var
  vStringStream: TStringStream;
  vResponse: String;
begin
  RestClient.Resource(CONTEXT_PATH + 'helloworld')
            .Accept('application/json')
            .GET(procedure(ResponseContent: TStream)
                 begin
                   vStringStream := TStringStream.Create('');
                   try
                     ResponseContent.Position := 0;

                     vStringStream.CopyFrom(ResponseContent, ResponseContent.Size);

                    {$IFDEF UNICODE}
                      vResponse :=  UTF8ToWideString(RawByteString(vStringStream.DataString));
                    {$ELSE}
                      vResponse :=  UTF8Decode(vStringStream.DataString);
                    {$ENDIF}
                   finally
                     vStringStream.Free;
                   end;
                 end);

  CheckEqualsString('{"msg":"Olá Mundo!"}', vResponse);
end;
{$ENDIF}

procedure TTestResponseHandler.HandleResponse(ResponseContent: TStream);
var
  vStringStream: TStringStream;
  s: string;
begin
  vStringStream := TStringStream.Create('');
  try
    ResponseContent.Position := 0;

    vStringStream.CopyFrom(ResponseContent, ResponseContent.Size);

    {$IFDEF UNICODE}
      FResponse :=  UTF8ToWideString(RawByteString(vStringStream.DataString));
    {$ELSE}
      s := vStringStream.DataString;
      s := UTF8Decode(s);
      FResponse := s;
    {$ENDIF}
  finally
    vStringStream.Free;
  end;
end;

procedure TTestResponseHandler.TestResponseHandler;
begin
  FResponse := EmptyStr;

  RestClient.Resource(CONTEXT_PATH + 'helloworld')
            .Accept('application/json')
            .GET({$IFDEF FPC}@{$ENDIF}HandleResponse);

  CheckEquals(UTF8Encode('{"msg":"Olá Mundo!"}'), FResponse);
end;

initialization
  TTestResponseHandler.RegisterTest;

end.
