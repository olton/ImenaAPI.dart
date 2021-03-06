import 'dart:io';

import 'package:imena/imena.dart';
import 'auth.dart';

void main() async {
  ImenaAPI api = ImenaAPI(API_ENDPOINT);

  var result, token;

  result = await api.login(login: API_LOGIN, password: API_PASSWORD);

  if (!result) {
    Debug.log("\nCan't login to API server!\n");
    exit(0);
  }

  Debug.log("\nLogin successful, authToken is: ${api.token}");
  Debug.log("Get token info...\n");

  token = await api.tokenInfo();
  if (!api.success) {
    Debug.log("\nCan't get token info!\n");
    Debug.log(api.error);
    exit(0);
  }
  Debug.log(token, "map", "Token info");

}
