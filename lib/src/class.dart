part of imena;

class ImenaAPI {
  String _endpoint = "";
  String transPrefix = "API";
  String transSuffix = "DART";

  var _apiRawResponse;
  var _apiResponse;
  var _apiError;
  var _apiErrorCode;
  var _apiResult;

  String _authToken = null;
  String _login = "";
  String _password = "";
  Map<String, dynamic> _tokenData = {};
  bool success = false;
  bool httpSuccess = false;
  var _httpError = null;
  http.Response _httpResponse;

  ImenaAPI(this._endpoint);

  String get endpoint => _endpoint;
  set endpoint(str) => _endpoint = str;

  http.Response get httpResponse => _httpResponse;
  String get rawResponse => _apiRawResponse;
  Map<dynamic, dynamic> get error => _apiError;
  int get errorCode => int.parse(_apiErrorCode);
  Map<dynamic, dynamic> get result => _apiResult;
  Map<String, dynamic> get tokenData => _tokenData;
  String get token => _authToken;
  dynamic get httpError => _httpError;

  String _transactionID() {
    return "${this.transPrefix}-${new DateTime.now().millisecondsSinceEpoch}-${this.transSuffix}";
  }

  Future<bool> _exec(cmd, [body = ""]) async {
    String trID = this._transactionID();
    Map<String, String> requestHeader = {'Content-Type': 'application/json', 'X-ApiTransactionID': trID};
    Map<String, dynamic> requestBody = {"jsonrpc": "2.0", "id": trID, "method": cmd, "params": body};

    success = false;
    httpSuccess = false;

    _apiError = null;
    _apiErrorCode = 0;
    _apiResult = null;
    _apiRawResponse = null;
    _apiResponse = null;

    try {
      _httpResponse = await http.post(endpoint, headers: requestHeader, body: json.encode(requestBody));

      _apiRawResponse = _httpResponse.body;
      _apiResponse = json.decode(_httpResponse.body);

      _apiError = _apiResponse['error'];
      _apiResult = _apiResponse['result'];

      if (_apiError != null) {
        _apiErrorCode = _apiError['code'];
      }

      success = _apiError == null;
      httpSuccess = true;
    } catch (e) {
      _httpError = e;
      print(e);
    }

    return success;
  }

  String getResellerCode([String resellerCode = null]){
    if (resellerCode == null) {
      if (this._tokenData.length == 0 || this._tokenData['user']['resellerCode'] == null) {
        throw Exception("This operation required resellerCode!");
      }
      resellerCode = this._tokenData['user']['resellerCode'];
    }

    return resellerCode;
  }

  /*
  * Authentication of reseller's user
  * API command - authenticateResellerUser
  * */
  Future<bool> login({
    @required String login,
    @required String password,
    String smsCode: '',
    String gaCode: ''
  }) async {
    _login = login;
    _password = password;

    Map<String, String> body = {
      "login": _login,
      "password": _password,
      if (smsCode != '') "smsCode": smsCode,
      if (gaCode != '') "gaCode": gaCode
    };

    await _exec(ImenaAPIConst.COMMAND_LOGIN, body);

    if (!success) {
      return false;
    }

    _authToken = _apiResult['authToken'];

    await tokenInfo();

    return true;
  }

  Future<bool> secondAuth({
    String smsCode: '',
    String gaCode: ''
  }) async {
    Map<String, String> body = {
      "login": _login,
      "password": _password,
      if (smsCode != '') "smsCode": smsCode,
      if (gaCode != '') "gaCode": gaCode
    };

    await _exec(ImenaAPIConst.COMMAND_LOGIN, body);

    if (!success) {
      return false;
    }

    this._authToken = _apiResult['authToken'];

    await tokenInfo();

    return true;
  }

  /*
  * Invalidation of token (end of session)
  * API command - invalidateAuthToken
  * */
  Future<bool> logout() async {
    await _exec(ImenaAPIConst.COMMAND_LOGOUT, {"authToken": this._authToken});

    if (!success) {
      return false;
    }

    this._login = null;
    this._password = null;
    this._authToken = null;
    this._tokenData = null;

    return true;
  }

