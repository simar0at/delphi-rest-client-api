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
{                               Here could be your name                        }
{                                                                              }
{******************************************************************************}

unit IdOpenSSLIOHandlerClientBase;

interface

{$i IdCompilerDefines.inc}

uses
  IdGlobal,
  IdOpenSSLContext,
  IdOpenSSLSocket,
  IdSSL;

type
  TIdOpenSSLIOHandlerClientBase = class(TIdSSLIOHandlerSocketBase)
  private
  protected
    FTLSSocket: TIdOpenSSLSocket;
    FContext: TIdOpenSSLContext;

    function RecvEnc(var ABuffer: TIdBytes): Integer; override;
    function SendEnc(const ABuffer: TIdBytes; const AOffset, ALength: Integer): Integer; override;
    procedure EnsureContext; virtual; abstract;

    procedure SetPassThrough(const Value: Boolean); override;
  public
    destructor Destroy; override;

    procedure AfterAccept; override;
    procedure StartSSL; override;
    procedure ConnectClient; override;
    procedure Close; override;

    function CheckForError(ALastResult: Integer): Integer; override;
    procedure RaiseError(AError: Integer); override;

    function Readable(AMSec: Integer = IdTimeoutDefault): Boolean; override;

    function Clone: TIdSSLIOHandlerSocketBase; override;
  end;

implementation

uses
  IdOpenSSLExceptions,
  IdOpenSSLHeaders_ssl,
  IdStackConsts,
  SysUtils;

type
  TIdOpenSSLSocketAccessor = class(TIdOpenSSLSocket);

{ TIdOpenSSLIOHandlerClientBase }

procedure TIdOpenSSLIOHandlerClientBase.AfterAccept;
begin
  inherited;
  EnsureContext();
  StartSSL();
end;

procedure TIdOpenSSLIOHandlerClientBase.Close;
begin
  if Assigned(FTLSSocket) then
  begin
    FTLSSocket.Close();
    FreeAndNil(FTLSSocket);
  end;
  inherited;
end;

procedure TIdOpenSSLIOHandlerClientBase.ConnectClient;
begin
  inherited;
  EnsureContext();
  StartSSL();
end;

destructor TIdOpenSSLIOHandlerClientBase.Destroy;
begin
  FreeAndNil(FTLSSocket);
  // no FContext.Free() here, if a derived class creates an own instance that
  // class should free that object
  inherited;
end;

function TIdOpenSSLIOHandlerClientBase.CheckForError(ALastResult: Integer): Integer;
begin
  if PassThrough then
  begin
    Result := inherited CheckForError(ALastResult);
    Exit;
  end;

  Result := FTLSSocket.GetErrorCode(ALastResult);
  case Result of
    SSL_ERROR_SYSCALL:
      Result := inherited CheckForError(ALastResult);
//      inherited CheckForError(Integer(Id_SOCKET_ERROR));
    SSL_ERROR_NONE:
    begin
      Result := 0;
      Exit;
    end;
  else
    raise EIdOpenSSLUnspecificStackError.Create('', Result);
  end;
end;

function TIdOpenSSLIOHandlerClientBase.Clone: TIdSSLIOHandlerSocketBase;
begin
  Result := TIdClientSSLClass(Self.ClassType).Create(Owner);
end;

function TIdOpenSSLIOHandlerClientBase.RecvEnc(var ABuffer: TIdBytes): Integer;
begin
  Result := FTLSSocket.Receive(ABuffer);
end;

function TIdOpenSSLIOHandlerClientBase.SendEnc(const ABuffer: TIdBytes;
  const AOffset, ALength: Integer): Integer;
begin
  Result := FTLSSocket.Send(ABuffer, AOffset, ALength);
end;

procedure TIdOpenSSLIOHandlerClientBase.SetPassThrough(const Value: Boolean);
begin
  if fPassThrough = Value then
    Exit;
  inherited;
  if not Value then
  begin
    if BindingAllocated then
      StartSSL();
  end
  else
  begin
    if Assigned(FTLSSocket) then
    begin
      FTLSSocket.Close();
      FreeAndNil(FTLSSocket);
    end;
  end;
end;

procedure TIdOpenSSLIOHandlerClientBase.RaiseError(AError: Integer);

  function IsSocketError(const AError: Integer): Boolean; {$IFDEF USE_INLINE}inline;{$ENDIF}
  begin
    Result := (AError = Id_WSAESHUTDOWN)
      or (AError = Id_WSAECONNABORTED)
      or (AError = Id_WSAECONNRESET)
  end;

begin
  if PassThrough or IsSocketError(AError) or not Assigned(FTLSSocket) then
    inherited RaiseError(AError)
  else
    raise EIdOpenSSLUnspecificError.Create(TIdOpenSSLSocketAccessor(FTLSSocket).FSSL, AError, '');
end;

function TIdOpenSSLIOHandlerClientBase.Readable(AMSec: Integer): Boolean;
begin
  Result := True;
  if PassThrough or not FTLSSocket.HasReadableData() then
    Result := inherited Readable(AMSec);
end;

procedure TIdOpenSSLIOHandlerClientBase.StartSSL;
var
  LTimeout: Integer;
begin
  inherited;
  if PassThrough then
    Exit;
  FTLSSocket := FContext.CreateSocket();

  {$IFDEF WIN32_OR_WIN64}
  if IndyCheckWindowsVersion(6) then
  begin
    // Note: Fix needed to allow SSL_Read and SSL_Write to timeout under
    // Vista+ when connection is dropped
    LTimeout := FReadTimeOut;
    if LTimeout <= 0 then begin
      LTimeout := 30000; // 30 seconds
    end;
    Binding.SetSockOpt(Id_SOL_SOCKET, Id_SO_RCVTIMEO, LTimeout);
    Binding.SetSockOpt(Id_SOL_SOCKET, Id_SO_SNDTIMEO, LTimeout);
  end;
  {$ENDIF}
end;

end.
