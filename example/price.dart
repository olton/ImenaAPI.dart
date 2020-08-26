import 'dart:io';

import 'package:imena/imena.dart';
import 'auth.dart';

void main() async {
  ImenaAPI api = ImenaAPI(API_ENDPOINT);

  var result, price;

  result = await api.login(API_LOGIN, API_PASSWORD);

  if (!result) {
    Debug.log("\nCan't login to API server!\n");
    exit(0);
  }

  Debug.log("\nLogin successful, authToken is: ${api.authToken}");
  Debug.log("Get reseller balance...\n");

  price = await api.price();
  if (!api.success) {
    Debug.log("\nCan't get reseller price list or list empty!\n");
    Debug.log(api.getError());
    exit(0);
  }
  Debug.log(price, "map", "Price list");

  price = await api.priceDomain('one');
  if (!api.success) {
    Debug.log("\nCan't get reseller price list or list empty!\n");
    Debug.log(api.getError());
    exit(0);
  }
  Debug.log(price, "map", "Price list");

  price = await api.priceDomains(['one', 'press']);
  if (!api.success) {
    Debug.log("\nCan't get reseller price list or list empty!\n");
    Debug.log(api.getError());
    exit(0);
  }
  Debug.log(price, "map", "Price list");

}
