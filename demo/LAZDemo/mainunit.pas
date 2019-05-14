unit mainunit;

{$mode objfpc}{$H+}{$M+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    Load: TButton;
    Go: TButton;
    Output: TMemo;
    procedure GoClick(Sender: TObject);
    procedure LoadClick(Sender: TObject);
  private

  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  fpjsonrtti, OldRTTIUnMarshal, OldRTTIMarshal;

const JSONData = '{ "embedded" : [{ "string" : "Hello from within!" }], "string" : "Hello World!" }';

type
  TEmbeddedTestClass = class(TCollectionItem)
  private
    __string: string;
  public
    class function NewInstance : TObject; override;
    destructor Destroy; override;
  published
    property &string: string read __string write __string;
  end;

  TEmbeddedClassArray = array of TEmbeddedTestClass;

  TTestClass = class(TPersistent)
    private
      __string: string;
      __embedded: TCollection;
    public
      constructor Create;
      destructor Destroy; override;
    published
      property &string: string read __string write __string;
      property embedded: TCollection read __embedded write __embedded;
  end;

  TTestClassArray = class(TPersistent)
    private
      __string: string;
      __embedded: TEmbeddedClassArray;
    public
      destructor Destroy; override;
      procedure AddEmbedded(AnEmbedded: TEmbeddedTestClass);
    published
      property &string: string read __string write __string;
      property embedded: TEmbeddedClassArray read __embedded write __embedded;
  end;

constructor TTestClass.Create;
begin
  __embedded := TCollection.Create(TEmbeddedTestClass);
end;

destructor TTestClass.destroy;
begin
  __embedded.Free;
end;

procedure TTestClassArray.AddEmbedded(AnEmbedded: TEmbeddedTestClass);
begin
  SetLength(__embedded, Length(__embedded) + 1);
  __embedded[Length(__embedded) - 1] := AnEmbedded;
end;

destructor TTestClassArray.destroy;
var
  i, l: Integer;
begin
  l := Length(__embedded);
  for i := 0 to l - 1 do;
    __embedded[i].Free;
  inherited;
end;

destructor TEmbeddedTestClass.Destroy;
begin
  inherited;
end;

class function TEmbeddedTestClass.NewInstance : TObject;
begin
  Result := inherited NewInstance;
end;

{ TMainForm }

procedure TMainForm.GoClick(Sender: TObject);
var
  Streamer: TJSONStreamer;
  TestClass: TTestClass;
  TestClassArray: TTestClassArray;
  json: string;
begin
  Streamer := TJSONStreamer.Create(nil);
  TestClass := TTestClass.Create;
  TestClass.__embedded.Add;
  TEmbeddedTestClass(TestClass.__embedded.Items[0]).&string := 'Hello from within!';
  TestClass.&string := 'Hello World!';
  json := Streamer.ObjectToJSONString(TestClass);
  Output.Lines.SetText(@json[1]);
  json := '';
  TestClassArray := TTestClassArray.Create;
  TestClassArray.AddEmbedded(TEmbeddedTestClass.Create(nil));
  TestClassArray.__embedded[0].&string := 'Hello from within 2!' ;
  TestClassArray.&string:= 'Hello World 2';
  json := TOldRttiMarshal.ToJson(TestClassArray).AsJSon();
  Output.Lines.SetText(@json[1]);
  TestClass.Free;
end;

procedure TMainForm.LoadClick(Sender: TObject);
var
  Parser: TJSONDeStreamer;
  TestClass: TTestClass;
  TestClassArray: TTestClassArray;
begin
  Parser := TJSONDeStreamer.Create(nil);
  TestClass := TTestClass.Create;
  Parser.JSONToObject(JSONData, TestClass);
  Output.Lines.Add(TestClass.&string);
  Output.Lines.Add(TEmbeddedTestClass(TestClass.__embedded.Items[0]).&string);
  Parser.Free;
  TestClass.Free;
  TestClassArray := TTestClassArray(TOldRttiUnMarshal.FromJson(TTestClassArray, JSONData));
  Output.Lines.Add(TestClassArray.&string);
  Output.Lines.Add(TestClassArray.__embedded[0].&string);
  TestClass.Free;
end;

initialization
  RegisterClass(TEmbeddedTestClass);

end.

