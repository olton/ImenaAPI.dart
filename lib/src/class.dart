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

  Future<dynamic> tokenInfo() async {
    var result = await _exec(
        ImenaAPIConst.COMMAND_TOKEN_INFO, {"authToken": this._authToken});

    return !result ? false : this.result;
  }

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

  Future<int> domainsTotal() async {
    var result;

    result = await _exec(ImenaAPIConst.COMMAND_DOMAINS_LIST,
        {"authToken": this._authToken, "limit": 1, "offset": 0});

    return !result ? 0 : this.result['total'];
  }

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

  Future<dynamic> domainInfo(serviceCode) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_DOMAIN_INFO, {
      "authToken": this._authToken,
      "serviceCode": serviceCode
    });

    return !result ? false : this.result;
  }

  Future<dynamic> domainInfoShort(domainName) async {
    bool result = await _exec(ImenaAPIConst.COMMAND_DOMAIN_INFO_SHORT, {
      "authToken": this._authToken,
      "domainName": domainName
    });

    return !result ? false : this.result;
  }

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

  Future<dynamic> tags(serviceCode) async{
    var result = await domainInfo(serviceCode);

    return result == Future.value(false) ? false : this.result['tagList'];
  }

  Future<dynamic> nameservers(serviceCode) async{
    var result = await domainInfo(serviceCode);

    return result == Future.value(false) ? false : this.result['nameservers'];
  }

  Future<dynamic> childNameservers(serviceCode) async{
    var result = await domainInfo(serviceCode);

    return result == Future.value(false) ? false : this.result['childNameservers'];
  }
}
