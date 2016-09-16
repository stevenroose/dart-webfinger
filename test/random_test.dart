

import "dart:async";
import "dart:io";

import "package:http/http.dart";



void main() {
  Client client = new Client();

//  client.get("https://stevenroose.be/").then((Response response) {
//    print(response);
//  });

  new Future.value(5).then((x) {
    throw "kaka";
  }, onError: print);
}