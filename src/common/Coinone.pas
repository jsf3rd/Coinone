// *******************************************************
//
// playIoT Coinone API Library
//
// Copyright(c) 2017 playIoT.
//
// Writer : jsf3rd@playiot.biz
//
// API Doc : http://doc.coinone.co.kr/#api-_
//
//
// *******************************************************

unit Coinone;

interface

uses System.SysUtils, System.Variants, System.Classes,
  EncdDecd, IdGlobal, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  REST.JSON, System.JSON, IdCoder, IdCoderMIME, IdHash, IdHashSHA, IdSSLOpenSSL,
  System.DateUtils, IdHMACSHA1, IdHMAC, System.NetEncoding, IdURI;

type
  TRequestType = ( //
    // Account
    rtBalance, rtDailyBalance, rtDepositAddress, rtUserInformation, rtVirtualAccount,
    // Order
    rtCancelOrder, rtLimitBuy, rtLimitSell, rtMyCompleteOrders, rtMyLimitOrders,
    rtMyOrderInformation,
    // Public
    rtOrderbook, rtRecentCompleteOrders, rtTicker);

  TCoinone = class
  private
    FIdHttp: TIdHTTP;
    FToken: string;
    FHashKey: string;
    function GetURL(AType: TRequestType): string;
    function Get(AType: TRequestType; AParam: string): TJSONObject;
    function Post(AType: TRequestType; AParams: TJSONObject): TJSONObject;
  public
    constructor Create(AToken, AKey: string);
    destructor Destroy; override;

    function AccountInfo(AType: TRequestType): TJSONObject;
    function Order(AType: TRequestType; AParams: TJSONObject): TJSONObject;
    function PublicInfo(AType: TRequestType; AParam: string): TJSONObject;
  end;

const
  // Account
  URL_BALANCE = 'https://api.coinone.co.kr/v2/account/balance/';
  URL_DAILY_BALANCE = 'https://api.coinone.co.kr/v2/account/daily_balance/';
  URL_DEPOSIT_ADDRESS = 'https://api.coinone.co.kr/v2/account/deposit_address/';
  URL_USER_INFORMATION = 'https://api.coinone.co.kr/v2/account/user_info/';
  URL_VIRTUAL_ACCOUNT = 'https://api.coinone.co.kr/v2/account/virtual_account/';

  // Order
  URL_CANCEL_ORDER = 'https://api.coinone.co.kr/v2/order/cancel/';
  URL_LIMIT_BUY = 'https://api.coinone.co.kr/v2/order/limit_buy/';
  URL_LIMIT_SELL = 'https://api.coinone.co.kr/v2/order/limit_sell/';
  URL_MY_COMPLETE_ORDERS = 'https://api.coinone.co.kr/v2/order/complete_orders/';
  URL_MY_LIMIT_ORDERS = 'https://api.coinone.co.kr/v2/order/limit_orders/';
  URL_MY_ORDER_INFORMATION = 'https://api.coinone.co.kr/v2/order/order_info/';

  // Public
  URL_ORDER_BOOK = 'https://api.coinone.co.kr/orderbook/';
  URL_RECENT_COMPLETE_ORDERS = 'https://api.coinone.co.kr/trades/';
  URL_TICKER = 'https://api.coinone.co.kr/ticker/';

  Coins: array [0 .. 9] of string = ('btc', 'bch', 'eth', 'etc', 'xrp', 'qtum', 'iota', 'ltc',
    'btg', 'krw');

implementation

{ TCoinone }

function TCoinone.AccountInfo(AType: TRequestType): TJSONObject;
var
  AParams: TJSONObject;
begin
  AParams := TJSONObject.Create;
  try
    result := Post(AType, AParams);
  finally
    AParams.Free;
  end;
end;

constructor TCoinone.Create(AToken, AKey: string);
begin
  if not LoadOpenSSLLibrary then
    raise Exception.Create('LoadOpenSSLLibrary Error');

  FToken := AToken;
  FHashKey := AKey;

  FIdHttp := TIdHTTP.Create(nil);
end;

destructor TCoinone.Destroy;
begin
  FIdHttp.Free;
  inherited;
end;

function TCoinone.Get(AType: TRequestType; AParam: string): TJSONObject;
var
  Response: TBytesStream;
  Res: string;
