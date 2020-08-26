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
ImenaAPI api = ImenaAPI(API_ENDPOINT_URL);
```

## Login to server
Method definition
```dart
Future<bool> login(String login, String password) async {...}
```
Example of usage
```dart
await api.login(API_LOGIN, API_PASSWORD);

if (!api.success) {
    print("\nCan't login to API server!\n");
} else {
    print("\nLogin successful, authToken is: ${api.authToken}");
}
```

## Login to server with second auth method
Method definition
```dart
Future<bool> secondAuth(code, [type = ImenaAPIConst.SECOND_AUTH_SMS]) async {...}
```
Example of usage
```dart
String secondAuthCode = "...";

await api.login(API_LOGIN, API_PASSWORD);

if (!api.success) {
    if (api.getError()['code'] == -32012) {
      // Second authentication required
      // for sms code use constant ImenaAPIConst.SECOND_AUTH_SMS
      // for google authentication use constant ImenaAPIConst.SECOND_AUTH_GOOGLE
      await api.secondAuth(secondAuthCode, ImenaAPIConst.SECOND_AUTH_SMS); 
      if (!api.success) {
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
Method definition
```dart
String get authToken => ...;
```
Example of usage
```dart
ImenaAPI api = new ImenaAPI(API_ENDPOINT_URL);
await api.login(API_LOGIN, API_PASSWORD);

if (!api.success) {
    print("\nCan't login to API server!\n");
} else {
    print("\nLogin successful, authToken is: ${api.authToken}");
}
```

## End of session 
To end active session, you must call method `logout()`.

Method definition
```dart
Future<bool> logout() async {...}
```
Example of usage
```dart
await api.logout();
```
 
## Get Token/Reseller info 
To get token info, you must call method `tokenInfo()`. This method calls automated when user successfully was logged.
This method save data into private class variable `_info`. You can get this info with method `getInfo()`.
Method `tokenInfo()` will return `false` or token data as `Map<String, dynamic>`. 

Method definition
```dart
Future<Map<String, dynamic>> tokenInfo() async {...}
```
Example of usage
```dart
dynamic token = await api.tokenInfo();

if (!api.success) {
  print("\nCan't get token info!\n");
} else {
  print(token);
}
```
 
## Get reseller domain list 
To get domain list, you must call method `domains()`. This method return `Map<String, dynamic>`.

Method definition
```dart
Future<Map<String, dynamic>> domains([int limit = 500, int offset = 0]) async {...}
```
Example of usage
```dart
Map<String, dynamic> domains = await api.domains();

if (!api.success) {
  print("\nCan't get domain list or list empty!\n");
} else {
  print(domains);
}
```
 
## Get domains count on reseller account 
To get domains count, you must call method `domainTotal()`.

Method definition
```dart
Future<int> domainsTotal() async {...}
```
Example of usage
```dart
int count = await domainsTotal();

print("You have a ${count} domains on your account");
```

## Get domains by name 
You can get domain list, filtered by part of name. 
To get filtered domains, you must call method `domainsBy()`. 
If you pass `filter` argument, you get all domains on your account.

Method definition
```dart
Future<Map<String, dynamic>> domainsBy([String filter = ""]) async {...}
```
Example of usage
```dart
Map<String, dynamic> domains = await api.domainsBy("part_of_domain_name");

if (!api.success) {
  print("\nCan't get domain list or list empty!\n");
} else {
  print(domains);
}
```

## Get domain info 
To get domain info, use method `domainInfo()`. This method return `false` or `Map<String, dynamic>` with domain information.

Method definition
```dart
Future<Map<String, dynamic>> domainInfo(String serviceCode) async {...}
```
Example of usage
```dart
dynamic info = await api.domainInfo("123456789");

if (!api.success) {
  print("\nCan't get domain info!\n");
} else {
  print(info);
}
```

## Get domain short info by name 
To get domain info, use method `domainInfoShort()`. 
This method return `false` or `Map<String, dynamic>` with domain information.
This method return info for tha domain, if domain served on `imena.ua`.
The method is useful if you need to perform an internal transfer between resellers `imena.ua` with method `internal()`.

Method definition
```dart
Future<Map<String, dynamic>> domainInfoShort(String domainName) async {...}
```
Example of usage
```dart
dynamic info = await api.domainInfoShort("imena.ua");

if (!api.success) {
  print("\nCan't get domain info!\n");
} else {
  print(info);
}
```

## Get domain contacts 
To get domain info, use method `contacts()`. 

Method definition
```dart
Future<Map<String, dynamic>> contacts(String serviceCode) async {...}
```
Example of usage
```dart
dynamic info = await api.domainInfoShort("imena.ua");

if (!api.success) {
  print("\nCan't get domain contacts!\n");
} else {
  print(info);
}
```


---

2020 © Copyright by Serhii Pimenov. All Rights Reserved. Created by Serhii Pimenov.