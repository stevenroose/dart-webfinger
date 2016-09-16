library webfinger.test.html;


import "package:http/http.dart";
import "package:http/browser_client.dart";
import "package:unittest/html_config.dart";

import "package:webfinger/webfinger.dart";

import 'webfinger_test_generic.dart';


void main() {
  useHtmlConfiguration();
  Client client = new BrowserClient();
  WebFinger webfinger = new WebFinger(client);
  testWebFinger(webfinger);
}