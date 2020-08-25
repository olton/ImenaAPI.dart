import 'dart:io';

import 'package:imena/imena.dart';
import 'auth.dart';

void main() async {
  ImenaAPI api = new ImenaAPI(API_ENDPOINT);

  var result, token;

  result = await api.login(API_LOGIN, API_PASSWORD);

  if (!result) {
    Debug.log("\nCan't login to API server!\n");
    exit(0);
  }

  Debug.log("\nLogin successful, authToken is: ${api.authToken}");
  Debug.log("Get token info...\n");

  token = await api.tokenInfo();
  if (token == Future.value(false)) {
    Debug.log("\nCan't get token info!\n");
    Debug.log(api.getError());
    exit(0);
  }
  Debug.log(token, "map", "Token info");

}
