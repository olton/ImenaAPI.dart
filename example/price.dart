import 'dart:io';

import 'package:imena/imena.dart';
import 'auth.dart';

void main() async {
  ImenaAPI api = ImenaAPI(API_ENDPOINT);

  var result, price;

  result = await api.login(login: API_LOGIN, password: API_PASSWORD);

  if (!result) {
    Debug.log("\nCan't login to API server!\n");
    exit(0);
  }

  Debug.log("\nLogin successful, authToken is: ${api.token}");
  Debug.log("Get reseller balance...\n");

  price = await api.price();
  if (!api.success) {
    Debug.log("\nCan't get reseller price list or list empty!\n");
    Debug.log(api.error);
    exit(0);
  }
  Debug.log(price, "map", "Price list");

  price = await api.priceDomain(domain: 'one');
  if (!api.success) {
    Debug.log("\nCan't get reseller price list or list empty!\n");
    Debug.log(api.error);
    exit(0);
  }
  Debug.log(price, "map", "Price list");

  price = await api.priceDomains(domains: ['one', 'press']);
  if (!api.success) {
    Debug.log("\nCan't get reseller price list or list empty!\n");
    Debug.log(api.error);
    exit(0);
  }
  Debug.log(price, "map", "Price list");

}
