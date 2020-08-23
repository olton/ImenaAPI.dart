import 'dart:convert';
import 'dart:io';

import 'package:imena/imena.dart';
import 'auth.dart';

void main() async {
  ImenaAPI api = new ImenaAPI(API_ENDPOINT);

  var result, domain;
  const domainName = "pimenov.com.ua";
  const serviceCode = "815633";

  result = await api.login(API_LOGIN, API_PASSWORD);

  if (!result) {
    Debug.log("\nCan't login to API server!\n");
    exit(0);
  }

  Debug.log("\nLogin successful, authToken is: ${api.authToken()}");

  Debug.log("\nGet domain info for $domainName...\n");

  domain = await api.domainInfo(serviceCode);
  if (domain == Future.value(false)) {
    Debug.log("\nCan't get domain list or list empty!\n");
    Debug.log(api.getError());
    exit(0);
  }
  Debug.log(domain, "map", "Domain info");
}
