unit OldRttiUnMarshal;

interface

uses TypInfo, SuperObject, Variants, SysUtils, Math, Classes;

type
  TObjectArray = array of TObject;

  TOldRttiUnMarshal = class
  private
    function FromClass(AClassType: TClass; AJSONValue: ISuperObject): TObject;
    function FromList(AClassType: TClass; APropInfo: PPropInfo; const AJSONValue: ISuperObject): TList;overload;
    function FromList(AClassType, AItemClassType: TClass; const AJSONValue: ISuperObject): TList;overload;
    function FromArray(AItemClassType: TClass; const AJSONValue: ISuperObject): TObjectArray;
    function FromInt(APropInfo: PPropInfo; const AJSONValue: ISuperObject): Variant;
    function FromInt64(APropInfo: PPropInfo; const AJSONValue: ISuperObject): Variant;
    function FromFloat(APropInfo: PPropInfo; const AJSONValue: ISuperObject): Variant;
    function FromString(APropInfo: PPropInfo; const AJSONValue: ISuperObject): Variant;
    function FromChar(APropInfo: PPropInfo; const AJSONValue: ISuperObject): Variant;
    function FromWideChar(APropInfo: PPropInfo; const AJSONValue: ISuperObject): Variant;
  public
    class function FromJson(AClassType: TClass; const AJson: string): TObject;
    class function FromJsonArray(AClassType, AItemClassType: TClass; const AJson: string): TObject;    
  end;

implementation

uses RestJsonUtils{$IFDEF FPC}, Contnrs{$ENDIF};

type
  PDynArray = ^TDynArray;
  TDynArray = packed record
   refcount : ptrint;
   high : tdynarrayindex;
  end;

{ TOldRttiUnMarshal }

function TOldRttiUnMarshal.FromChar(APropInfo: PPropInfo; const AJSONValue: ISuperObject): Variant;
begin
  Result := Null;
  if ObjectIsType(AJSONValue, stString) and (Length(AJSONValue.AsString) = 1) then
  begin
    Result := Ord(AJSONValue.AsString[1]);
  end;
end;

function TOldRttiUnMarshal.FromClass(AClassType: TClass; AJSONValue: ISuperObject): TObject;
var
  i, l: Integer;
  vTypeInfo: PTypeInfo;
  vTypeData, vArrayTypeData: PTypeData;
  vPropList: PPropList;
  vPropInfo: PPropInfo;
  value: Variant;
  vPropName: string;
  vInt64Value: Int64;
  vObjProp: TObject;
  vObjArrayProp: TObjectArray;
  vDynArray: PDynArray;
  vObjClass: TClass;
  vPropType: {$IFNDEF FPC}PTypeInfo{$ELSE}TTypeInfo{$ENDIF};
