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

## Check command complete successful
To check command complete successful, you must use property `success`.
```dart
var result = await api.method(...);

if (api.success) {
  // Command complete successful
  print(result);
} else {
  // Check error details with method getError()
  print(api.error);
}
```

## Get errors
To get API error use getter `error`.
```dart
print( api.error );
```

## Get network error
To get network error use getter `httpError`.
```dart
print( api.httpError );
```

## Get full result object
To get full result object as `Map()` use getter `result`. This getter returns all the information that was contained in the response by the result key.
```dart
print( api.result );
```

## Get token and tokenData
After login successful, you can get auth token value and token data.

To get auth token value use getter `token`  
```dart
print( api.token );
```

To get token data (reseller info) use getter `tokenData`  
```dart
print( api.tokenData );
```

## Login to server
Method definition
```dart
  Future<bool> login({
    @required String login,
    @required String password,
    String smsCode: '',
    String gaCode: ''
  });
```
Example of usage
```dart
await api.login(login: API_LOGIN, password: API_PASSWORD);

if (!api.success) {
    print("\nCan't login to API server!\n");
} else {
    print("\nLogin successful, authToken is: ${api.token}");
}
```

## Login to server with second auth method
Method definition:
```dart
  Future<bool> secondAuth({
    String smsCode: '', 
    String gaCode: ''
  });
```
Example of usage:
```dart
String secondAuthCode = "...";

await api.login(login: API_LOGIN, password: API_PASSWORD);

if (!api.success) {
    if (api.errorCode == -32012) {
      // Second authentication required
      await api.secondAuth(smsCode: secondAuthCode); 
      if (!api.success) {
        print("\nCan't login to API server!\n");
      } else {
        print("\nLogin successful, authToken is: ${api.token}");
      }  
    }
} else {
    print("\nLogin successful, authToken is: ${api.token}");
}
```

## Get authToken after authentication

To get `authToken` after successful authentication, you can use getter `authToken`. The `authToken` is available after successful authentication.

Method definition:
```dart
String get authToken => {};
```

## End of session 

To stop an active session you must call method `logout()`.

Method definition
```dart
Future<bool> logout();
```
Example of usage
```dart
await api.logout();
```
 
## Get Token/Reseller info from api
To get token info, you must call method `tokenInfo()`. This method calls automated when user successfully was logged.
This method save data into private class variable `_info`. You can get this info with method `getInfo()`.
Method `tokenInfo()` will return `false` or token data as `Map<String, dynamic>`. 

Method definition
```dart
Future<Map<String, dynamic>> tokenInfo();
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
  Future<Map<String, dynamic>> domains({
    int limit: 500,
    int offset: 0
  });
```
Example of usage
```dart
Map<String, dynamic> domains = await api.domains(limit: 100, offset: 500);

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
Future<int> domainsTotal();
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
Future<Map<String, dynamic>> domainsBy([String filter = ""]);
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

## Get all domains on reseller account 
You can get all domain from your account with method `domainsAll()`. 

Method definition
```dart
Future<Map<String, dynamic>> domainsAll();
```
Example of usage
```dart
Map<String, dynamic> domains = await api.domainsAll();

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
Future<Map<String, dynamic>> domainInfo(String serviceCode);
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
Future<Map<String, dynamic>> domainInfoShort(String domainName);
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
Future<Map<String, dynamic>> contacts(String serviceCode);
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

## Get domain tagList 

Method definition
```dart
Future<List<dynamic>> tags(String serviceCode);
```
Example of usage
```dart
List<dynamic> tags = await api.tags(serviceCode);

if (!api.success) {
  print("\nCan't get domain contacts!\n");
} else {
  print(tags);
}
```

## Get domain nameservers 

Method definition
```dart
Future<List<dynamic>> nameservers(String serviceCode);
```
Example of usage
```dart
List<dynamic> nameservers = await api.nameservers(serviceCode);

if (!api.success) {
  print("\nCan't get domain contacts!\n");
} else {
  print(nameservers);
}
```

## Get domain child nameservers 

Method definition
```dart
Future<List<dynamic>> childNameservers(String serviceCode);
```
Example of usage
```dart
List<dynamic> nameservers = await api.childNameservers(serviceCode);

if (!api.success) {
  print("\nCan't get domain contacts!\n");
} else {
  print(nameservers);
}
```


## Set domain nameservers 

Method definition
```dart
  Future<bool> setNS({
    @required String serviceCode, 
    @required List<String> ns
  });
```
Example of usage
```dart
String serviceCode = "123456";
List<String> ns = const ['ns1.com', 'ns2.com', 'ns3.com'];
await api.setNS(serviceCode: serviceCode, ns: ns);

if (!api.success) {
  print("\nCan't set domain ns!\n");
} else {
  print("\nDomain ns changed!\n");
}
```

## Set default domain nameservers 

You can set default nameservers to:
- default, with constant `ImenaAPIConst.HOSTING_TYPE_DEFAULTS`; 
- to mirohost NS, with constant `ImenaAPIConst.HOSTING_TYPE_MIROHOST`; 
- to dnshosting NS, with constant `ImenaAPIConst.HOSTING_TYPE_DNS`; 

Method definition
```dart
Future<bool> setNSPreset(String serviceCode, [String nsType = ImenaAPIConst.HOSTING_TYPE_DEFAULTS]);
```
Example of usage
```dart
await api.setNSPreset(serviceCode, ImenaAPIConst.HOSTING_TYPE_DEFAULTS);

if (!api.success) {
  print("\nCan't set domain ns!\n");
} else {
  print("\nDomain ns changed!\n");
}
```

## Set specified default domain nameservers 

You can set specified default nameservers. 

Method definition
```dart
Future<bool> setDefaultNS(String serviceCode);
Future<bool> setMirohostNS(String serviceCode);
Future<bool> setDnshostingNS(String serviceCode);
```
Example of usage
```dart
await api.setDefaultNS(serviceCode);

if (!api.success) {
  print("\nCan't set domain ns!\n");
} else {
  print("\nDomain ns changed!\n");
}
```

## Add and delete child name servers
## Set contact for domain
## Set privacy protection
## Get reseller balance info
## Get reseller balance
## Get reseller credit
## Get reseller prices
## Get reseller prices for specified domain
## Get reseller prices for specified domains
## Create an order to get a domain for serving (registration, transfer)
## Create payment for operation with domain name
## Create payment for registration
## Create payment for renew
## Create payment for transfer
## Get payment status
## Delete unused orders
## get domain auth-code for outside transfer
## Internal transfer between imena clients
## Pick domain names
## Get reseller client list
## Get reseller client info
## Create client


---

2020 © Copyright by Serhii Pimenov. All Rights Reserved. Created by Serhii Pimenov.