begin
  FIdHttp.Request.Clear;
  FIdHttp.Request.Accept := 'application/json';
  FIdHttp.Request.ContentType := 'application/json';

  Response := TBytesStream.Create;
  try
    FIdHttp.Get(GetURL(AType) + '?' + AParam, Response);
    Response.SetSize(Response.Size);
    Res := TEncoding.UTF8.GetString(Response.Bytes);
    result := TJSONObject.ParseJSONValue(Res) as TJSONObject;
  finally
    Response.Free;;
  end;

end;

function TCoinone.GetURL(AType: TRequestType): string;
begin
  case AType of
    rtBalance:
      result := URL_BALANCE;
    rtDailyBalance:
      result := URL_DAILY_BALANCE;
    rtDepositAddress:
      result := URL_DEPOSIT_ADDRESS;
    rtUserInformation:
      result := URL_USER_INFORMATION;
    rtVirtualAccount:
      result := URL_VIRTUAL_ACCOUNT;
    rtCancelOrder:
      result := URL_CANCEL_ORDER;
    rtLimitBuy:
      result := URL_LIMIT_BUY;
    rtLimitSell:
      result := URL_LIMIT_SELL;
    rtMyCompleteOrders:
      result := URL_MY_COMPLETE_ORDERS;
    rtMyLimitOrders:
      result := URL_MY_LIMIT_ORDERS;
    rtMyOrderInformation:
      result := URL_MY_ORDER_INFORMATION;
    rtOrderbook:
      result := URL_ORDER_BOOK;
    rtRecentCompleteOrders:
      result := URL_RECENT_COMPLETE_ORDERS;
    rtTicker:
      result := URL_TICKER;

  else
    raise Exception.Create('Unknown RequestType,' + Integer(AType).ToString);
  end;
end;

function TCoinone.Order(AType: TRequestType; AParams: TJSONObject): TJSONObject;
begin
  result := Post(AType, AParams);
end;

function TCoinone.Post(AType: TRequestType; AParams: TJSONObject): TJSONObject;

// Build base64 encoded payLoad
  function GetPayLoad: string;
  var
    Bytes: TIdBytes;
    Encoded: string;
  begin
    AParams.AddPair('access_token', FToken);
    AParams.AddPair('nonce', TJSONNumber.Create(DateTimeToUnix(Now)));
    Bytes := ToBytes(AParams.ToString);
    Encoded := EncodeBase64(Bytes, Length(Bytes));
    result := Encoded.Replace(sLineBreak, '', [rfReplaceAll]);
  end;

  function SHA512Hash(AVAlue: string): string;
  var
    Hasher: TIdHMACSHA512;
    Bytes: TIdBytes;
  begin
    Hasher := TIdHMACSHA512.Create;
    try
      Hasher.Key := ToBytes(FHashKey);
      Bytes := ToBytes(AVAlue);
      result := LowerCase(ToHex(Hasher.HashValue(Bytes)));
    finally
      Hasher.Free;
    end;
  end;

var
  Signature: String;
  Response: TBytesStream;
  FPost: TStrings;

  Res: string;
  PayLoad: string;
begin
  PayLoad := GetPayLoad;

  try
    Signature := SHA512Hash(PayLoad);
  except
    on E: Exception do
      raise Exception.Create('SHA512 Error,' + E.Message);
  end;

  FIdHttp.Request.Clear;
  FIdHttp.Request.Accept := 'application/json';
  FIdHttp.Request.ContentType := 'application/json';
  FIdHttp.Request.CustomHeaders.AddValue('X-COINONE-PAYLOAD', PayLoad);
  FIdHttp.Request.CustomHeaders.AddValue('X-COINONE-SIGNATURE', Signature);

  FPost := TStringList.Create;
  try
    Response := TBytesStream.Create;
    try
      FIdHttp.Post(GetURL(AType), FPost, Response);
      Response.SetSize(Response.Size);
      Res := TEncoding.UTF8.GetString(Response.Bytes);
      result := TJSONObject.ParseJSONValue(Res) as TJSONObject;
    finally
      Response.Free;;
    end;
  finally
    FPost.Free;
  end;
end;

function TCoinone.PublicInfo(AType: TRequestType; AParam: string): TJSONObject;
begin
  result := Get(AType, AParam);
end;

end.
