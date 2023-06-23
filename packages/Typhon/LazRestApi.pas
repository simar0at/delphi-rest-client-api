{ This file was automatically created by Typhon IDE. Do not edit!
  This source is only used to compile and install the package.
 }

unit LazRestApi;

{$warn 5023 off : no warning about unused units}
interface

uses
  RestClient, RestUtils, superobject, superxmlparser, RestJsonUtils, 
  RestJsonOldRTTI, DataSetUtils, RestRegister, OldRttiMarshal, 
  OldRttiUnMarshal, HttpConnectionFactory, HttpConnection, TyphonPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('RestRegister', @RestRegister.Register);
end;

initialization
  RegisterPackage('LazRestApi', @Register);
end.