  /*
  * Receiving information about the current session and authenticated user by authToken
  * API command - getAuthTokenInfo
  * */
  Future<Map<String, dynamic>> tokenInfo() async {
    await _exec(ImenaAPIConst.COMMAND_TOKEN_INFO, {"authToken": this._authToken});
    _tokenData = success ? _apiResult : {};
    return _tokenData;
  }

  /*
  * Receiving the list of domain names accessible to the current user
  * API command - getDomainsList
  * */
  Future<Map<String, dynamic>> domains({
    int limit: 500,
    int offset: 0
  }) async {
    Map<String, dynamic> domainList = {};

    await _exec(ImenaAPIConst.COMMAND_DOMAINS_LIST, {"authToken": this._authToken, "limit": limit, "offset": offset});

    if (success) {
      _apiResult['list'].forEach((elem) {
        domainList[elem['domainName']] = elem;
      });
    }

    return domainList;
  }

  /*
  * Get domains total on reseller account
  * */
  Future<int> domainsTotal() async {
    await _exec(ImenaAPIConst.COMMAND_DOMAINS_LIST, {"authToken": this._authToken, "limit": 1, "offset": 0});
    return !success ? 0 : _apiResult['total'];
  }

  /*
  * Find domains by name
  * */
  Future<Map<String, dynamic>> domainsBy([String filter = ""]) async {
    Map<String, dynamic> domainList = new Map();
    int limit = 500;
    int total = await domainsTotal();
    int pages;
    int i;
    Map<String, dynamic> result;

    if (total == 0) {
      return domainList;
    }

    pages = (total / limit).ceil();

    for (i = 0; i < pages; i++) {
      result = await domains(limit: limit, offset: limit * i);

      if (i == 0 && result.length == 0) {
        return domainList;
      }

      result.forEach((key, val) {
        if (key.contains(filter))
          domainList[key] = val;
      });
    }

    return domainList;
  }

  /*
  * Get all domains from reseller account
  * */
  Future<Map<String, dynamic>> domainsAll() async {
    return await domainsBy();
  }
    /*
  * Receiving the information on a domain name by service code
  * API command - getDomain
  * */
  Future<Map<String, dynamic>> domainInfo(String serviceCode) async {
    await _exec(ImenaAPIConst.COMMAND_DOMAIN_INFO, {"authToken": this._authToken, "serviceCode": serviceCode});
    return !success ? {} : _apiResult;
  }

  /*
  * Receiving the short information on a domain by domain name
  * API command - getDomainInfoByName
  * */
  Future<Map<String, dynamic>> domainInfoShort(String domainName) async {
    await _exec(ImenaAPIConst.COMMAND_DOMAIN_INFO_SHORT, {"authToken": this._authToken, "domainName": domainName});
    return !success ? {} : _apiResult;
  }

  /*
  * Get domain contacts by service code
  * */
  Future<dynamic> contacts(String serviceCode) async {
    Map<String, dynamic> contactList = {};

    await domainInfo(serviceCode);

    if (success) {
      _apiResult['contacts'].forEach((elem) {
        contactList[elem["contactType"]] = elem;
      });
    }

    return contactList;
  }

  /*
  * Get domain tag list
  * */
  Future<List<dynamic>> tags(String serviceCode) async {
    await domainInfo(serviceCode);
    return !success ? [] : _apiResult['tagList'];
  }

  /*
  * Get domain nameservers
  * */
  Future<List<dynamic>> nameservers(String serviceCode) async {
    await domainInfo(serviceCode);
    return !success ? [] : _apiResult['nameservers'];
  }

  /*
  * Get domain child nameservers
  * */
  Future<List<dynamic>> childNameservers(String serviceCode) async {
    await domainInfo(serviceCode);
    return !success ? [] : _apiResult['childNameservers'];
  }

  /*
  * Set domain nameservers
  * API command - editDomainNameserversList
  * */
  Future<bool> setNS({
    @required String serviceCode,
    @required List<String> ns
  }) async {
    return await _exec(ImenaAPIConst.COMMAND_SET_NS, {"authToken": this._authToken, "serviceCode": serviceCode, "list": ns});
  }

