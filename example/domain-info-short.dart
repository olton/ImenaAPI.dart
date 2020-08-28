import 'dart:io';

import 'package:imena/imena.dart';
import 'auth.dart';

void main() async {
  ImenaAPI api = ImenaAPI(API_ENDPOINT);

  var result, domain;
  const domainName = "pimenov.com.ua";
  const domainNameOut = "badko.org.ua";

  result = await api.login(login: API_LOGIN, password: API_PASSWORD);

  if (!result) {
    Debug.log("Can't login to API server!\n");
    exit(0);
  }

  Debug.log("Login successful, authToken is: ${api.token}\n");

  Debug.log("Get domain info for $domainName...");
  domain = await api.domainInfoShort(domainName);
  if (!api.success) {
    Debug.log("Can't get domain info for $domainName!");
    Debug.log(api.error);
    exit(0);
  }
  Debug.log(domain, "map", "Domain info");

  Debug.log("Get domain info for $domainNameOut...");
  domain = await api.domainInfoShort(domainNameOut);
  if (!api.success) {
    Debug.log("Can't get domain info for $domainNameOut!");
    Debug.log(api.error);
    exit(0);
  }
  Debug.log(domain, "map", "Domain info");
}
