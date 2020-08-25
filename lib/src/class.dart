part of imena;

class ImenaAPI {
  String endpoint = "";
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

  ImenaAPI(this.endpoint) {}

  String _transactionID() {
    return "${this.transPrefix}-${new DateTime.now().millisecondsSinceEpoch}-${this.transSuffix}";
  }

  Future<bool> _exec(cmd, [body = ""]) async {
    http.Response response;
    String trID = this._transactionID();
    Map<String, String> requestHeader = {'Content-Type': 'application/json', 'X-ApiTransactionID': trID};
    Map<String, dynamic> requestBody = {"jsonrpc": "2.0", "id": trID, "method": cmd, "params": body};

    response = await http.post(this.endpoint, headers: requestHeader, body: json.encode(requestBody));

    this.rawResponse = response.body;
    this.response = json.decode(response.body);

    this.error = this.response['error'];
    this.result = this.response['result'];

    return this.error == null;
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
  Future<bool> login(String login, String password) async {
    bool result;

    this._login = login;
    this._password = password;

    result = await _exec(ImenaAPIConst.COMMAND_LOGIN, {"login": this._login, "password": this._password});

    if (!result) {
      return false;
    }

    this._authToken = this.result['authToken'];

    await tokenInfo();

    return true;
  }

  Future<bool> secondAuth(code, [type = ImenaAPIConst.SECOND_AUTH_SMS]) async {
    bool result;
    Map<String, dynamic> body = {"login": this._login, "password": this._password};

    if (type == ImenaAPIConst.SECOND_AUTH_SMS) {
      body.addAll({"smsCode": code});
    } else {
      body.addAll({"gaCode": code});
    }

    result = await _exec(ImenaAPIConst.COMMAND_LOGIN, body);

    if (!result) {
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
    bool result = await _exec(ImenaAPIConst.COMMAND_LOGOUT, {"authToken": this._authToken});

    if (!result) {
      return false;
    }

    this._login = '';
    this._password = '';
    this._authToken = '';

    return true;
  }

  /*
  * Receiving information about the current session and authenticated user by authToken
  * API command - getAuthTokenInfo
  * */
  Future<dynamic> tokenInfo() async {
    bool result = await _exec(ImenaAPIConst.COMMAND_TOKEN_INFO, {"authToken": this._authToken});

    this._info = result ? this.result : {};

    return !result ? false : this.result;
  }

  Map<String, dynamic> getInfo() {
    return this._info;
  }

  /*
  * Receiving the list of domain names accessible to the current user
  * API command - getDomainsList
  * */
  Future<Map<String, dynamic>> domains([int limit = 500, int offset = 0]) async {
    Map<String, dynamic> domainList = {};
    bool result = await _exec(ImenaAPIConst.COMMAND_DOMAINS_LIST, {"authToken": this._authToken, "limit": limit, "offset": offset});

    if (result) {
      this.result['list'].forEach((elem) {
        domainList.addAll({elem['domainName']: elem});
      });
    }

    return domainList;
  }

  /*
  * Get domains total on reseller account
  * */
  Future<int> domainsTotal() async {
    bool result = await _exec(ImenaAPIConst.COMMAND_DOMAINS_LIST, {"authToken": this._authToken, "limit": 1, "offset": 0});

    return !result ? 0 : this.result['total'];
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
      result = await domains(limit, limit * i);

      if (i == 0 && result.length == 0) {
        return domainList;
      }

      result.forEach((key, val) {
        if (key.contains(filter)) domainList.addAll({key: val});
      });
    }

    return domainList;
  }

  /*
  * Receiving the information on a domain name by service code
  * API command - getDomain
  * */
  Future<dynamic> domainInfo(String serviceCode) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_DOMAIN_INFO, {"authToken": this._authToken, "serviceCode": serviceCode});

