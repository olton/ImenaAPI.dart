import 'dart:io';

import 'package:imena/imena.dart';
import 'auth.dart';

void main() async {
  ImenaAPI api = ImenaAPI(API_ENDPOINT);

  var result, domains;

  result = await api.login(login: API_LOGIN, password: API_PASSWORD);

  if (!result) {
    Debug.log("\nCan't login to API server!\n");
    exit(0);
  }

  Debug.log("\nLogin successful, authToken is: ${api.token}");

  Debug.log("\nGet all domains...\n");

  domains = await api.domainsAll();
  if (domains.length == 0) {
    Debug.log("\nCan't get domain list or list empty!\n");
    Debug.log(api.error);
    exit(0);
  }
  Debug.log(domains, "map", "Domains total");
}
