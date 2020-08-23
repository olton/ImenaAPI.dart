import 'package:imena/imena.dart';

void main() async {
  const endpoint = "https://rpc.imena.devua.net/v1/";
  const login = "dnmarketAPIclient";
  const password = "CrX4hQcE8Ix9xCP076vmrD21";

  ImenaAPI api = new ImenaAPI(endpoint);

  var result;

  result = await api.Login(login, password);

  if (result == Future.value(false)) {
    print("Can't login to API server!\n");
  } else {
    print("Login successful, authToken is: ${api.authToken()}");
  }

}