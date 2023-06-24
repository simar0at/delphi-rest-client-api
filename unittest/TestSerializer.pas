unit TestSerializer;

interface

uses BaseTestRest, Generics.Collections, SuperObject, ContNrs, Classes, SysUtils;

type
  TPhone = class(TObject)
  public
    _number: Int64;
    _code: Integer;
  published
    property number: Int64 read _number write _number;
    property code: Integer read _code write _code;
  end;

  TPhoneArray = array of TPhone;

  TPerson = class(TObject)
  private
    _age: Integer;
    _name: String;
    _father: TPerson;
    _phones : TPhoneArray;
  public
    function ToString: string; override;
    destructor Destroy; override;
  published
    property age: Integer read _age write _age;
    property name: string read _name write _name;
    property father: TPerson read _father write _father;
    property phones: TPhoneArray read _phones write _phones;
  end;
  
  TTestDesserializer = class(TBaseTestRest)
  published
    procedure person;
    procedure personWithFather;
    procedure personWithFatherAndPhones;
  end;

  TTestSerializer = class(TBaseTestRest)
  published
    procedure person;
  end;

implementation

uses RestJsonUtils;

{ TTestDesserializer }

procedure TTestDesserializer.personWithFather;
const
  sJson = '{' +
          '    "name": "Helbert",' +
          '    "age": 30,' +
          '    "father": {' +
          '        "name": "Luiz",' +
          '        "age": 60,' +
          '        "father": null,' +
          '        "phones": null' +
          '    }' +
          '}';
var
  vPerson: TPerson;
begin
  vPerson := TPerson(TJsonUtil.UnMarshal(TPerson, sJson));
  try
    CheckNotNull(vPerson);
    CheckEquals('Helbert', vPerson.name);
    CheckEquals(30, vPerson.age);

    CheckNotNull(vPerson.father);
    CheckEquals('Luiz', vPerson.father.name);
    CheckEquals(60, vPerson.father.age);
  finally
    vPerson.Free;
  end;
end;

procedure TTestDesserializer.personWithFatherAndPhones;
const
  sJson = '{' +
          '    "name": "Helbert",' +
          '    "age": 30,' +
          '    "father": {' +
          '        "name": "Luiz",' +
          '        "age": 60,' +
          '        "father": null,' +
          '        "phones": null' +
          '    },' +
          '    "phones": [' +
          '        {' +
          '            "number": 33083518,' +
          '            "code": 61' +
          '        },' +
          '        {' +
          '            "number": 99744165,' +
          '            "code": 61' +
          '        }' +
          '    ]' +
          '}';
var
  vPerson: TPerson;
begin
  vPerson := TPerson(TJsonUtil.UnMarshal(TPerson, sJson));
  try
    CheckNotNull(vPerson);
    CheckEquals('Helbert', vPerson.name);
    CheckEquals(30, vPerson.age);

    CheckNotNull(vPerson.father);
    CheckEquals('Luiz', vPerson.father.name);
    CheckEquals(60, vPerson.father.age);

    CheckEquals(2, Length(vPerson.phones));
    CheckEquals(33083518, vPerson.phones[0].number);
    CheckEquals(61, vPerson.phones[0].code);

    CheckEquals(99744165, vPerson.phones[1].number);
    CheckEquals(61, vPerson.phones[1].code);
  finally
    vPerson.Free;
  end;
end;

procedure TTestDesserializer.person;
const
  sJson = '{' +
          '    "name": "Helbert",' +
          '    "age": 30' +
          '}';
var
  vPerson: TPerson;
begin
  vPerson := TPerson(TJsonUtil.UnMarshal(TPerson, sJson));
  try
    CheckNotNull(vPerson);
    CheckEquals('Helbert', vPerson.name);
    CheckEquals(30, vPerson.age);
  finally
    vPerson.Free;
  end;
end;

{ TTestSerializer }

procedure TTestSerializer.person;
const
  sJson = '{"age":30,"name":"Helbert"}';
var
  vPerson: TPerson;
begin
  vPerson := TPerson.Create;
  try
    vPerson.name := 'Helbert';
    vPerson.age := 30;

    CheckEquals(sJson, TJsonUtil.Marshal(vPerson));
  finally
    vPerson.Free;
  end;
end;

{ TPerson }

destructor TPerson.Destroy;
var
  phone: TPhone;
begin
  if Assigned(_phones) then
    for phone in _phones do phone.Free;
  SetLength(_phones, 0);
  father.Free;
  inherited;
end;

function TPerson.ToString: string;
begin
  Result := 'name:' + name + ' age:' + IntToStr(age);
end;

initialization
  TTestDesserializer.RegisterTest;
  TTestSerializer.RegisterTest;

end.