    return !result ? false : this.result;
  }

  /*
  * Receiving the short information on a domain by domain name
  * API command - getDomainInfoByName
  * */
  Future<dynamic> domainInfoShort(String domainName) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_DOMAIN_INFO_SHORT, {"authToken": this._authToken, "domainName": domainName});

    return !result ? false : this.result;
  }

  /*
  * Get domain contacts by service code
  * */
  Future<dynamic> contacts(String serviceCode) async {
    Map<String, dynamic> contactList = {};
    dynamic result = await domainInfo(serviceCode);

    if (result != Future.value(false)) {
      this.result['contacts'].forEach((elem) {
        contactList.addAll({elem["contactType"]: elem});
      });
    }

    return contactList;
  }

  /*
  * Get domain tag list
  * */
  Future<dynamic> tags(String serviceCode) async {
    dynamic result = await domainInfo(serviceCode);

    return result == Future.value(false) ? false : this.result['tagList'];
  }

  /*
  * Get domain nameservers
  * */
  Future<dynamic> nameservers(String serviceCode) async {
    dynamic result = await domainInfo(serviceCode);

    return result == Future.value(false) ? false : this.result['nameservers'];
  }

  /*
  * Get domain child nameservers
  * */
  Future<dynamic> childNameservers(String serviceCode) async {
    dynamic result = await domainInfo(serviceCode);

    return result == Future.value(false) ? false : this.result['childNameservers'];
  }

  /*
  * Set domain nameservers
  * API command - editDomainNameserversList
  * */
  Future<bool> setNS(String serviceCode, List<String> ns) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_SET_NS, {"authToken": this._authToken, "serviceCode": serviceCode, "list": ns});

    return result;
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

    bool result = await _exec(cmd, {"authToken": this._authToken, "serviceCode": serviceCode});

    return result;
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

  Future<bool> addChildNS(serviceCode, host, ip) async {
    return await _exec(ImenaAPIConst.COMMAND_ADD_CHILD_NS, {"authToken": this._authToken, "serviceCode": serviceCode, "host": host, "ip": ip});
  }

  Future<bool> deleteChildNS(String serviceCode, String host, String ip) async {
    return await _exec(ImenaAPIConst.COMMAND_DEL_CHILD_NS, {"authToken": this._authToken, "serviceCode": serviceCode, "host": host, "ip": ip});
  }

  /*
  * Editing the contact data of a domain name by serviceCode and contactType
  * */
  Future<bool> setContact(String serviceCode, String contactType, Map<String, String> contactData) async {
    return await _exec(
        ImenaAPIConst.COMMAND_UPD_CONTACT, {"authToken": this._authToken, "serviceCode": serviceCode, "contactType": contactType, "contact": contactData});
  }

  Future<bool> setPrivacy(String serviceCode, [bool disclose = false]) async {
    return await _exec(ImenaAPIConst.COMMAND_SET_PRIVACY, {"authToken": this._authToken, "serviceCode": serviceCode, "whoisPrivacy": !disclose});
  }

  /*
  * Get reseller balance info
  * API command - getResellerBalance
  * */
  Future<dynamic> balanceInfo([String resellerCode = null]) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_RESELLER_BALANCE, {"authToken": this._authToken, "resellerCode": getResellerCode(resellerCode)});

    return !result ? false : this.result;
  }

  /*
  * Get reseller balance
  * API command - getResellerBalance
  * */
  Future<dynamic> balance([String resellerCode = null]) async {
    dynamic result = await balanceInfo(resellerCode);

    return result == Future.value(false) ? false : this.result['balance'];
  }

  /*
  * Get reseller credit
  * API command - getResellerBalance
  * */
  Future<dynamic> credit([String resellerCode = null]) async {
    dynamic result = await balanceInfo(resellerCode);

    return result == Future.value(false) ? false : this.result['creditLimit'];
  }

  /*
  * Get reseller price list
  * API command - getResellerPrices
  * */
  Future<Map<String, dynamic>> price([String resellerCode = null]) async {
    Map<String, dynamic> priceList = {};
    bool result = await _exec(ImenaAPIConst.COMMAND_RESELLER_PRICES, {"authToken": this._authToken, "resellerCode": getResellerCode(resellerCode)});

    if (result) {
      this.result.forEach((elem) {
        priceList.addAll({elem['domain']: elem});
      });
    }

    return priceList;
  }

  /*
  * Get reseller price list for specified domain
  * API command - getResellerPrices
  * */
  Future<Map<String, dynamic>> priceDomain(String domain, [String resellerCode = null]) async {
    Map<String, dynamic> result = await price(resellerCode);
    return result.length == 0 ? {} : result[domain];
  }

  /*
  * Get reseller price list for specified domains
  * API command - getResellerPrices
  * */
  Future<Map<String, dynamic>> priceDomains(List<String> domains, [String resellerCode = null]) async {
    Map<String, dynamic> priceList = {};
    Map<String, dynamic> result = await price(resellerCode);

    result.forEach((key, value) {
      if (domains.contains(key)) {
        priceList.addAll({key: value});
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
  Future<dynamic> order(String orderType, String clientCode, String domainName,
      [int term = 1, String aeroId = null, String ensAuthKey = null, String patentNumber = null, String patentDate = null, String nicD = null]) async {
    String cmd = orderType == ImenaAPIConst.ORDER_TYPE_ADD ? ImenaAPIConst.COMMAND_CREATE_REGISTRATION_ORDER : ImenaAPIConst.COMMAND_CREATE_TRANSFER_ORDER;
    Map<String, dynamic> params = {"authToken": this._authToken, "clientCode": clientCode, "domainName": domainName, "term": term};

    if (aeroId != null) {
      params.addAll({"aeroId": aeroId});
    }
    if (ensAuthKey != null) {
      params.addAll({"ensAuthKey": ensAuthKey});
    }
    if (patentNumber != null) {
      params.addAll({"patentNumber": patentNumber});
    }
    if (patentDate != null) {
      params.addAll({"patentDate": patentDate});
    }
    if (nicD != null) {
      params.addAll({"nicId": nicD});
    }

    bool result = await _exec(cmd, params);

    return !result ? false : this.result['serviceCode'];
  }

  /*
  * Create payment for operation, before payment for add, transfer, you must create order
  * ADD - paymentType = ImenaAPIConst.PAYMENT_TYPE_ADD
  * RENEW - paymentType = ImenaAPIConst.PAYMENT_TYPE_RENEW
  * TRANSFER - paymentType = ImenaAPIConst.PAYMENT_TYPE_TRANSFER
  * */
  Future<dynamic> payment(String paymentType, String serviceCode, [int term = 1]) async {
    String cmd;

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

    dynamic result = await _exec(cmd, {"authToken": this._authToken, "serviceCode": serviceCode, "term": term});

    return result == Future.value(false) ? false : this.result['paymentId'];
  }

  /*
  * Renew domain
  * */
  Future<dynamic> renew(String serviceCode, String stopDate, [int term = 1]) async {
    return payment(ImenaAPIConst.PAYMENT_TYPE_RENEW, serviceCode, term);
  }

  /*
  * Add domain
  * */
  Future<dynamic> add(String serviceCode, [int term = 1]) async {
    return payment(ImenaAPIConst.PAYMENT_TYPE_ADD, serviceCode, term);
  }

  /*
  * Transfer domain
  * */
  Future<dynamic> transfer(String serviceCode, [int term = 1]) async {
    return payment(ImenaAPIConst.PAYMENT_TYPE_TRANSFER, serviceCode, term);
  }

  /*
  * Get payment status
  * */
  Future<dynamic> paymentStatus(String paymentId) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_PAYMENT_STATUS, {"authToken": this._authToken, "paymentId": paymentId});

    return result == Future.value(false) ? false : this.result;
  }

  /*
  * Delete unused orders
  * */
  Future<bool> deleteOrders(String serviceCode) async {
    return await _exec(ImenaAPIConst.COMMAND_DELETE_ORDER, {"authToken": this._authToken, "serviceCode": serviceCode});
  }

  /*
  * Get auth code for transfer
  * */
  Future<String> getAuthCode(String serviceCode) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_GET_AUTH_CODE, {"authToken": this._authToken, "serviceCode": serviceCode});

    return !result ? "" : this.result['authCode'];
  }

  /*
  * Execute internal transfer (transfer from-to accounts inside imena)
  * */
  Future<bool> internal(String serviceCode, String authCode, String clientCode) async {
    return await _exec(
        ImenaAPIConst.COMMAND_INTERNAL_TRANSFER, {"authToken": this._authToken, "serviceCode": serviceCode, "clientCode": clientCode, "authCode": authCode});
  }

  /*
  * Picks domain names for subsequent registration.
  * */
  Future<Map<String, dynamic>> pickDomain(List<String> names, List<String> zones, {List<String> filter = const [], String resellerCode = null}) async {
    Map<String, dynamic> domainNames = {};
    bool result =
        await _exec(ImenaAPIConst.COMMAND_PICK_DOMAIN, {"authToken": this._authToken, "resellerCode": getResellerCode(resellerCode), "names": names, "domainTypes": zones});
    if (result) {
      this.result.forEach((elem) {
        String name = '${elem['domainName']}';

        if (filter.length == 0) {
          domainNames.addAll({name: elem});
        } else {
          if (filter.contains(elem['domainNameStatus'])) {
            domainNames.addAll({name: elem});
          }
        }
      });
    }
    return domainNames;
  }

  /*
  * Get reseller clients
  * */
  Future<Map<String, dynamic>> clients([int limit = 500, int offset = 0, String resellerCode = null]) async {
    Map<String, dynamic> clientList = {};
    bool result =
        await _exec(ImenaAPIConst.COMMAND_CLIENT_LIST, {"authToken": this._authToken, "resellerCode": getResellerCode(resellerCode), "limit": limit, "offset": offset});

    if (result) {
      this.result['list'].forEach((elem) {
        clientList.addAll({elem['clientName']: elem});
      });
    }

    return clientList;
  }

  /*
  * Get client info
  * */
  Future<dynamic> clientInfo(String clientCode) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_CLIENT_INFO, {"authToken": this._authToken, "clientCode": clientCode});

    return !result ? false : this.result;
  }

  /*
  * Create client
  * */
  Future<dynamic> createClient(String firstName, String middleName, String lastName, String msgLanguage, String clientType,
      bool isUaResident, Map<String, dynamic> contactData, Map<String, dynamic> legalData, [String resellerCode = null]) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_CREATE_CLIENT, {
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

    return !result ? false : this.result["clientCode"];
  }
}
