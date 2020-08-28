import 'dart:io';

import 'package:imena/imena.dart';
import 'auth.dart';

void main() async {
  ImenaAPI api = ImenaAPI(API_ENDPOINT);

  var result, balance;
  const resellerCode = RESELLER_CODE;

  result = await api.login(login: API_LOGIN, password: API_PASSWORD);

  if (!result) {
    Debug.log("\nCan't login to API server!\n");
    exit(0);
  }

  Debug.log("\nLogin successful, authToken is: ${api.token}");
  Debug.log("Get reseller balance...\n");

  balance = await api.balanceInfo(resellerCode);
  if (!api.success) {
    Debug.log("\nCan't get reseller balance info!\n");
    Debug.log(api.error);
    exit(0);
  }
  Debug.log(balance, "map", "Balance info");

  balance = await api.balance(resellerCode);
  if (!api.success) {
    Debug.log("\nCan't get reseller balance!\n");
    Debug.log(api.error);
    exit(0);
  }
  Debug.log(balance, "map", "Balance");

  balance = await api.credit(resellerCode);
  if (!api.success) {
    Debug.log("\nCan't get reseller credit!\n");
    Debug.log(api.error);
    exit(0);
  }
  Debug.log(balance, "map", "Credit");

}
