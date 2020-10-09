import 'dart:io';

import 'package:imena/imena.dart';
import 'auth.dart';

void main() async {
  ImenaAPI api = ImenaAPI(API_ENDPOINT);

  var result, domain;
  const domainName = "pimenov.com.ua";
  // const serviceCode = "123";
  const serviceCode = SERVICE_CODE;

  result = await api.login(login: API_LOGIN, password: API_PASSWORD);

  if (!result) {
    Debug.log("\nCan't login to API server!\n");
    exit(0);
  }

  Debug.log("\nLogin successful, authToken is: ${api.token}");

  Debug.log("\nGet dns info for $domainName...\n");

  domain = await api.dnsInfo(serviceCode);
  if (!api.success) {
    Debug.log("\nCan't get domain list or list empty!\n");
    Debug.log(api.error);
    exit(0);
  }
  Debug.log(domain, "map", "Domain info");
}
