unit testclass;

{$mode delphi}{$H+}{$M+}

interface

uses
  Classes, SysUtils;

type

  { TTestClass }

  TTestClass = class;

  TTestClassArray = array of TTestClass;

  TTestClass = class(TComponent)
  private
    F_self: string;
    F_this: string;
    F_type: string;
    F_name: string;
    F_listArray: array of TTestClass;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddTestClass(ATestClass: TTestClass);
  published
    property &self: string read F_self write F_self;
    property &this: string read F_this write F_this;
    property &type: string read F_type write F_type;
    property _name: string read F_name write F_name;
    property &array: TTestClassArray read F_listArray write F_listArray;
  end;

implementation

{ TTestClass }

constructor TTestClass.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TTestClass.Destroy;
begin
  inherited Destroy;
end;

procedure TTestClass.AddTestClass(ATestClass: TTestClass);
begin
  SetLength(F_listArray, Length(F_listArray) + 1);
  F_listArray[Length(F_listArray) - 1] := ATestClass;
end;

end.

