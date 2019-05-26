{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit LazRestApi;

{$warn 5023 off : no warning about unused units}
interface

uses
  RestClient, RestUtils, superobject, superxmlparser, RestJsonUtils, 
  RestJsonOldRTTI, DataSetUtils, RestRegister, Wcrypt2, OldRttiMarshal, 
  OldRttiUnMarshal, HttpConnectionFactory, HttpConnection, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('RestRegister', @RestRegister.Register);
end;

initialization
  RegisterPackage('LazRestApi', @Register);
end.
