import 'dart:io';

import 'package:imena/imena.dart';
import 'auth.dart';

void main() async {
  ImenaAPI api = ImenaAPI(API_ENDPOINT);

  var result;
  dynamic domain;
  const domainName = "pimenov.com.ua";
  const serviceCode = SERVICE_CODE;

  result = await api.login(API_LOGIN, API_PASSWORD);

  if (!result) {
    Debug.log("\nCan't login to API server!\n");
    exit(0);
  }

  Debug.log("\nLogin successful, authToken is: ${api.authToken}");

  Debug.log("\nGet domain contacts for $domainName...\n");

  domain = await api.contacts(serviceCode);

  print(domain.runtimeType);
  print(Future.value(false).runtimeType);

  if (!api.success) {
    Debug.log("\nCan't get domain!\n");
    Debug.log(api.getError());
    exit(0);
  }
  Debug.log(domain, "map", "Domain info");
}
