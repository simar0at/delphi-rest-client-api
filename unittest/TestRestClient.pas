unit TestRestClient;

interface

{$I DelphiRest.inc}

uses {$IFNDEF FPC}DUnitX.TestFramework,DUnitX.DUnitCompatibility, {$ELSE}fpcunit, testregistry, {$ENDIF}RestClient, HttpConnection, Classes, SysUtils, RestException;

type
  TTestRestClient = class(TTestCase)
  private
    FRest: TRestClient;
    FCustomCreateConnectionCalled: Boolean;

    procedure OnCreateCustomConnectionNull(Sender: TObject; AConnectionType: THttpConnectionType; out AConnection: IHttpConnection);
    procedure OnCreateCustomConnection(Sender: TObject; AConnectionType: THttpConnectionType; out AConnection: IHttpConnection);
    procedure _InvalidCustomConnectionConfiguration;
    procedure _InvalidCustomConnectionConfigurationResult;
    procedure _RaiseExceptionWhenInactiveConnection;
    procedure _RaiseExceptionWhenInactiveConnection2;
  protected
    procedure TearDown; override;
    procedure SetUp; override;
  published
    procedure InvalidCustomConnectionConfiguration;
    procedure InvalidCustomConnectionConfigurationResult;
    procedure UsingCustomConnection;
    procedure RaiseExceptionWhenInactiveConnection;
    procedure RaiseExceptionWhenInactiveConnection2;
  end;

implementation

type
  IStubConnection = interface(IHttpConnection)
    ['{9CCD27F6-ADA6-47CE-84C4-B7126F8D3281}']
  end;

  TStubConnection = class(TInterfacedObject, IHttpConnection, IStubConnection)
    function SetAcceptTypes(AAcceptTypes: string): IHttpConnection;virtual;abstract;
    function SetContentTypes(AContentTypes: string): IHttpConnection;virtual;abstract;
    function SetAcceptedLanguages(AAcceptedLanguages: string): IHttpConnection;virtual;abstract;
    function SetHeaders(AHeaders: TStrings): IHttpConnection;virtual;abstract;
    function ConfigureTimeout(const ATimeOut: TTimeOut): IHttpConnection;virtual;abstract;
    function ConfigureProxyCredentials(AProxyCredentials: TProxyCredentials): IHttpConnection;virtual;abstract;
    function SetCredentials(const ALogin: string; const APassword: string): IHttpConnection;virtual;abstract;

    procedure Get(AUrl: string; AResponse: TStream);virtual;abstract;
    procedure Post(AUrl: string; AContent, AResponse: TStream);virtual;abstract;
    procedure Put(AUrl: string; AContent, AResponse: TStream);virtual;abstract;
    procedure Patch(AUrl: string; AContent, AResponse: TStream);virtual;abstract;
    procedure Delete(AUrl: string; AContent, AResponse: TStream);virtual;abstract;

    function GetResponseCode: Integer;virtual;abstract;
    function GetResponseHeader(const Header: string): string; virtual;abstract;
    function GetEnabledCompression: Boolean;virtual;abstract;

    procedure SetEnabledCompression(const Value: Boolean);virtual;abstract;

    function GetOnConnectionLost: THTTPConnectionLostEvent;
    procedure SetOnConnectionLost(AConnectionLostEvent: THTTPConnectionLostEvent);
    property OnConnectionLost: THTTPConnectionLostEvent read GetOnConnectionLost write SetOnConnectionLost;

    procedure SetVerifyCert(const Value: boolean);
    function GetVerifyCert: boolean;virtual;abstract;

    function SetAsync(const Value: Boolean): IHttpConnection; virtual; abstract;
    procedure CancelRequest;

    function SetOnAsyncRequestProcess(const Value: TAsyncRequestProcessEvent): IHttpConnection;
  end;

{ TTestRestClient }

