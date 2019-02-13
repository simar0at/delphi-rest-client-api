unit TestHelloWorld;

interface

uses BaseTestRest;

type
  TTestHelloWorld = class(TBaseTestRest)
  private
  published
    procedure GET_HelloWorldAsXml;
    procedure GET_HelloWorldAsJson;
  end;

implementation

{ TTestHelloWorld }

procedure TTestHelloWorld.GET_HelloWorldAsJson;
const
  ExpectedJson = '{"msg":"Olá Mundo!"}';
var
  vResponse: string;
begin
  vResponse := RestClient.Resource(CONTEXT_PATH + 'helloworld')
                         .Accept('application/json')
                         .GET();

  CheckEquals(ExpectedJson, vResponse);
end;

procedure TTestHelloWorld.GET_HelloWorldAsXml;
const
  ExpectedXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><helloWorld><msg>Olá Mundo!</msg></helloWorld>';
var
  vResponse: string;
begin
  vResponse := RestClient.Resource(CONTEXT_PATH + 'helloworld')
                         .Accept('text/xml')
                         .GET();

  CheckEquals(ExpectedXml, vResponse);
end;

initialization
  TTestHelloWorld.RegisterTest;

end.
