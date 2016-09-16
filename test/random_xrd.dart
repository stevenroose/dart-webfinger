// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library random_xrd;

import "dart:io";

import "package:webfinger/xrd.dart";
import 'package:unittest/unittest.dart';
import 'package:xml/xml.dart';

main() {
  HttpStatus x;
//  XrdDocument doc = new XrdDocument.fromJson(json6);
//  print(doc.toXml().toXmlString(pretty: true));
print(Uri.parse("http://google.com").host);
}






var json1 = '''
{
  "properties": {
    "http://protocol.example.net/version": "1.0"
  },
  "links": [
    {
      "rel": "copyright",
      "href": "http://bar.eu/copyright"
    },
    {
      "rel": "lrdd",
      "type": "application/jrd+json",
      "template": "https://bar.eu/.well-known/webfinger?resource={uri}"
    },
    {
      "rel": "lrdd",
      "type": "application/jrd+json",
      "template": "https://openid.bar.eu/webfinger.json?q={uri}"
    },
    {
      "rel": "lrdd",
      "type": "application/xrd+xml",
      "template": "https://openid.bar.eu/webfinger.xml?q={uri}"
    }
  ]
}
''';

var json2 = '''{
      "subject": "acct:foo@bar.eu",
      "aliases": [
        "https://www.bar.eu/~foo/"
      ],
      "properties": {
        "http://bar.eu/ns/role": "employee"
      },
      "links": [
        {
          "rel": "http://webfinger.example/rel/profile-page",
          "href": "https://www.bar.eu/~foo/"
        },
        {
          "rel": "http://webfinger.example/rel/avatar",
          "template": "https://www.bar.eu/avatars/{uri}.jpg"
        },
        {
          "rel": "author",
          "href": "http://blog.bar.eu/author/foo",
          "titles": {
            "en-us": "The Magical World of Foo",
            "fr": "Le Monde Magique de Foo"
          },
          "properties": {
            "http://blog.bar.eu/role" : "editor"
          }
        }
      ]
    }
    ''';

var json3 = '''{
      "subject": "acct:foo@bar.eu",
      "properties": {
        "http://specs.openid.net/version": "v1.0"
      },
      "links": [
        {
          "rel": "http://specs.openid.net/auth/2.1/provider",
          "href": "https://openid.bar.eu/provider"
        }
      ]
    }''';


var json4 = '''{
      "subject": "acct:foo@bar.eu",
      "properties": {
        "http://webhand.org/rel/origin": "openid",
        "http://specs.openid.net/version": "v1.0"
      },
      "links": [
        {
          "rel": "http://specs.openid.net/auth/2.1/provider",
          "href": "https://openid.bar.eu/provider"
        }
      ]
    }''';

var json5 = '''{
      "properties": {
        "http://protocol.example.net/version": "1.0"
      },
      "links": [
        {
          "rel": "copyright",
          "href": "http://bar.eu/copyright"
        },
        {
          "rel": "lrdd",
          "type": "application/jrd+json",
          "template": "https://bar.eu/.well-known/webfinger?resource={uri}",
          "properties": {
            "http://webhand.org/rel/origin": "webfinger"
          }
        },
        {
          "rel": "lrdd",
          "type": "application/jrd+json",
          "template": "https://openid.bar.eu/webfinger.json?q={uri}",
          "properties": {
            "http://webhand.org/rel/origin": "openid"
          }
        },
        {
          "rel": "lrdd",
          "type": "application/xrd+xml",
          "template": "https://openid.bar.eu/webfinger.xml?q={uri}",
          "properties": {
            "http://webhand.org/rel/origin": "openid"
          }
        }
      ]
    }''';


var json6 = '''{
      "properties": {
        "http://protocol.example.net/version": "1.0",
        "test-prop-null": null
      },
      "links": [
        {
          "rel": "copyright",
          "href": "http://bar.eu/copyright"
        },
        {
          "rel": "lrdd",
          "type": "application/jrd+json",
          "template": "https://bar.eu/.well-known/webfinger?resource={uri}",
          "properties": {
            "http://webhand.org/rel/origin": "webfinger"
          }
        },
        {
          "rel": "lrdd",
          "type": "application/jrd+json",
          "template": "https://openid.bar.eu/webfinger.json?q={uri}",
          "properties": {
            "http://webhand.org/rel/origin": "openid",
            "also-null-random-test": null
          }
        },
        {
          "rel": "lrdd",
          "type": "application/xrd+xml",
          "template": "https://openid.bar.eu/webfinger.xml?q={uri}",
          "properties": {
            "http://webhand.org/rel/origin": "openid"
          }
        }
      ]
    }''';

