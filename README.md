# ImenaAPI.dart
Imena.ua API dart implementation

### Who will it be useful for:
+ [x] If you are developing the server side for your reselling on dart
+ [x] If you are developing the client side for your reselling on dart
+ [x] If you are developing a mobile application on flutter

### License
This software licensed under the MIT license.

### Docs

#### About
The `Imena.dart` is an `asynchronous` library for accessing and executing commands from the [Imena.ua](https://imena.ua) domain registrar `reseller API`.
This means that all methods that directly access the API implemented as Future (Promises) and, as a consequence, 
actual execution is available either in the `then()` call, or you must use `await` keyword before calling the method.
Inside the class, the async / await methodology is used and below in the documentation, this approach will also be used.

## Create instance
```dart
ImenaAPI api = new ImenaAPI(API_ENDPOINT_URL);
```

## Login to server
Method implementation
```dart
Future<bool> login(String login, String password) async {...}
```
Example of usage
```dart
ImenaAPI api = new ImenaAPI(API_ENDPOINT_URL);
bool result = await api.login(API_LOGIN, API_PASSWORD);

if (!result) {
    print("\nCan't login to API server!\n");
} else {
    print("\nLogin successful, authToken is: ${api.authToken}");
}
```

## Login to server with second auth method
Method implementation
```dart
Future<bool> secondAuth(code, [type = ImenaAPIConst.SECOND_AUTH_SMS]) async {...}
```
Example of usage
```dart
bool result;
String secondAuthCode = "...";

ImenaAPI api = new ImenaAPI(API_ENDPOINT_URL);

result = await api.login(API_LOGIN, API_PASSWORD);


if (!result) {
    if (api.getError()['code'] == -32012) {
      // Second authentication required
      // for sms code use constant ImenaAPIConst.SECOND_AUTH_SMS
      // for google authentication use constant ImenaAPIConst.SECOND_AUTH_GOOGLE
      result = await api.secondAuth(secondAuthCode, ImenaAPIConst.SECOND_AUTH_SMS); 
      if (!result) {
        print("\nCan't login to API server!\n");
      } else {
        print("\nLogin successful, authToken is: ${api.authToken}");
      }  
    }
} else {
    print("\nLogin successful, authToken is: ${api.authToken}");
}
```

## Get authToken after authentication
To get `authToken` after successful authentication, you can use getter `authToken`.  
Method implementation
```dart
String get authToken => this._authToken;
```
Example of usage
```dart
ImenaAPI api = new ImenaAPI(API_ENDPOINT_URL);
bool result = await api.login(API_LOGIN, API_PASSWORD);

if (!result) {
    print("\nCan't login to API server!\n");
} else {
    print("\nLogin successful, authToken is: ${api.authToken}");
}
```

## End of session 
To end active session, you must call method `logout()`.

Method implementation
```dart
Future<bool> logout() async {...}
```
Example of usage
```dart
ImenaAPI api = new ImenaAPI(API_ENDPOINT_URL);
bool result = await api.login(API_LOGIN, API_PASSWORD);

...

await api.logout();
```
 


---

2020 © Copyright by Serhii Pimenov. All Rights Reserved. Created by Serhii Pimenov.