part of imena;

class ImenaAPI {
  String version = "1.0.0";
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

  ImenaAPI(this.endpoint) {}

  String _transactionID() {
    return "${this.transPrefix}-${new DateTime.now().millisecondsSinceEpoch}-${this.transSuffix}";
  }

  Future<bool> _exec(cmd, [body = ""]) async {
    http.Response response;
    String trID = this._transactionID();
    Map<String, String> requestHeader = {
      'Content-Type': 'application/json',
      'X-ApiTransactionID': trID
    };
    Map<String, dynamic> requestBody = {
      "jsonrpc": "2.0",
      "id": trID,
      "method": cmd,
      "params": body
    };

    Debug.log(requestBody, "map", "Request");

    response = await http.post(this.endpoint,
        headers: requestHeader, body: json.encode(requestBody));

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

  /*
  * Authentication of reseller's user
  * API command - authenticateResellerUser
  * */
  Future<bool> login(String login, String password) async {
    var result;

    this._login = login;
    this._password = password;

    result = await _exec(ImenaAPIConst.COMMAND_LOGIN,
        {"login": this._login, "password": this._password});

    if (!result) {
      return false;
    }

    this._authToken = this.result['authToken'];

    return true;
  }

  Future<bool> secondAuth(code, [type = ImenaAPIConst.SECOND_AUTH_SMS]) async {
    var result;
    Map<String, dynamic> body = {
      "login": this._login,
      "password": this._password
    };

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

    return true;
  }

  String authToken() {
    return this._authToken;
  }

  /*
  * Invalidation of token (end of session)
  * API command - invalidateAuthToken
  * */
  Future<bool> logout() async {
    var result;

    result =
        _exec(ImenaAPIConst.COMMAND_LOGOUT, {"authToken": this._authToken});

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
    var result = await _exec(
        ImenaAPIConst.COMMAND_TOKEN_INFO, {"authToken": this._authToken});

    return !result ? false : this.result;
  }

  /*
  * Receiving the list of domain names accessible to the current user
  * API command - getDomainsList
  * */
  Future<Map<String, dynamic>> domains([int limit = 500, int offset = 0]) async {
    var result;
    Map<String, dynamic> domainList = {};

    result = await _exec(ImenaAPIConst.COMMAND_DOMAINS_LIST,
        {"authToken": this._authToken, "limit": limit, "offset": offset});

    if (result) {
      this.result['list'].forEach((elem){
        domainList.addAll({elem['domainName']: elem});
      });
    }

    return domainList;
  }

  /*
  * Get domains total on reseller account
  * */
  Future<int> domainsTotal() async {
    var result;

    result = await _exec(ImenaAPIConst.COMMAND_DOMAINS_LIST,
        {"authToken": this._authToken, "limit": 1, "offset": 0});

    return !result ? 0 : this.result['total'];
  }

  /*
  * Find domains by name
  * */
  Future<dynamic> domainsBy([filter = ""]) async {
    Map<String, dynamic> domainList = new Map();
    int limit = 500;
    int total = await domainsTotal();
    int pages;
    int i;
    var result;

    if (total == 0) {
      return false;
    }

    pages = (total / limit).ceil();

    for(i = 0; i < pages; i++) {
      result = await domains(limit, limit * i);

      if (i == 0 && result.length == 0) {
        print("empty");
        return domainList;
      }

      result.forEach((key, val){
        if (key.contains(filter))
          domainList.addAll({key: val});
      });
    }

    return domainList;
  }

  /*
  * Receiving the information on a domain name by service code
  * API command - getDomain
  * */
  Future<dynamic> domainInfo(serviceCode) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_DOMAIN_INFO, {
      "authToken": this._authToken,
      "serviceCode": serviceCode
    });

