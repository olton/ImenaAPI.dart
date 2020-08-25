import 'dart:io';

import 'package:imena/imena.dart';
import 'auth.dart';

void main() async {
  ImenaAPI api = ImenaAPI(API_ENDPOINT);

  var result, clients;

  result = await api.login(API_LOGIN, API_PASSWORD);

  if (!result) {
    Debug.log("\nCan't login to API server!\n");
    exit(0);
  }

  Debug.log("\nLogin successful, authToken is: ${api.authToken}");
  Debug.log("Get client list...\n");

  clients = await api.clients();
  if (clients.length == 0) {
    Debug.log("\nCan't get token info!\n");
    Debug.log(api.getError());
    exit(0);
  }
  Debug.log(clients, "map", "Clients");

}
