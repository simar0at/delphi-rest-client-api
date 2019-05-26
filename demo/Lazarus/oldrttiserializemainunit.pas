unit oldrttiserializemainunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  TestClass;

type

  { TMainForm }

  TMainForm = class(TForm)
    Go: TButton;
    BottomPanel: TPanel;
    UnitView: TMemo;
    Output: TMemo;
    Splitter1: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GoClick(Sender: TObject);
  private
    FTestClass: TTestClass;
    FStringStream: TStringStream;
  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}
uses
  LResources, OldRTTIMarshal, OldRttiUnMarshal, SuperObject;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
var
  list: TList;
begin
  FTestClass := TTestClass.Create(nil);
  FTestClass.Name := 'FTestClass';
  FTestClass.Tag := 42;
  FTestClass.&self:='self';
  FTestClass.&this:='this';
  FTestClass.&type:='type';
  FTestClass._name:='_name';
  FTestClass.AddTestClass( TTestClass.Create(nil));
  FStringStream := TStringStream.Create('');
  TClass.
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FTestClass.Free;
  FStringStream.Free;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  CreateLFMFile(FTestClass, FStringStream);
  UnitView.Lines.SetText(PChar(FStringStream.DataString));
end;

procedure AddToOutput(const data: string);
begin
  MainForm.Output.Lines.Add(data);
end;

procedure TMainForm.GoClick(Sender: TObject);
var
  Convertible: ISuperObject;
begin
  Convertible := TOldRttiMarshal.ToJson(FTestClass);
  Output.Lines.SetText('');
  Output.Lines.Add(Convertible.AsJson);
end;

end.

