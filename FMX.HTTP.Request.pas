unit FMX.HTTP.Request;

{
  author: ZuBy
  email: rzaripov1990@gmail.com

  https://github.com/rzaripov1990
}

interface

uses
  System.Classes, System.SysUtils,
  FMX.Types;

type
  // Post Params
  TmyPostParam = record
    Key: string;
    Value: string;
    IsFile: boolean;
    constructor Create(const aKey, aValue: string; const aIsFile: boolean = false);
  end;

  // HTTP Helper
  TmyAPI = record
  private
    class function CheckInet: boolean; static;
  public
    class function IsOK(const aData: string): boolean; static;
    class function ErrorText(const aData: string): string; static;
    class function Get(const aURL: string): string; overload; static;
    class function Get(const aURL: string; const aEncoding: TEncoding): string; overload; static;
    class function Post(const aURL: string; const aFields: TArray<TmyPostParam>): string; overload; static;
    class function Post(const aURL: string; const aFields: TArray<TmyPostParam>; const aEncoding: TEncoding): string;
      overload; static;
  end;

implementation

uses
  System.Net.HTTPClient, System.Net.HTTPClientComponent,
  System.Net.Mime;

const
  SIGNATURE = '[TmyAPI]';
  SIGNATURE_LEN = Length(SIGNATURE);
  MSGERR = SIGNATURE + 'Error';
  MSGERR_I = SIGNATURE + 'No Internet Connection';

class function TmyAPI.CheckInet: boolean;
var
  aResp: IHTTPResponse;
  aHTTP: TNetHTTPClient;
begin
  Result := false;
  aHTTP := TNetHTTPClient.Create(nil);
  try
    try
      aResp := aHTTP.Head('http://google.com');
      Result := aResp.StatusCode < 400;
    except
      Result := false;
    end;
  finally
    FreeAndNil(aHTTP);
  end;
end;

class function TmyAPI.ErrorText(const aData: string): string;
begin
  Result := aData.Substring(SIGNATURE_LEN);
end;

class function TmyAPI.IsOK(const aData: string): boolean;
begin
  Result := not aData.StartsWith(SIGNATURE);
end;

class function TmyAPI.Post(const aURL: string; const aFields: TArray<TmyPostParam>; const aEncoding: TEncoding): string;
var
  aData: TMultipartFormData;
  aHTTP: TNetHTTPClient;
  aResp: TStringStream;
  I: Integer;
begin
  // Check Internet Connection
  if not TmyAPI.CheckInet then
  begin
    Result := MSGERR_I;
    exit;
  end;

  Result := MSGERR;
  // Request
  aResp := TStringStream.Create('', aEncoding);
  aData := TMultipartFormData.Create();
  aHTTP := TNetHTTPClient.Create(nil);
  try
    for I := Low(aFields) to High(aFields) do
    begin
      if aFields[I].IsFile then
        aData.AddFile(aFields[I].Key, aFields[I].Value)
      else
        aData.AddField(aFields[I].Key, aFields[I].Value);
    end;

    try
      aHTTP.Post(aURL, aData, aResp);
      Result := aResp.DataString;
    except
      Result := MSGERR;
    end;
  finally
    FreeAndNil(aHTTP);
    FreeAndNil(aData);
    FreeAndNil(aResp);
  end;
end;

class function TmyAPI.Post(const aURL: string; const aFields: TArray<TmyPostParam>): string;
begin
  Result := TmyAPI.Post(aURL, aFields, TEncoding.UTF8);
end;

class function TmyAPI.Get(const aURL: string): string;
begin
  Result := TmyAPI.Get(aURL, TEncoding.UTF8);
end;

class function TmyAPI.Get(const aURL: string; const aEncoding: TEncoding): string;
var
  aHTTP: TNetHTTPClient;
  aResp: TStringStream;
begin
  // Check Internet Connection
  if not TmyAPI.CheckInet then
  begin
    Result := MSGERR_I;
    exit;
  end;

  Result := MSGERR;
  // Request
  aResp := TStringStream.Create('', aEncoding);
  aHTTP := TNetHTTPClient.Create(nil);
  try
    try
      aHTTP.Get(aURL, aResp);
      Result := aResp.DataString;
    except
      Result := MSGERR;
    end;
  finally
    FreeAndNil(aHTTP);
    FreeAndNil(aResp);
  end;
end;

{ TmyPostParam }

constructor TmyPostParam.Create(const aKey, aValue: string; const aIsFile: boolean = false);
begin
  Self.Key := aKey;
  Self.Value := aValue;
  Self.IsFile := aIsFile;
end;

end.
