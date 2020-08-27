import 'dart:io';

import 'package:imena/imena.dart';
import 'auth.dart';

void main() async {
  ImenaAPI api = ImenaAPI(API_ENDPOINT);

  var result, domains;

  result = await api.login(API_LOGIN, API_PASSWORD);

  if (!result) {
    Debug.log("\nCan't login to API server!\n");
    exit(0);
  }

  Debug.log("\nLogin successful, authToken is: ${api.authToken}");

  Debug.log("\nGet domains by name...\n");

  domains = await api.domainsBy("stoy");
  if (domains.length == 0) {
    Debug.log("\nCan't get domain list or list empty!\n");
    Debug.log(api.getError());
    exit(0);
  }
  Debug.log(domains, "map", "Domains total");
}