    return !result ? false : this.result;
  }

  /*
  * Receiving the short information on a domain by domain name
  * API command - getDomainInfoByName
  * */
  Future<dynamic> domainInfoShort(domainName) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_DOMAIN_INFO_SHORT, {
      "authToken": this._authToken,
      "domainName": domainName
    });

    return !result ? false : this.result;
  }

  /*
  * Get domain contacts by service code
  * */
  Future<dynamic> contacts(serviceCode) async{
    Map<String, dynamic> contactList = {};
    var result = await domainInfo(serviceCode);

    if (result != Future.value(false)) {
      this.result['contacts'].forEach((elem){
        contactList.addAll({elem["contactType"]: elem});
      });
    }

    return contactList;
  }

  /*
  * Get domain tag list
  * */
  Future<dynamic> tags(serviceCode) async{
    var result = await domainInfo(serviceCode);

    return result == Future.value(false) ? false : this.result['tagList'];
  }

  /*
  * Get domain nameservers
  * */
  Future<dynamic> nameservers(serviceCode) async{
    var result = await domainInfo(serviceCode);

    return result == Future.value(false) ? false : this.result['nameservers'];
  }

  /*
  * Get domain child nameservers
  * */
  Future<dynamic> childNameservers(serviceCode) async{
    var result = await domainInfo(serviceCode);

    return result == Future.value(false) ? false : this.result['childNameservers'];
  }

  /*
  * Set domain nameservers
  * API command - editDomainNameserversList
  * */
  Future<bool> setNS(String serviceCode, List<String> ns) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_SET_NS, {
      "authToken": this._authToken,
      "serviceCode": serviceCode,
      "list": ns
    });

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
      default: cmd = ImenaAPIConst.COMMAND_SET_NS_DEFAULT;
    }

    bool result = await _exec(cmd, {
      "authToken": this._authToken,
      "serviceCode": serviceCode
    });

    return result;
  }

  /*
  * Set preset nameservers for domain
  * API command - setDomainNameserversToDefault
  * */
  Future<bool> setDefaultNS(String serviceCode) async {
    bool result = await setNSPreset(serviceCode, ImenaAPIConst.HOSTING_TYPE_DEFAULTS);

    return result;
  }

  /*
  * Set preset nameservers for domain
  * API command - setDomainNameserversToMirohost
  * */
  Future<bool> setMirohostNS(String serviceCode) async {
    bool result = await setNSPreset(serviceCode, ImenaAPIConst.HOSTING_TYPE_MIROHOST);

    return result;
  }

  /*
  * Set preset nameservers for domain
  * API command - setDomainNameserversToDnshosting
  * */
  Future<bool> setDnshostingNS(String serviceCode) async {
    bool result = await setNSPreset(serviceCode, ImenaAPIConst.HOSTING_TYPE_DNS);

    return result;
  }

  Future<bool> addChildNS(serviceCode, host, ip) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_ADD_CHILD_NS, {
      "authToken": this._authToken,
      "serviceCode": serviceCode,
      "host": host,
      "ip": ip
    });

    return result;
  }

  Future<bool> deleteChildNS(serviceCode, host, ip) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_DEL_CHILD_NS, {
      "authToken": this._authToken,
      "serviceCode": serviceCode,
      "host": host,
      "ip": ip
    });

    return result;
  }

  /*
  * Editing the contact data of a domain name by serviceCode and contactType
  * */
  Future<bool> setContact(String serviceCode, String contactType, Map<String, String> contactData) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_UPD_CONTACT, {
      "authToken": this._authToken,
      "serviceCode": serviceCode,
      "contactType": contactType,
      "contact": contactData
    });

    return result;
  }

  Future<bool> setPrivacy(serviceCode, [disclose = false]) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_SET_PRIVACY, {
      "authToken": this._authToken,
      "serviceCode": serviceCode,
      "whoisPrivacy": !disclose
    });

    return result;
  }

  /*
  * Get reseller balance info
  * API command - getResellerBalance
  * */
  Future<dynamic> balanceInfo(resellerCode) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_RESELLER_BALANCE, {
      "authToken": this._authToken,
      "resellerCode": resellerCode
    });

    return !result ? false : this.result;
  }

  /*
  * Get reseller balance
  * API command - getResellerBalance
  * */
  Future<dynamic> balance(resellerCode) async {
    dynamic result = await balanceInfo(resellerCode);

    return result == Future.value(false) ? false : this.result['balance'];
  }

  /*
  * Get reseller credit
  * API command - getResellerBalance
  * */
  Future<dynamic> credit(resellerCode) async {
    dynamic result = await balanceInfo(resellerCode);

    return result == Future.value(false) ? false : this.result['creditLimit'];
  }

  /*
  * Get reseller price list
  * API command - getResellerPrices
  * */
  Future<Map<String, dynamic>> price(String resellerCode) async {
    Map<String, dynamic> priceList = {};
    bool result = await _exec(ImenaAPIConst.COMMAND_RESELLER_PRICES, {
      "authToken": this._authToken,
      "resellerCode": resellerCode
    });

    if (result) {
      this.result.forEach((elem){
        priceList.addAll({elem['domain']: elem});
      });
    }

    return priceList;
  }

  /*
  * Get reseller price list for specified domain
  * API command - getResellerPrices
  * */
  Future<Map<String, dynamic>> priceDomain(String resellerCode, String domain) async {
    Map<String, dynamic> result = await price(resellerCode);
    return result.length == 0 ? {} : result[domain];
  }

  /*
  * Get reseller price list for specified domains
  * API command - getResellerPrices
  * */
  Future<Map<String, dynamic>> priceDomains(String resellerCode, List<String> domains) async {
    Map<String, dynamic> priceList = {};
    Map<String, dynamic> result = await price(resellerCode);

    result.forEach((key, value) {
      if (domains.contains(key)) {
        priceList.addAll({key: value});
      }
    });

    return priceList;
  }
}
