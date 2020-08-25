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
 
## Get Token/Reseller info 
To get token info, you must call method `tokenInfo()`. This method calls automated when user successfully was logged.
This method save data into private class variable `_info`. You can get this info with method `getInfo()`.
Method `tokenInfo()` will return `false` or token data as `Map<String, dynamic>`. 

Method implementation
```dart
Future<dynamic> tokenInfo() async {...}
```
Example of usage
```dart
ImenaAPI api = new ImenaAPI(API_ENDPOINT_URL);
bool result = await api.login(API_LOGIN, API_PASSWORD);
...
dynamic token = await api.tokenInfo();
if (token == Future.value(false)) {
  print("\nCan't get token info!\n");
} else {
  print(token);
}
```
 
## Get reseller domain list 
To get domain list, you must call method `domains()`. This method return `Map<String, dynamic>`.

Method implementation
```dart
Future<Map<String, dynamic>> domains([int limit = 500, int offset = 0]) async {...}
```
Example of usage
```dart
ImenaAPI api = new ImenaAPI(API_ENDPOINT_URL);
bool result = await api.login(API_LOGIN, API_PASSWORD);
...
domains = await api.domains();
if (domains.length == 0) {
  print("\nCan't get domain list or list empty!\n");
} else {
  print(domains);
}
```
 
## Get domains count on reseller account 
To get domains count, you must call method `domainTotal()`.

Method implementation
```dart
Future<int> domainsTotal() async {...}
```
Example of usage
```dart
ImenaAPI api = new ImenaAPI(API_ENDPOINT_URL);
bool result = await api.login(API_LOGIN, API_PASSWORD);
...
int count = await domainsTotal();
print("You have a ${count} domains on your account");
```

## Get domains by name 
You can get domain list, filtered by part of name. To get filtered domains, you must call method `domainsBy()`.

Method implementation
```dart
Future<dynamic> domainsBy([String filter = ""]) async {...}
```
Example of usage
```dart
ImenaAPI api = new ImenaAPI(API_ENDPOINT_URL);
bool result = await api.login(API_LOGIN, API_PASSWORD);
...
Map<String, dynamic> domains = await api.domainsBy("part_of_domain_name");
if (domains.length == 0) {
  print("\nCan't get domain list or list empty!\n");
} else {
  print(domains);
}
```
 



---

2020 © Copyright by Serhii Pimenov. All Rights Reserved. Created by Serhii Pimenov.