var example = '''<?xml version='1.0' encoding='UTF-8'?>
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0" xml:id="foo">
  <Expires>1970-01-01T00:00:00Z</Expires>
  <Subject>http://example.com/gpburdell</Subject>
  <Alias>http://people.example.com/gpburdell</Alias>
  <Alias>acct:gpburdell@example.com</Alias>
  <Property type="http://spec.example.net/version">1.0</Property>
  <Property type="http://spec.example.net/version">2.0</Property>
  <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
    <ds:SignedInfo>
      <ds:CanonicalizationMethod
        Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
      <ds:SignatureMethod
        Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>
      <ds:Reference URI="#foo">
        <ds:Transforms>
          <ds:Transform
           Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
          <ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#">
            <InclusiveNamespaces PrefixList="#default xrd ds xs xsi"
              xmlns="http://www.w3.org/2001/10/xml-exc-c14n#"/>
          </ds:Transform>
        </ds:Transforms>
        <ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>
        <ds:DigestValue>yi2N42KYR6b8dl6TCBKjs4duPuo=</ds:DigestValue>
      </ds:Reference>
    </ds:SignedInfo>
    <ds:SignatureValue>
      NGJ/tVRnK8O7FwTic3nQjrEw1do+SgWE/LKE/Q2bgE+k4b3Go6d9fLZq0/DX8nyr
      x0nYfpTgxzMUDVUVaDyvnp0MfnmTSJ/yL5bXAV2jW6+NWJH73DXjQoPKn0j1WY2G
      UoTdgnMiiNzKYY+QhWYogy4QXJOmjOF+6OE+uONKvQU=
    </ds:SignatureValue>
    <ds:KeyInfo>
      <ds:X509Data>
        <ds:X509Certificate>
          MIICsDCCAhmgAwIBAgIJAK6eiEXk2FoiMA0GCSqGSIb3DQEBBQUAMEUxCzAJBgNV
          BAYTAkFVMRMwEQYDVQQIEwpTb21lLVN0YXRlMSEwHwYDVQQKExhJbnRlcm5ldCBX
          aWRnaXRzIFB0eSBMdGQwHhcNMTAwNTA3MDQ1MDAzWhcNMzgwMTE5MDQ1MDAzWjBF
          MQswCQYDVQQGEwJBVTETMBEGA1UECBMKU29tZS1TdGF0ZTEhMB8GA1UEChMYSW50
          ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKB
          gQDVEftG6aMNrBRMu9hHaZUe4ZU5jrbtsaexNlh4OWnIOj9Tyyk2NfI9w1b2hp5f
          KQf5B9HYeZjowuYKVuc+NQMYgkN7V+YvcJ9ohAjCBZuo9Xcm5CiKeFnz5E6Ad0Fs
          BPnAHch9kZu2joz+iQOp6Av+A78Gvam9giG9ZT3rIj2LZQIDAQABo4GnMIGkMB0G
          A1UdDgQWBBR3yN91g2lEACpJ9WaKm3fM+PAPqTB1BgNVHSMEbjBsgBR3yN91g2lE
          ACpJ9WaKm3fM+PAPqaFJpEcwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgTClNvbWUt
          U3RhdGUxITAfBgNVBAoTGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZIIJAK6eiEXk
          2FoiMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQEFBQADgYEAc3cepBp8h2rwwc+f
          lFahLmJNVOePhw+uCyO8tLWu7Jcq9todVmeCNyqB9hGm2Rvt5yQ69tRpMxQ7Wmqs
          O6HbDYzW5APuCPHEtlXoafEq4oWZS8ICPNel68MX5mnXg+XkUOb8cjuY8CwRNtBf
          Ehs3jFzXUcMITIL1PmE7bb38Hug=
        </ds:X509Certificate>
      </ds:X509Data>
    </ds:KeyInfo>
  </ds:Signature>
  <Link rel="http://spec.example.net/auth/1.0"
    href="http://services.example.com/auth">
    <Title xml:lang="en">kaka</Title>
  </Link>
</XRD>''';