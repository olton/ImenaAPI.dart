import 'dart:io';

import 'package:imena/imena.dart';
import 'auth.dart';

void main() async {
  ImenaAPI api = ImenaAPI(API_ENDPOINT);

  var result, setContact, contact;
  const domainName = "cctld.org.ua";
  const serviceCode = "800190";
  Map<String, String> contactData = {
    "firstName": "Tester",
    "middleName": "Иванович",
    "lastName": "Testerenko",
    "company": "",
    "email": "email@email.com",
    "country": "UA",
    "postalCode": "02055",
    "region": "Киевская область",
    "city": "Киев",
    "address": "ул. Ленина, д. 111-22",
    "address2": "",
    "phone": "+380501234567",
    "fax": "+380441234567"
  };

  result = await api.login(API_LOGIN, API_PASSWORD);

  if (!result) {
    Debug.log("\nCan't login to API server!\n");
    exit(0);
  }

  Debug.log("\nLogin successful, authToken is: ${api.authToken}");

  Debug.log("\nSet contact to ... for $domainName...\n");

  setContact = await api.setContact(serviceCode, ImenaAPIConst.CONTACT_TECH, contactData);
  if (!setContact) {
    Debug.log("\nCan't set contact!\n");
    Debug.log(api.getError());
    exit(0);
  }
  contact = await api.contacts(serviceCode);
  Debug.log(contact['tech-c'], "map", "Domain contact");
}
