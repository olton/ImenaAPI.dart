import 'package:imena/imena.dart';

void main() async {
  const endpoint = "https://rpc.imena.devua.net/v1/";
  const login = "dnmarketAPIclient";
  const password = "";

  ImenaAPI api = new ImenaAPI(endpoint);

  var result;

  result = await api.login(login, password);

  if (result == Future.value(false)) {
    Debug.log("\nCan't login to API server!\n");
  } else {
    Debug.log("\nLogin successful, authToken is: ${api.authToken()}");
  }

}
