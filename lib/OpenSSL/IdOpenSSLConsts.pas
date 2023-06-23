unit IdOpenSSLConsts;

interface

{$i IdCompilerDefines.inc}

{$IFDEF FPC}
uses
  ctypes
  {$IFDEF HAS_UNIT_UnixType}
  , UnixType
  {$ENDIF}
  ;
{$ELSE}
  // Delphi defines (P)SIZE_T and (P)SSIZE_T in the Winapi.Windows unit in
  // XE2+, but we don't want to pull in that whole unit here just to define
  // a few aliases...
  {$IFDEF WINDOWS}
    {$IFDEF VCL_XE2_OR_ABOVE}
uses Winapi.Windows;
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

const
  CLibCryptoRaw = 'libcrypto';
  CLibSSLRaw = 'libssl';

  SSLDLLVers: array [0..1] of string = ('', '.1.1');

  CLibCrypto =
    CLibCryptoRaw + '-1_1.dll';
  CLibSSL =
    CLibSSLRaw + '-1_1.dll';
  {$IFDEF FPC}
  IdNilHandle = {$IFDEF WINDOWS}PtrUInt(0){$ELSE}PtrInt(0){$ENDIF};
  {$ELSE}
  IdNilHandle = THandle(0);
  {$ENDIF}

type
  PPByte = ^PByte;
  PPPByte = ^PPByte;
  // this is necessary because Borland still doesn't support QWord
  // (unsigned 64bit type).
  {$IFNDEF HAS_QWord}
  qword = {$IFDEF HAS_UInt64}UInt64{$ELSE}Int64{$ENDIF};
  {$ENDIF}
  {$IFDEF FPC}
  TIdC_INT64 = cint64;
  PIdC_INT64 = pcint64;
  TIdC_UINT64 = cuint64;
  PIdC_UINT64 = pcuint64;
  {$ELSE}
  TIdC_INT64 = Int64;
  PIdC_INT64 = ^TIdC_INT64{PInt64};
  TIdC_UINT64 = QWord;
  PIdC_UINT64 = ^TIdC_UINT64{PQWord};
  {$ENDIF}

  {$IFDEF FPC}
  TIdC_INT32 = cint;
  PIdC_INT32 = pcint;
  TIdC_UINT32 = cuint;
  PIdC_UINT32 = pcuint;
  {$ELSE}
  TIdC_INT32 = Integer;
  PIdC_INT32 = ^TIdC_INT64{PInt64};
  TIdC_UINT32 = Cardinal;
  PIdC_UINT32 = ^TIdC_UINT64{PQWord};
  {$ENDIF}

  {$IFDEF FPC}
  TIdC_INT   = cInt;
  PIdC_INT   = pcInt;
  PPIdC_INT  = ^PIdC_INT;
  {$ELSE}
  TIdC_INT   = Integer;
  PIdC_INT   = ^TIdC_INT;
  PPIdC_INT  = ^PIdC_INT;
  {$ENDIF}
  {$IFDEF HAS_SIZE_T}
  TIdC_SIZET = size_t;
  {$ELSE}
    {$IFDEF HAS_PtrUInt}
  TIdC_SIZET = PtrUInt;
    {$ELSE}
      {$IFDEF CPU32}
  TIdC_SIZET = TIdC_UINT32;
      {$ENDIF}
      {$IFDEF CPU64}
  TIdC_SIZET = TIdC_UINT64;
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
  {$IFDEF HAS_PSIZE_T}
  PIdC_SIZET = psize_t;
  {$ELSE}
  PIdC_SIZET = ^TIdC_SIZET;
  {$ENDIF}
  {$IFDEF FPC}
  TIdLibHandle = {$IFDEF WINDOWS}PtrUInt{$ELSE}PtrInt{$ENDIF};
  {$ELSE}
  TIdLibHandle = THandle;
  {$ENDIF}
  TIdLibFuncName = String;
  PIdLibFuncNameChar = PChar;
  {$IFDEF HAS_TIME_T}
  TIdC_TIMET = time_t;
  {$ELSE}
    {$IFDEF HAS_PtrInt}
  TIdC_TIMET = PtrInt;
    {$ELSE}
      {$IFDEF CPU32}
  TIdC_TIMET = TIdC_INT32;
      {$ENDIF}
      {$IFDEF CPU64}
  TIdC_TIMET = TIdC_INT64;
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
  {$IFDEF HAS_PTIME_T}
  PIdC_TIMET = ptime_t;
  {$ELSE}
  PIdC_TIMET = ^TIdC_TIMET;
  {$ENDIF}

  function LoadLibFunction(const ALibHandle: TIdLibHandle; const AProcName: TIdLibFuncName): Pointer;

implementation

function LoadLibFunction(const ALibHandle: TIdLibHandle; const AProcName: TIdLibFuncName): Pointer;
begin
  {$I IdRangeCheckingOff.inc}
  Result := {$IFDEF WINDOWS}{$IFNDEF FPC}Winapi.Windows.{$ENDIF}{$ENDIF}GetProcAddress(ALibHandle, PIdLibFuncNameChar(AProcName));
  {$I IdRangeCheckingOn.inc}
end;

end.