procedure TTestRestClient.InvalidCustomConnectionConfiguration;
begin
  {$IFNDEF FPC}
  CheckException(_InvalidCustomConnectionConfiguration, EInvalidHttpConnectionConfiguration);
  {$ELSE}
  ExpectException(EInvalidHttpConnectionConfiguration);
  _InvalidCustomConnectionConfiguration
  {$ENDIF}
end;

procedure TTestRestClient._InvalidCustomConnectionConfiguration;
begin
  FRest.ConnectionType := hctCustom;
end;

procedure TTestRestClient.InvalidCustomConnectionConfigurationResult;
begin
  {$IFNDEF FPC}
  CheckException(_InvalidCustomConnectionConfiguration, ECustomCreateConnectionException);
  {$ELSE}
  ExpectException(ECustomCreateConnectionException);
  _InvalidCustomConnectionConfigurationResult
  {$ENDIF}
end;

procedure TTestRestClient._InvalidCustomConnectionConfigurationResult;
begin
  FRest.OnCustomCreateConnection := {$IFDEF FPC}@{$ENDIF}OnCreateCustomConnectionNull;
  FRest.ConnectionType := hctCustom;
end;

procedure TTestRestClient.OnCreateCustomConnection(Sender: TObject; AConnectionType: THttpConnectionType; out AConnection: IHttpConnection);
begin
  FCustomCreateConnectionCalled := True;
  {$WARN CONSTRUCTING_ABSTRACT OFF}
  AConnection := TStubConnection.Create;
  {$WARN CONSTRUCTING_ABSTRACT ON}
end;

procedure TTestRestClient.OnCreateCustomConnectionNull(Sender: TObject;
  AConnectionType: THttpConnectionType; out AConnection: IHttpConnection);
begin
  AConnection := nil;
end;

procedure TTestRestClient.RaiseExceptionWhenInactiveConnection;
begin
  {$IFNDEF FPC}
  CheckException(_RaiseExceptionWhenInactiveConnection, EInactiveConnection);
  {$ELSE}
  ExpectException(EInactiveConnection);
  _RaiseExceptionWhenInactiveConnection
  {$ENDIF}
end;


procedure TTestRestClient._RaiseExceptionWhenInactiveConnection;
begin
  FRest.ResponseCode;
end;

procedure TTestRestClient.RaiseExceptionWhenInactiveConnection2;
begin
  {$IFNDEF FPC}
  CheckException(_RaiseExceptionWhenInactiveConnection2, EInactiveConnection);
  {$ELSE}
  ExpectException(EInactiveConnection);
  _RaiseExceptionWhenInactiveConnection2
  {$ENDIF}
end;
procedure TTestRestClient._RaiseExceptionWhenInactiveConnection2;
begin
  FRest.Resource('https://www.google.com.br').Get;
end;

procedure TTestRestClient.SetUp;
begin
  inherited;
  FRest := TRestClient.Create(nil);
  FRest.Name := ClassName + '_' + FRest.ClassName;;
end;

procedure TTestRestClient.TearDown;
begin
  inherited;
  FRest.Free;
end;

procedure TTestRestClient.UsingCustomConnection;
begin
  FRest.OnCustomCreateConnection := {$IFDEF FPC}@{$ENDIF}OnCreateCustomConnection;
  FRest.ConnectionType := hctCustom;

  CheckTrue(FCustomCreateConnectionCalled);
  CheckTrue(Supports(FRest.UnWrapConnection, IStubConnection));
end;

procedure TStubConnection.CancelRequest;
begin

end;

{ TStubConnection }

function TStubConnection.GetOnConnectionLost: THTTPConnectionLostEvent;
begin

end;

function TStubConnection.SetOnAsyncRequestProcess(const Value: TAsyncRequestProcessEvent): IHttpConnection;
begin
  Result := Self;
end;

procedure TStubConnection.SetOnConnectionLost(
  AConnectionLostEvent: THTTPConnectionLostEvent);
begin

end;

procedure TStubConnection.SetVerifyCert(const Value: boolean);
begin

end;

initialization
  {$IFDEF FPC}
  RegisterTest(TTestRestClient);
  {$ENDIF}

end.
