import 'package:imena/imena.dart';
import 'auth.dart';

void main() async {

  ImenaAPI api = new ImenaAPI(API_ENDPOINT);

  var result;

  result = await api.login(API_LOGIN, API_PASSWORD);

  if (result == Future.value(false)) {
    Debug.log("\nCan't login to API server!\n");
  } else {
    Debug.log("\nLogin successful, authToken is: ${api.authToken()}");
  }

}
