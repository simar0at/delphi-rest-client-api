unit TestAsync;

interface

uses BaseTestRest, RestException;

type
  TTestAsync = class(TBaseTestRest)
  private
    procedure _GET_CancelRequestUsingOnAsyncRequestProcessEvent;
    procedure _GET_CancelRequestWhenDestroyingTheRestClientObject;
  published
    procedure GET_CancelRequestUsingOnAsyncRequestProcessEvent;
    procedure GET_CancelRequestWhenDestroyingTheRestClientObject;
  end;

implementation

uses
  Classes, SysUtils, HttpConnection;

type
  TAnonymousThread = class(TThread)
  private
    FProc: TProc;
  protected
    procedure Execute; override;
  public
    constructor Create(const AProc: TProc);
  end;

{ TTestAsync }

procedure TTestAsync.GET_CancelRequestUsingOnAsyncRequestProcessEvent;
begin
  {$IFDEF FPC}
  if RestClient.ConnectionType = hctWinHttp then
    ExpectedException := EAbort
  else
    ExpectedException := ENotImplemented;
  _GET_CancelRequestUsingOnAsyncRequestProcessEvent;
  {$ELSE}
  if RestClient.ConnectionType = hctWinHttp then
    CheckException(_GET_CancelRequestUsingOnAsyncRequestProcessEvent, EAbort)
  else
    CheckException(_GET_CancelRequestUsingOnAsyncRequestProcessEvent, ENotImplemented);
  {$ENDIF}
end;

procedure TTestAsync._GET_CancelRequestUsingOnAsyncRequestProcessEvent;
begin
  RestClient.OnAsyncRequestProcess :=
    procedure(var Cancel: Boolean)
    begin
      Cancel := True;
    end;

  RestClient.Resource(CONTEXT_PATH + 'async')
            .Accept('text/plain')
            .Async
            .GET();
end;

procedure TTestAsync.GET_CancelRequestWhenDestroyingTheRestClientObject;
begin
  {$IFDEF FPC}
  if RestClient.ConnectionType = hctWinHttp then
    ExpectedException := EAbort
  else
    ExpectedException := ENotImplemented;
  _GET_CancelRequestWhenDestroyingTheRestClientObject
  {$ELSE}
  if RestClient.ConnectionType = hctWinHttp then
    CheckException(_GET_CancelRequestWhenDestroyingTheRestClientObject, EAbort)
  else
    CheckException(_GET_CancelRequestWhenDestroyingTheRestClientObject, ENotImplemented);
  {$ENDIF}

end;

procedure TTestAsync._GET_CancelRequestWhenDestroyingTheRestClientObject;
begin
  TAnonymousThread.Create(
    procedure
    begin
      Sleep(50);
      FreeAndNilRestClient;
    end).Start;

  RestClient.Resource(CONTEXT_PATH + 'async')
            .Accept('text/plain')
            .Async
            .GET();end;
{ TAnonymousThread }

constructor TAnonymousThread.Create(const AProc: TProc);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FProc := AProc;
end;

procedure TAnonymousThread.Execute;
begin
  FProc();
end;

initialization
  TTestAsync.RegisterTest;

end.

