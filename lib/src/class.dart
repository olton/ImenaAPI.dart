part of imena;

class ImenaAPI {
  String version = "1.0.0";
  String endpoint = "";
  String transPrefix = "API";
  String transSuffix = "DART";
  bool isLogged = false;

  String rawResponse;
  var response;
  var error;
  var result;

  String _authToken = null;
  bool debugger;

  ImenaAPI(this.endpoint, [this.debugger = true]) {}

  void debug(val, [as = "default", before = ""]) {
    if (this.debugger == false) {
      return ;
    }
    if (before != "") {
      print("\n$before");
    }
    switch (as) {
      case "map":
        print(new JsonEncoder.withIndent("  ").convert(val));
        break;
      default:
        print(val);
    }
  }

  String _transactionID() {
    return "${this.transPrefix}-${new DateTime.now().millisecondsSinceEpoch}-${this.transSuffix}";
  }

  Future<bool> _exec(cmd, body) async {
    var response;
    String trID = this._transactionID();
    Map<String, String> requestHeader = {
      'Content-Type': 'application/json',
      'X-ApiTransactionID': trID
    };
    Map<String, dynamic> requestBody = {
      "jsonrpc": "2.0",
      "id": trID,
      "params": body,
      "method": cmd
    };

    if (cmd != ImenaAPIConst.COMMAND_LOGIN) {
      requestBody.addAll({"authToken": this._authToken});
    }

    debug(requestBody, "map", "Request");

    response = await http.post(this.endpoint,
        headers: requestHeader, body: json.encode(requestBody));

    this.rawResponse = response.body;
    this.response = json.decode(response.body);

    this.error = this.response['error'];
    this.result = this.response['result'];

    return this.error == null;
  }

  Future<bool> Login(String login, String password) async {
    var result = await _exec(
        ImenaAPIConst.COMMAND_LOGIN, {"login": login, "password": password});

    if (result == Future.value(false)) {
      return false;
    }

    this._authToken = this.result['authToken'];

    return true;
  }

  String authToken() {
    return this._authToken;
  }
}