  /*
  * Set preset nameservers for domain
  * API command - setDomainNameserversToDefault, setDomainNameserversToMirohost, setDomainNameserversToDnshosting
  * */
  Future<bool> setNSPreset(String serviceCode, [String nsType = ImenaAPIConst.HOSTING_TYPE_DEFAULTS]) async {
    String cmd;

    switch (nsType) {
      case ImenaAPIConst.HOSTING_TYPE_MIROHOST:
        cmd = ImenaAPIConst.COMMAND_SET_NS_MIROHOST;
        break;
      case ImenaAPIConst.HOSTING_TYPE_DNS:
        cmd = ImenaAPIConst.COMMAND_SET_NS_DNSHOSTING;
        break;
      default:
        cmd = ImenaAPIConst.COMMAND_SET_NS_DEFAULT;
    }

    return await _exec(cmd, {"authToken": this._authToken, "serviceCode": serviceCode});
  }

  /*
  * Set preset nameservers for domain
  * API command - setDomainNameserversToDefault
  * */
  Future<bool> setDefaultNS(String serviceCode) async {
    return await setNSPreset(serviceCode, ImenaAPIConst.HOSTING_TYPE_DEFAULTS);
  }

  /*
  * Set preset nameservers for domain
  * API command - setDomainNameserversToMirohost
  * */
  Future<bool> setMirohostNS(String serviceCode) async {
    return await setNSPreset(serviceCode, ImenaAPIConst.HOSTING_TYPE_MIROHOST);
  }

  /*
  * Set preset nameservers for domain
  * API command - setDomainNameserversToDnshosting
  * */
  Future<bool> setDnshostingNS(String serviceCode) async {
    return await setNSPreset(serviceCode, ImenaAPIConst.HOSTING_TYPE_DNS);
  }

  /*
  * Add child nameserver
  * */
  Future<bool> addChildNS({
    @required String serviceCode,
    @required String host,
    @required String ip
  }) async {
    return await _exec(ImenaAPIConst.COMMAND_ADD_CHILD_NS, {"authToken": this._authToken, "serviceCode": serviceCode, "host": host, "ip": ip});
  }

  /*
  * Delete child nameserver
  * */
  Future<bool> deleteChildNS({
    @required String serviceCode,
    @required String host,
    @required String ip
  }) async {
    return await _exec(ImenaAPIConst.COMMAND_DEL_CHILD_NS, {"authToken": this._authToken, "serviceCode": serviceCode, "host": host, "ip": ip});
  }

  /*
  * Editing the contact data of a domain name by serviceCode and contactType
  * */
  Future<bool> setContact({
    @required String serviceCode,
    @required String contactType,
    @required Map<String, String> contactData
  }) async {
    return await _exec(
        ImenaAPIConst.COMMAND_UPD_CONTACT, {"authToken": this._authToken, "serviceCode": serviceCode, "contactType": contactType, "contact": contactData});
  }

  Future<bool> setPrivacy({
    @required String serviceCode,
    bool disclose: false
  }) async {
    return await _exec(ImenaAPIConst.COMMAND_SET_PRIVACY, {"authToken": this._authToken, "serviceCode": serviceCode, "whoisPrivacy": !disclose});
  }

  /*
  * Get reseller balance info
  * API command - getResellerBalance
  * */
  Future<Map<String, dynamic>> balanceInfo([String resellerCode]) async {
    await _exec(ImenaAPIConst.COMMAND_RESELLER_BALANCE, {"authToken": this._authToken, "resellerCode": getResellerCode(resellerCode)});
    return !success ? {} : _apiResult;
  }

  /*
  * Get reseller balance
  * API command - getResellerBalance
  * */
  Future<num> balance([String resellerCode]) async {
    await balanceInfo(resellerCode);
    return !success ? 0 : _apiResult['balance'];
  }

  /*
  * Get reseller credit
  * API command - getResellerBalance
  * */
  Future<num> credit([String resellerCode]) async {
    await balanceInfo(resellerCode);
    return !success ? 0 : _apiResult['creditLimit'];
  }

  /*
  * Get reseller price list
  * API command - getResellerPrices
  * */
  Future<Map<String, dynamic>> price([String resellerCode]) async {
    Map<String, dynamic> priceList = {};
    await _exec(ImenaAPIConst.COMMAND_RESELLER_PRICES, {"authToken": this._authToken, "resellerCode": getResellerCode(resellerCode)});

    if (success) {
      _apiResult.forEach((elem) {
        priceList[elem['domain']] = elem;
      });
    }

    return priceList;
  }

