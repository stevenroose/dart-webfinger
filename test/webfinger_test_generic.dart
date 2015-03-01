// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library webfinger.test.generic;


import "package:unittest/unittest.dart";
import "package:webfinger/webfinger.dart";


void testWebFinger(WebFinger webfinger) {
  test("paulej@packetizer.com", () {
    Function checkPaulej = (JRDDocument result) {
      expect(result.subject, equals("acct:paulej@packetizer.com"));
      expect(result.properties.containsKey("http://packetizer.com/ns/name"), isTrue);
      expect(result.aliases.contains("h323:paulej@packetizer.com"), isTrue);
      expect(result.link("http://specs.openid.net/auth/2.0/provider"), new isInstanceOf<JRDLink>());
      expect(result.link("http://specs.openid.net/auth/2.0/provider").href, equals("https://openid.packetizer.com/paulej"));
      expect(result.link("http://packetizer.com/rel/blog").type, equals("text/html"));
      expect(result.link("http://packetizer.com/rel/blog").titles, containsPair("en-us", "Paul E. Jones' Blog"));
    };
    expect(webfinger.account("paulej@packetizer.com").then(checkPaulej), completes);
    expect(webfinger.query("acct:paulej@packetizer.com").then(checkPaulej), completes);
  });
  test("packetizer.com", () {
    expect(webfinger.query("https://packetizer.com/").then((JRDDocument result) {
      expect(result.aliases.contains("http://packetizer.com"), isTrue);
      expect(result.links, isNotNull);
      expect(result.links, isEmpty);
    }), completes);
  });
}



