begin
  Result := nil;

  case ObjectGetType(AJSONValue) of
    stObject: begin
                Result := AClassType.Create;
                try
                  vTypeInfo := AClassType.ClassInfo;
                  vTypeData := GetTypeData(vTypeInfo);

                  New(vPropList);
                  try
                    GetPropList(vTypeInfo, tkProperties, vPropList);

                    for i := 0 to vTypeData^.PropCount-1 do
                    begin
                      vPropInfo := vPropList^[i];
                      vPropName := String(vPropInfo^.Name);

                      value := Null;
                      vPropType := vPropInfo^.PropType^;
                      try
                        case vPropType.Kind of
                          tkMethod: ;
                          tkSet,
                          tkInteger,
                          tkEnumeration
                          {$IFDEF FPC}, tkBool{$ENDIF}: begin
                                           value := FromInt(vPropInfo, AJSONValue.O[vPropName]);
                                           if not VarIsNull(value) then
                                           begin
                                             vInt64Value := value;
                                             SetOrdProp(Result, vPropInfo, vInt64Value);
                                             value := Null;
                                           end;
                                         end;
                          tkInt64: begin
                                     value := FromInt64(vPropInfo, AJSONValue.O[vPropName]);
                                     if not VarIsNull(value) then
                                     begin
                                       vInt64Value := value;
                                       SetInt64Prop(Result, vPropInfo, vInt64Value);
                                       value := Null;
                                     end;
                                   end;
                          tkFloat: value := FromFloat(vPropInfo, AJSONValue.O[vPropName]);
                          tkChar: value := FromChar(vPropInfo, AJSONValue.O[vPropName]);
                          tkWChar: value := FromWideChar(vPropInfo, AJSONValue.O[vPropName]);
                          tkString, tkLString,
                          {$IFDEF UNICODE}
                          tkUString,
                          {$ENDIF}
                          tkWString{$IFDEF FPC}, tkAString{$ENDIF}: value := FromString(vPropInfo, AJSONValue.O[vPropName]);
                          tkClass: begin
                                      value := Null;

                                      vObjClass := GetObjectPropClass(Result, {$IFNDEF FPC}vPropInfo{$ELSE}vPropName{$ENDIF});

                                      if vObjClass.InheritsFrom(TList) then
                                      begin
                                        vObjProp := FromList(vObjClass, vPropInfo, AJSONValue.O[vPropName])
                                      end
                                      else
                                      begin
                                        vObjProp := FromClass(vObjClass, AJSONValue.O[vPropName]);
                                      end;

                                      if Assigned(vObjProp) then
                                      begin
                                        SetObjectProp(Result, vPropInfo, vObjProp);
                                      end;
                                   end;
                          tkDynArray: begin
                                        vArrayTypeData := GetTypeData(GetTypeData(@vPropType).elType2);
                                        vObjArrayProp := FromArray(vArrayTypeData^.ClassType, AJSONValue.O[vPropName]);
                                        if (Length(vObjArrayProp) > 0) then
                                        begin
                                          vDynArray:=Pointer(@vObjArrayProp[0])-sizeof(TDynArray);
                                          InterLockedIncrement(vDynArray^.refcount);
                                          {$ifdef cpu64}
                                          SetInt64Prop(Result,vPropInfo,Int64(vObjArrayProp));
                                          {$else cpu64}
                                          SetOrdProp(Result,vPropInfo,PtrInt(vObjArrayProp));
                                          {$endif cpu64}
                                        end;
                                      end;
                        end;
                      except
                        on E: Exception do
                        begin
                          raise EJsonInvalidValueForField.CreateFmt('UnMarshalling error for field "%s.%s" : %s',
                                                                    [Result.ClassName, vPropName, E.Message]);
                        end;
                      end;

                      if not VarIsNull(value) then
                      begin
                        SetPropValue(Result, vPropName, value);
                      end;
                    end;
                  finally
                    Dispose(vPropList);
                  end;
                  except
                  Result.Free;
                  raise;
                end;
              end;
    stArray: begin
               Result := FromList(AClassType, PPropInfo(nil), AJSONValue);
             end;
  end;
end;

function TOldRttiUnMarshal.FromFloat(APropInfo: PPropInfo;const AJSONValue: ISuperObject): Variant;
var
  o: ISuperObject;
begin
  Result := Null;
  case ObjectGetType(AJSONValue) of
    stInt, stDouble, stCurrency:
      begin
        if Pointer(APropInfo^.PropType) = System.TypeInfo(TDateTime) then
        begin
          Result := JavaToDelphiDateTime(AJSONValue.AsInteger);
        end
        else
        begin
          case GetTypeData(APropInfo^.PropType{$IFNDEF FPC}^{$ENDIF})^.FloatType of
            ftSingle: Result := AJSONValue.AsDouble;
            ftDouble: Result := AJSONValue.AsDouble;
            ftExtended: Result := AJSONValue.AsDouble;
            ftCurr: Result := AJSONValue.AsCurrency;
          end;
        end;
      end;
    stString:
      begin
        o := SO(AJSONValue.AsString);
        if not ObjectIsType(o, stString) then
        begin
          Result := FromFloat(APropInfo, o);
        end;
      end
  end;
end;

function TOldRttiUnMarshal.FromInt(APropInfo: PPropInfo; const AJSONValue: ISuperObject): Variant;
var
   o: ISuperObject;
begin
  Result := Null;
  case ObjectGetType(AJSONValue) of
    stInt, stBoolean:
      begin
        Result := AJSONValue.AsInteger;
      end;
    stString:
      begin
        o := SO(AJSONValue.AsString);
        if not ObjectIsType(o, stString) then
        begin
          Result := FromInt(APropInfo, o);
        end;
      end;
  end;
end;

function TOldRttiUnMarshal.FromInt64(APropInfo: PPropInfo;const AJSONValue: ISuperObject): Variant;
var
  i: Int64;
begin
  Result := Null;
  case ObjectGetType(AJSONValue) of
    stInt:
      begin
        Result := AJSONValue.AsInteger;
      end;
    stString:
      begin
        if TryStrToInt64(AJSONValue.AsString, i) then
        begin
          Result := i;
        end;
      end;
  end;
end;

class function TOldRttiUnMarshal.FromJson(AClassType: TClass;const AJson: string): TObject;
var
  vUnMarshal: TOldRttiUnMarshal;
  vJsonObject: ISuperObject;