  /*
  * Get reseller price list for specified domain
  * API command - getResellerPrices
  * */
  Future<Map<String, dynamic>> priceDomain({
    @required String domain,
    String resellerCode: null
  }) async {
    Map<String, dynamic> result = await price(resellerCode);
    return result.length == 0 ? {} : result[domain] != null ? result[domain] : {};
  }

  /*
  * Get reseller price list for specified domains
  * API command - getResellerPrices
  * */
  Future<Map<String, dynamic>> priceDomains({
    @required List<String> domains,
    String resellerCode: null
  }) async {
    Map<String, dynamic> priceList = {};
    Map<String, dynamic> result = await price(resellerCode);

    result.forEach((key, value) {
      if (domains.contains(key)) {
        priceList[key] = value;
      }
    });

    return priceList;
  }

  /*
  * Create order for domain - add, transfer
  * API command - createDomainRegistrationOrder, createDomainTransferOrder
  * For registration domain use orderType - ImenaAPIConst.ORDER_TYPE_ADD
  * For transfer domain use orderType - ImenaAPIConst.ORDER_TYPE_TRANSFER
  * */
  Future<dynamic> order({
    @required String orderType,
    @required String clientCode,
    @required String domainName,
    int term: 1,
    String aeroId: null,
    String ensAuthKey: null,
    String patentNumber: null,
    String patentDate: null,
    String nicD: null
  }) async {
    String cmd = orderType == ImenaAPIConst.ORDER_TYPE_ADD ? ImenaAPIConst.COMMAND_CREATE_REGISTRATION_ORDER : ImenaAPIConst.COMMAND_CREATE_TRANSFER_ORDER;
    Map<String, dynamic> params = {
      "authToken": _authToken,
      "clientCode": clientCode,
      "domainName": domainName,
      "term": term,
      if (aeroId != null) "aeroId": aeroId,
      if (ensAuthKey != null) "ensAuthKey": ensAuthKey,
      if (patentNumber != null) "patentNumber": patentNumber,
      if (patentDate != null) "patentDate": patentDate,
      if (nicD != null) "nicD": nicD
    };

    await _exec(cmd, params);

    return !success ? -1 : _apiResult['serviceCode'];
  }

  /*
  * Create payment for operation, before payment for add, transfer, you must create order
  * ADD - paymentType = ImenaAPIConst.PAYMENT_TYPE_ADD
  * RENEW - paymentType = ImenaAPIConst.PAYMENT_TYPE_RENEW
  * TRANSFER - paymentType = ImenaAPIConst.PAYMENT_TYPE_TRANSFER
  * */
  Future<dynamic> payment({
    @required String paymentType,
    @required String serviceCode,
    int term: 1,
    currentStopDate: null
  }) async {
    String cmd;
    Map<String, dynamic> body = {
      "authToken": _authToken,
      "serviceCode": serviceCode,
      "term": term,
      if (currentStopDate != null) "currentStopDate": currentStopDate
    };

    switch (paymentType) {
      case ImenaAPIConst.PAYMENT_TYPE_ADD:
        cmd = ImenaAPIConst.COMMAND_CREATE_REGISTRATION_PAYMENT;
        break;
      case ImenaAPIConst.PAYMENT_TYPE_TRANSFER:
        cmd = ImenaAPIConst.COMMAND_CREATE_TRANSFER_PAYMENT;
        break;
      case ImenaAPIConst.PAYMENT_TYPE_RENEW:
        cmd = ImenaAPIConst.COMMAND_CREATE_RENEW_PAYMENT;
        break;
    }

    await _exec(cmd, body);

    return !success ? -1 : _apiResult['paymentId'];
  }

  /*
  * Renew domain
  * */
  Future<dynamic> renew({
    @required String serviceCode,
    @required String currentStopDate,
    int term: 1
  }) async {
    return payment(
        paymentType: ImenaAPIConst.PAYMENT_TYPE_RENEW,
        serviceCode: serviceCode,
        term: term,
        currentStopDate: currentStopDate
    );
  }

  /*
  * Add domain
  * */
  Future<dynamic> register({
    @required String serviceCode,
    int term: 1
  }) async {
    return payment(
        paymentType: ImenaAPIConst.PAYMENT_TYPE_ADD,
        serviceCode: serviceCode,
        term: term
    );
  }

