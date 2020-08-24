import 'dart:convert';
import 'dart:io';

import 'package:imena/imena.dart';
import 'auth.dart';

void main() async {
  ImenaAPI api = new ImenaAPI(API_ENDPOINT);

  var result, balance;
  const resellerCode = "DG3789";

  result = await api.login(API_LOGIN, API_PASSWORD);

  if (!result) {
    Debug.log("\nCan't login to API server!\n");
    exit(0);
  }

  Debug.log("\nLogin successful, authToken is: ${api.authToken()}");
  Debug.log("Get reseller balance...\n");

  balance = await api.balanceInfo(resellerCode);
  if (balance == Future.value(false)) {
    Debug.log("\nCan't get reseller balance info!\n");
    Debug.log(api.getError());
    exit(0);
  }
  Debug.log(balance, "map", "Balance info");

  balance = await api.balance(resellerCode);
  if (balance == Future.value(false)) {
    Debug.log("\nCan't get reseller balance!\n");
    Debug.log(api.getError());
    exit(0);
  }
  Debug.log(balance, "map", "Balance");

  balance = await api.credit(resellerCode);
  if (balance == Future.value(false)) {
    Debug.log("\nCan't get reseller credit!\n");
    Debug.log(api.getError());
    exit(0);
  }
  Debug.log(balance, "map", "Credit");

}