begin
  Result := nil;

  vUnMarshal := TOldRttiUnMarshal.Create;
  try
    vJsonObject := SO(AJson);

    if vJsonObject = nil then
      raise EJsonInvalidSyntax.CreateFmt('Invalid json: "%s"', [AJson]);

    Result := vUnMarshal.FromClass(AClassType, vJsonObject);
  finally
    vUnMarshal.Free;
  end;
end;

class function TOldRttiUnMarshal.FromJsonArray(AClassType, AItemClassType: TClass; const AJson: string): TObject;
var
  vUnMarshal: TOldRttiUnMarshal;
  vJsonObject: ISuperObject;
begin
  Result := nil;

  vUnMarshal := TOldRttiUnMarshal.Create;
  try
    vJsonObject := SO(AJson);

    if vJsonObject = nil then
      raise EJsonInvalidSyntax.CreateFmt('Invalid json: "%s"', [AJson]);

    Result := vUnMarshal.FromList(AClassType, AItemClassType, vJsonObject);
  finally
    vUnMarshal.Free;
  end;
end;

function TOldRttiUnMarshal.FromList(AClassType: TClass; APropInfo: PPropInfo; const AJSONValue: ISuperObject): TList;
var
  vPosList: Integer;
  vItemClassName: String;
  vItemClass: TClass;
begin
  Result := nil;
  if ObjectIsType(AJSONValue, stArray) then
  begin
    if AClassType.InheritsFrom(TList) and (AJSONValue.AsArray.Length > 0) then
    begin
      vItemClassName := '';
      if Assigned(APropInfo) and (vItemClassName = '') then
      begin
        vPosList := Pos('ObjectList', String(APropInfo^.Name));
        if (vPosList = 0) then
        begin
          vPosList := Pos('List', String(APropInfo^.Name));
        end;

        vItemClassName := 'T' + Copy(String(APropInfo^.Name), 1, vPosList-1);
      end;

      vItemClass := FindClass(vItemClassName);

      Result :=  FromList(AClassType, vItemClass, AJSONValue);
    end;
  end;
end;

function TOldRttiUnMarshal.FromList(AClassType, AItemClassType: TClass;const AJSONValue: ISuperObject): TList;
var
  i: Integer;
  vItem: TObject;
begin
  Result := nil;
  if ObjectIsType(AJSONValue, stArray) then
  begin
    if AClassType.InheritsFrom(TList) and (AJSONValue.AsArray.Length > 0) then
    begin
      {$IFNDEF FPC}
      Result := TList(AClassType.Create)
      {$ELSE}
      if AClassType.InheritsFrom(TObjectList) then Result := TObjectList.Create
      else Result := TList.Create
      {$ENDIF};
      try
        for i := 0 to AJSONValue.AsArray.Length-1 do
        begin
          vItem := FromClass(AItemClassType, AJSONValue.AsArray.O[i]);

          Result.Add(vItem);
        end;
      except
        Result.Free;
        raise;
      end;
    end;
  end;
end;

function TOldRttiUnMarshal.FromArray(AItemClassType: TClass; const AJSONValue: ISuperObject): TObjectArray;
var
  i: Integer;
  vItem: TObject;
begin
  SetLength(Result, 0);
  if ObjectIsType(AJSONValue, stArray) then
  begin
    if (AJSONValue.AsArray.Length > 0) then
    begin
      try
        for i := 0 to AJSONValue.AsArray.Length-1 do
        begin
          vItem := FromClass(AItemClassType, AJSONValue.AsArray.O[i]);
          SetLength(Result, Length(Result) + 1);
          Result[Length(Result) - 1] := vItem;
        end;
      except
        for i := 0 to Length(Result) - 1 do
          Result[i].Free;
        SetLength(Result, 0);
        raise;
      end;
    end;
  end;
end;

function TOldRttiUnMarshal.FromString(APropInfo: PPropInfo;const AJSONValue: ISuperObject): Variant;
begin
  case ObjectGetType(AJSONValue) of
    stNull: Result := '';
    stString: Result := AJSONValue.AsString;
  else
    raise EJsonInvalidValue.CreateFmt('Invalid value "%s".', [AJSONValue.AsJSon]);
  end;
end;

function TOldRttiUnMarshal.FromWideChar(APropInfo: PPropInfo;const AJSONValue: ISuperObject): Variant;
begin
  Result := Null;
  if ObjectIsType(AJSONValue, stString) and (Length(AJSONValue.AsString) = 1) then
  begin
    Result := Ord(AJSONValue.AsString[1]);
  end;
end;

end.
