import 'package:imena/imena.dart';
import 'auth.dart';

void main() async {

  ImenaAPI api = ImenaAPI(API_ENDPOINT);

  bool result = await api.login(login: API_LOGIN, password: API_PASSWORD);

  if (!result) {
    Debug.log("\nCan't login to API server!\n");
  } else {
    Debug.log("\nLogin successful, authToken is: ${api.token}");
    Debug.log(api.tokenData, "map", "Info");
  }

}