  /*
  * Transfer domain
  * */
  Future<dynamic> transfer({
    @required String serviceCode,
    int term: 1
  }) async {
    return payment(
        paymentType: ImenaAPIConst.PAYMENT_TYPE_TRANSFER,
        serviceCode: serviceCode,
        term: term
    );
  }

  /*
  * Get payment status
  * */
  Future<Map<String, dynamic>> paymentStatus({@required String paymentId}) async {
    await _exec(ImenaAPIConst.COMMAND_PAYMENT_STATUS, {"authToken": this._authToken, "paymentId": paymentId});
    return !success ? {} : _apiResult;
  }

  /*
  * Delete unused orders
  * */
  Future<bool> deleteOrders({@required String serviceCode}) async {
    return await _exec(ImenaAPIConst.COMMAND_DELETE_ORDER, {"authToken": this._authToken, "serviceCode": serviceCode});
  }

  /*
  * Get auth code for transfer
  * */
  Future<String> getAuthCode({@required String serviceCode}) async {
    await _exec(ImenaAPIConst.COMMAND_GET_AUTH_CODE, {"authToken": this._authToken, "serviceCode": serviceCode});
    return !success ? "" : _apiResult['authCode'];
  }

  /*
  * Execute internal transfer (transfer from-to accounts inside imena)
  * */
  Future<bool> internalTransfer({
    @required String serviceCode,
    @required String authCode,
    @required String clientCode
  }) async {
    return await _exec(
        ImenaAPIConst.COMMAND_INTERNAL_TRANSFER, {"authToken": this._authToken, "serviceCode": serviceCode, "clientCode": clientCode, "authCode": authCode});
  }

  /*
  * Picks domain names for subsequent registration.
  * */
  Future<Map<String, dynamic>> pickDomain({
    @required List<String> names,
    @required List<String> zones,
    List<String> filter = const [],
    String resellerCode = null
  }) async {
    Map<String, dynamic> domainNames = {};
    await _exec(ImenaAPIConst.COMMAND_PICK_DOMAIN, {"authToken": this._authToken, "resellerCode": getResellerCode(resellerCode), "names": names, "domainTypes": zones});
    if (success) {
      _apiResult.forEach((elem) {
        String name = '${elem['domainName']}';

        if (filter.length == 0) {
          domainNames[name] = elem;
        } else {
          if (filter.contains(elem['domainNameStatus'])) {
            domainNames[name] = elem;
          }
        }
      });
    }
    return domainNames;
  }

  /*
  * Get reseller clients
  * */
  Future<Map<String, dynamic>> clients({
    int limit = 500,
    int offset = 0,
    String resellerCode = null
  }) async {
    Map<String, dynamic> clientList = {};
    await _exec(ImenaAPIConst.COMMAND_CLIENT_LIST, {"authToken": this._authToken, "resellerCode": getResellerCode(resellerCode), "limit": limit, "offset": offset});

    if (success) {
      _apiResult['list'].forEach((elem) {
        clientList[elem['clientName']] = elem;
      });
    }

    return clientList;
  }

  /*
  * Get client info
  * */
  Future<dynamic> clientInfo(String clientCode) async {
    await _exec(ImenaAPIConst.COMMAND_CLIENT_INFO, {"authToken": this._authToken, "clientCode": clientCode});
    return !success ? {} : _apiResult;
  }

  /*
  * Create client
  * */
  Future<String> createClient({
    @required String firstName,
    @required String middleName,
    @required String lastName,
    @required String msgLanguage,
    @required String clientType,
    @required bool isUaResident,
    @required Map<String, dynamic> contactData,
    @required Map<String, dynamic> legalData,
    String resellerCode = null
  }) async {

    await _exec(ImenaAPIConst.COMMAND_CREATE_CLIENT, {
      "authToken": this._authToken,
      "resellerCode": getResellerCode(resellerCode),
      "firstName": firstName,
      "middleName": middleName,
      "lastName": lastName,
      "messagesLanguage": msgLanguage,
      "clientType": clientType,
      "isUaResident": isUaResident,
      "contactData": contactData,
      "legalData": legalData
    });

    return !success ? "" : _apiResult["clientCode"].toString();
  }
}
