library webfinger.test.io;


import "package:http/http.dart";

import "package:webfinger/webfinger.dart";

import 'webfinger_test_generic.dart';


void main() {
  Client client = new Client();
  WebFinger webfinger = new WebFinger(client);
  testWebFinger(webfinger);
}