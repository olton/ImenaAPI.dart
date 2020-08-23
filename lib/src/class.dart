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

  dynamic getError(){
    return this.error;
  }

  dynamic getResult(){
    return this.result;
  }

  Future<bool> login(String login, String password) async {
    var result;

    this._login = login;
    this._password = password;

    result = await _exec(
        ImenaAPIConst.COMMAND_LOGIN, {"login": this._login, "password": this._password});

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

    result = await _exec(
        ImenaAPIConst.COMMAND_LOGIN, body);

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

    result = _exec(ImenaAPIConst.COMMAND_LOGOUT, {
      "authToken": this._authToken
    });

    if (!result) {
      return false;
    }

    this._login = '';
    this._password = '';
    this._authToken = '';

    return true;
  }

  Future<dynamic> tokenInfo() async {
    var result = await _exec(ImenaAPIConst.COMMAND_TOKEN_INFO, {
      "authToken": this._authToken
    });

    return !result ? false : this.result;
  }

  Future<dynamic> domains([int limit = 500, int offset = 0]) async {
    var result;

    result = await _exec(ImenaAPIConst.COMMAND_DOMAINS_LIST, {
      "authToken": this._authToken,
      "limit": limit,
      "offset": offset
    });

    return !result ? false : this.result['list'];
  }

  Future<dynamic> domainsTotal() async {
    var result;

    result = await _exec(ImenaAPIConst.COMMAND_DOMAINS_LIST, {
      "authToken": this._authToken,
      "limit": 1,
      "offset": 0
    });

    return !result ? false : this.result['total'];
  }
}
