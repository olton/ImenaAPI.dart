import 'dart:convert';
import 'dart:io';

import 'package:imena/imena.dart';

void main() async {
  const endpoint = "https://rpc.imena.devua.net/v1/";
  const login = "";
  const password = "";

  ImenaAPI api = new ImenaAPI(endpoint);

  var result, token;

  result = await api.login(login, password);

  if (result == Future.value(false)) {
    Debug.log("\nCan't login to API server!\n");
    exit(0);
  }

  Debug.log("\nLogin successful, authToken is: ${api.authToken()}");
  Debug.log("Get token info...\n");

  token = await api.tokenInfo();
  if (token == false) {
    Debug.log("\nCan't get token info!\n");
    Debug.log(api.getError());
    exit(0);
  }
  Debug.log(token, "map", "Token info");

}
