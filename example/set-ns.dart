import 'dart:io';

import 'package:imena/imena.dart';
import 'auth.dart';

void main() async {
  ImenaAPI api = ImenaAPI(API_ENDPOINT);

  var result, ns, domain;
  const domainName = "cctld.org.ua";
  const serviceCode = "800190";
  List<String> nsList = [
    "nsa4.srv53.net",
    "nsa2.srv53.com",
    "nsa1.srv53.org"
  ];

  result = await api.login(login: API_LOGIN, password: API_PASSWORD);

  if (!result) {
    Debug.log("\nCan't login to API server!\n");
    exit(0);
  }

  Debug.log("\nLogin successful, authToken is: ${api.authToken}");

  Debug.log("\nSet ns to ... for $domainName...\n");

  ns = await api.setNS(serviceCode: serviceCode, ns: nsList);
  if (!ns) {
    Debug.log("\nCan't set ns!\n");
    Debug.log(api.getError());
    exit(0);
  }
  domain = await api.nameservers(serviceCode);
  Debug.log(domain, "map", "Domain ns");
}
