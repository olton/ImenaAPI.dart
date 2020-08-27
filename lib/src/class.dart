part of imena;

class ImenaAPI {
  String _endpoint = "";
  String transPrefix = "API";
  String transSuffix = "DART";

  String rawResponse;
  var response;
  var error;
  var result;

  String _authToken = null;
  String _login = "";
  String _password = "";
  Map<String, dynamic> _info = {};
  bool success = false;

  ImenaAPI(this._endpoint);

  String get endpoint => this._endpoint;
  set endpoint(str) => this._endpoint = str;

  String _transactionID() {
    return "${this.transPrefix}-${new DateTime.now().millisecondsSinceEpoch}-${this.transSuffix}";
  }

  Future<bool> _exec(cmd, [body = ""]) async {
    String trID = this._transactionID();
    Map<String, String> requestHeader = {'Content-Type': 'application/json', 'X-ApiTransactionID': trID};
    Map<String, dynamic> requestBody = {"jsonrpc": "2.0", "id": trID, "method": cmd, "params": body};

    success = false;

    try {
      http.Response httpResponse = await http.post(
          endpoint, headers: requestHeader, body: json.encode(requestBody));

      rawResponse = httpResponse.body;
      response = json.decode(httpResponse.body);

      error = response['error'];
      result = response['result'];

      success = this.error == null;
    } catch (e) {
      print(e);
    }

    return success;
  }

  dynamic getError() {
    return this.error;
  }

  dynamic getResult() {
    return this.result;
  }

  String getResellerCode([String resellerCode = null]){
    if (resellerCode == null) {
      if (this._info.length == 0 || this._info['user']['resellerCode'] == null) {
        throw Exception("This operation required resellerCode!");
      }
      resellerCode = this._info['user']['resellerCode'];
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
    this._login = login;
    this._password = password;

    Map<String, String> body = {
      "login": this._login,
      "password": this._password,
      if (smsCode != '') "smsCode": smsCode,
      if (gaCode != '') "gaCode": gaCode
    };

    await _exec(ImenaAPIConst.COMMAND_LOGIN, body);

    if (!success) {
      return false;
    }

    _authToken = result['authToken'];

    await tokenInfo();

    return true;
  }

  Future<bool> secondAuth({
    String smsCode: '',
    String gaCode: ''
  }) async {
    Map<String, String> body = {
      "login": this._login,
      "password": this._password,
      if (smsCode != '') "smsCode": smsCode,
      if (gaCode != '') "gaCode": gaCode
    };

    await _exec(ImenaAPIConst.COMMAND_LOGIN, body);

    if (!success) {
      return false;
    }

    this._authToken = this.result['authToken'];

    await tokenInfo();

    return true;
  }

  String get authToken => this._authToken;

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
    this._info = null;

    return true;
  }

  /*
  * Receiving information about the current session and authenticated user by authToken
  * API command - getAuthTokenInfo
  * */
  Future<Map<String, dynamic>> tokenInfo() async {
    await _exec(ImenaAPIConst.COMMAND_TOKEN_INFO, {"authToken": this._authToken});
    this._info = success ? this.result : {};
    return !success ? {} : this.result;
  }

  Map<String, dynamic> getInfo() {
    return this._info;
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
      this.result['list'].forEach((elem) {
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
    return !success ? 0 : result['total'];
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
    return !success ? {} : result;
  }

  /*
  * Receiving the short information on a domain by domain name
  * API command - getDomainInfoByName
  * */
  Future<Map<String, dynamic>> domainInfoShort(String domainName) async {
    await _exec(ImenaAPIConst.COMMAND_DOMAIN_INFO_SHORT, {"authToken": this._authToken, "domainName": domainName});
    return !success ? {} : this.result;
  }

  /*
  * Get domain contacts by service code
  * */
  Future<dynamic> contacts(String serviceCode) async {
    Map<String, dynamic> contactList = {};

    await domainInfo(serviceCode);

    if (success) {
      result['contacts'].forEach((elem) {
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
    return !success ? [] : this.result['tagList'];
  }

  /*
  * Get domain nameservers
  * */
  Future<List<dynamic>> nameservers(String serviceCode) async {
    await domainInfo(serviceCode);
    return !success ? [] : this.result['nameservers'];
  }

  /*
  * Get domain child nameservers
  * */
  Future<List<dynamic>> childNameservers(String serviceCode) async {
    await domainInfo(serviceCode);
    return !success ? [] : this.result['childNameservers'];
  }

  /*
  * Set domain nameservers
  * API command - editDomainNameserversList
  * */
  Future<bool> setNS({
    @required String serviceCode,
    @required List<String> ns
  }) async {
    await _exec(ImenaAPIConst.COMMAND_SET_NS, {"authToken": this._authToken, "serviceCode": serviceCode, "list": ns});
    return success;
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
    return !success ? {} : this.result;
  }

  /*
  * Get reseller balance
  * API command - getResellerBalance
  * */
  Future<dynamic> balance([String resellerCode]) async {
    await balanceInfo(resellerCode);
    return !success ? 0 : this.result['balance'];
  }

  /*
  * Get reseller credit
  * API command - getResellerBalance
  * */
  Future<dynamic> credit([String resellerCode]) async {
    await balanceInfo(resellerCode);
    return !success ? 0 : this.result['creditLimit'];
  }

  /*
  * Get reseller price list
  * API command - getResellerPrices
  * */
  Future<Map<String, dynamic>> price([String resellerCode]) async {
    Map<String, dynamic> priceList = {};
    await _exec(ImenaAPIConst.COMMAND_RESELLER_PRICES, {"authToken": this._authToken, "resellerCode": getResellerCode(resellerCode)});

    if (success) {
      result.forEach((elem) {
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
    return result.length == 0 ? {} : result[domain];
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
      "authToken": this._authToken,
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

    return !success ? -1 : this.result['serviceCode'];
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
      "authToken": this._authToken,
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

    return !success ? -1 : this.result['paymentId'];
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
    return !success ? {} : this.result;
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
    return !success ? "" : this.result['authCode'];
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
      result.forEach((elem) {
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
      result['list'].forEach((elem) {
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
    return !success ? {} : this.result;
  }

  /*
  * Create client
  * */
  Future<dynamic> createClient({
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

    return !success ? -1 : this.result["clientCode"];
  }
}
