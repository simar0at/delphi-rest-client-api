{******************************************************************************}
{                                                                              }
{            Indy (Internet Direct) - Internet Protocols Simplified            }
{                                                                              }
{            https://www.indyproject.org/                                      }
{            https://gitter.im/IndySockets/Indy                                }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  This file is part of the Indy (Internet Direct) project, and is offered     }
{  under the dual-licensing agreement described on the Indy website.           }
{  (https://www.indyproject.org/license/)                                      }
{                                                                              }
{  Copyright:                                                                  }
{   (c) 1993-2020, Chad Z. Hower and the Indy Pit Crew. All rights reserved.   }
{                                                                              }
{******************************************************************************}
{                                                                              }
{        Originally written by: Fabian S. Biehn                                }
{                               fbiehn@aagon.com (German & English)            }
{                                                                              }
{        Contributers:                                                         }
{                               Christopher Wagner                             }
{                               cwagner@aagon.com (German & English)           }
{                                                                              }
{******************************************************************************}

unit IdOpenSSLSocketClient;

interface

{$i IdCompilerDefines.inc}

uses
  IdOpenSSLHeaders_ossl_typ,
  IdOpenSSLSocket,
  IdStackConsts;

type
  TIdOpenSSLSocketClient = class(TIdOpenSSLSocket)
  private
    FSession: Pointer;
  public
    function Connect(
      const AHandle: TIdStackSocketHandle;
      const ASNIHostname: string = '';
      const AVerifyHostName: Boolean = True): Boolean;
    procedure SetSession(const ASession: Pointer);
  end;

implementation

uses
  IdCTypes,
  IdGlobal,
  IdOpenSSLExceptionResourcestrings,
  IdOpenSSLExceptions,
  IdOpenSSLHeaders_ssl,
  IdOpenSSLHeaders_tls1,
  IdOpenSSLHeaders_x509_vfy,
  IdOpenSSLUtils;

{ TIdOpenSSLSocketClient }

function TIdOpenSSLSocketClient.Connect(
  const AHandle: TIdStackSocketHandle;
  const ASNIHostname: string;
  const AVerifyHostName: Boolean): Boolean;
var
  LReturnCode: TIdC_INT;
  LShouldRetry: Boolean;
begin
  FSSL := StartSSL(FContext);
  SSL_set_fd(FSSL, AHandle);
  if ASNIHostname <> '' then
  begin
    if SSL_set_tlsext_host_name(FSSL, GetPAnsiChar(UTF8String(ASNIHostname))) <> 1 then
      EIdOpenSSLSetSNIServerNameError.Raise_();

    if AVerifyHostName then
      if X509_VERIFY_PARAM_set1_host(SSL_get0_param(FSSL), GetPAnsiChar(UTF8String(ASNIHostname)), 0) <> 1 then
        EIdOpenSSLSetVerifyParamHostError.Raise_();
  end;
  if Assigned(FSession) then
    if SSL_set_session(FSSL, FSession) <> 1 then
      EIdOpenSSLSetSessionError.Raise_();

  repeat
    LReturnCode := SSL_connect(FSSL);
    Result := LReturnCode = 1;

    LShouldRetry := ShouldRetry(FSSL, LReturnCode);
    if not LShouldRetry and (LReturnCode < 0) then
      raise EIdOpenSSLConnectError.Create(FSSL, LReturnCode, '');
  until not LShouldRetry;
end;

procedure TIdOpenSSLSocketClient.SetSession(const ASession: Pointer);
begin
  FSession := ASession;
end;

end.