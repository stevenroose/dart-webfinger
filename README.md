# webfinger
This library implements the WebFinger protocol defined in [RFC 7033](https://tools.ietf.org/html/rfc7033).


# Usage

```dart
WebFinger webfinger = ...; // see next section

// query any URI
webfinger.query("https://packetizer.com/").then((JRDDocument result) {
  print(result.subject); // = https://packetizer.com/
  print(result.properties["http://packetizer.com/ns/name"]);
});

// shortcut for accounts
webfinger.account("paulej@packetizer.com").then((JRDDocument result) {
  // same as webfinger.query("acct:paulej@packetizer.com")
  print(result.subject); // = acct:paulej@packetizer.com
  // iterate over the links
  result.links.forEach((JRDLink link) {
    print(link.rel);
    print(link.href);
  });
  // or just find a link by its relation
  print(result.link("http://specs.openid.net/auth/2.0/provider").href); // = https://openid.packetizer.com/paulej
});

// query for only certain relations
webfinger.account("paulej@packetizer.com", rels: ["http://webfinger.net/rel/avatar"]).then((JRDDocument result) {
  print(result.link("http://specs.openid.net/auth/2.0/provider")); // = null
});
```

## Creating WebFinger instance

Use the `package:http.Client` interface to provide an HTTP client to the `WebFinger` constructor.
The [`http`](https://pub.dartlang.org/packages/http) package provides both an implementation for the VM and for the browser.

### In the VM

```dart
import "package:http/http.dart"
import "Package:webfinger/webfinger.dart"

WebFinger webfinger = new WebFinger(new Client());
```

### In the browser

```dart
import "package:http/browser_client.dart"
import "Package:webfinger/webfinger.dart"

WebFinger webfinger = new WebFinger(new BrowserClient());
```



