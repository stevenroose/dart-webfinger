library test.xrd;


import "package:collection/equality.dart";
import "package:unittest/unittest.dart";

import "package:webfinger/xrd.dart";


void main() {
  group("XRD", () {
    group("oasis", () {
      test("Example B.1. Simple XRD Example", () {
        XrdDocument xrd = new XrdDocument.fromXml('''
<XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Expires>1970-01-01T00:00:00Z</Expires>
  <Subject>http://example.com/gpburdell</Subject>
  <Property type="http://spec.example.net/type/person" xsi:nil="true" />
  <Link rel="http://spec.example.net/auth/1.0"
    href="http://services.example.com/auth" />
  <Link rel="http://spec.example.net/photo/1.0" type="image/jpeg"
    href="http://photos.example.com/gpburdell.jpg">
    <Title xml:lang="en">User Photo</Title>
    <Title xml:lang="de">Benutzerfoto</Title>
    <Property type="http://spec.example.net/created/1.0">1970-01-01</Property>
  </Link>
</XRD>''');
        expect(xrd.expires, equals(new DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)));
        expect(xrd.subject, equals("http://example.com/gpburdell"));
        expect(xrd.property("http://spec.example.net/type/person"), isNull);
        expect(xrd.propertyMap.length, equals(1));
        expect(xrd.propertyMap.containsKey("http://spec.example.net/type/person"), isTrue);
        expect(xrd.link("http://spec.example.net/auth/1.0").href, equals("http://services.example.com/auth"));
        expect(xrd.link("http://spec.example.net/photo/1.0").type, equals("image/jpeg"));
        expect(xrd.link("http://spec.example.net/photo/1.0").titles["en"], equals("User Photo"));
        expect(xrd.link("http://spec.example.net/photo/1.0").property("http://spec.example.net/created/1.0"),
        equals("1970-01-01"));
        expect(xrd.links.length, equals(2));
      });

      test("Example B.2. Signed XRD Example", () {
        XrdDocument xrd = new XrdDocument.fromXml('''
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
    href="http://services.example.com/auth" />
</XRD>''');
        expect(xrd.expires, equals(new DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)));
        expect(xrd.subject, equals("http://example.com/gpburdell"));
        expect(xrd.aliases.contains("http://people.example.com/gpburdell"), isTrue);
        expect(xrd.aliases.contains("acct:gpburdell@example.com"), isTrue);
        expect(xrd.link("http://spec.example.net/auth/1.0").href, equals("http://services.example.com/auth"));
      });
    });


    group("RFC 6415", () {
      test("1.1. Example", () {
        XrdDocument xrd = new XrdDocument.fromXml('''
<?xml version='1.0' encoding='UTF-8'?>
<XRD xmlns='http://docs.oasis-open.org/ns/xri/xrd-1.0'>
 <!-- Host-Wide Information -->
 <Property type='http://protocol.example.net/version'>1.0</Property>
 <Link rel='copyright'
  href='http://example.com/copyright' />
 <!-- Resource-specific Information -->
 <Link rel='hub'
  template='http://example.com/hub' />
 <Link rel='lrdd'
  type='application/xrd+xml'
  template='http://example.com/lrdd?uri={uri}' />
 <Link rel='author'
  template='http://example.com/author?q={uri}' />
</XRD>''');
        expect(xrd.property("http://protocol.example.net/version"), equals("1.0"));
        expect(xrd.link("copyright").href, equals("http://example.com/copyright"));
        expect(xrd.link("hub").template, equals("http://example.com/hub"));
        expect(xrd.link("lrdd").href, isNull);
        expect(xrd.link("lrdd").template, equals("http://example.com/lrdd?uri={uri}"));
        expect(xrd.link("lrdd").type, equals("application/xrd+xml"));
      });

      test("1.1.1.  Processing Resource-Specific Information", () {
        XrdDocument xrd = new XrdDocument.fromXml('''
<?xml version='1.0' encoding='UTF-8'?>
<XRD xmlns='http://docs.oasis-open.org/ns/xri/xrd-1.0'>
  <Subject>http://example.com/xy</Subject>
  <Property type='http://spec.example.net/color'>red</Property>
  <Link rel='hub'
        href='http://example.com/another/hub' />
  <Link rel='author'
        href='http://example.com/john' />
</XRD>''');
        expect(xrd.property("http://spec.example.net/color"), equals("red"));
        expect(xrd.link("copyright"), isNull);
        expect(xrd.link("hub").href, equals("http://example.com/another/hub"));
        expect(xrd.link("lrdd"), isNull);
      });

      test("1.1.1.  Processing Resource-Specific Information (bis)", () {
        XrdDocument xrd = new XrdDocument.fromXml('''
<?xml version='1.0' encoding='UTF-8'?>
<XRD xmlns='http://docs.oasis-open.org/ns/xri/xrd-1.0'>
  <Subject>http://example.com/xy</Subject>
  <Property type='http://spec.example.net/color'>red</Property>
  <Link rel='hub'
        href='http://example.com/hub' />
  <Link rel='hub'
        href='http://example.com/another/hub' />
  <Link rel='author'
        href='http://example.com/john' />
  <Link rel='author'
        href='http://example.com/author?q=http%3A%2F%2Fexample.com%2Fxy' />
</XRD>''');
        expect(xrd.property("http://spec.example.net/color"), equals("red"));
        expect(xrd.link("copyright"), isNull);
        expect(xrd.link("hub").href, equals("http://example.com/hub"));
        expect(xrd.allLinks("hub").map((l) => l.href), orderedEquals(['http://example.com/hub', 'http://example.com/another/hub']));
        expect(xrd.allLinks("author").last.href, equals("http://example.com/author?q=http%3A%2F%2Fexample.com%2Fxy"));
      });

      test("Appendix A.  JRD Document Format", () {
        XrdDocument fromXml = new XrdDocument.fromXml('''
<?xml version='1.0' encoding='UTF-8'?>
<XRD xmlns='http://docs.oasis-open.org/ns/xri/xrd-1.0'
     xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
  <Subject>http://blog.example.com/article/id/314</Subject>
  <Expires>2010-01-30T09:30:00Z</Expires>
  <Alias>http://blog.example.com/cool_new_thing</Alias>
  <Alias>http://blog.example.com/steve/article/7</Alias>
  <Property type='http://blgx.example.net/ns/version'>1.2</Property>
  <Property type='http://blgx.example.net/ns/version'>1.3</Property>
  <Property type='http://blgx.example.net/ns/ext' xsi:nil='true' />
  <Link rel='author' type='text/html'
        href='http://blog.example.com/author/steve'>
    <Title>About the Author</Title>
    <Title xml:lang='en-us'>Author Information</Title>
    <Property type='http://example.com/role'>editor</Property>
  </Link>
  <Link rel='author' href='http://example.com/author/john'>
    <Title>The other guy</Title>
    <Title>The other author</Title>
  </Link>
  <Link rel='copyright'
        template='http://example.com/copyright?id={uri}' />
</XRD>''');
        XrdDocument fromJson = new XrdDocument.fromJson('''
{
  "subject":"http://blog.example.com/article/id/314",
  "expires":"2010-01-30T09:30:00Z",
  "aliases":[
    "http://blog.example.com/cool_new_thing",
    "http://blog.example.com/steve/article/7"
    ],
  "properties":{
    "http://blgx.example.net/ns/version":"1.3",
    "http://blgx.example.net/ns/ext":null
  },
  "links":[
    {
      "rel":"author",
      "type":"text/html",
      "href":"http://blog.example.com/author/steve",
      "titles":{
        "default":"About the Author",
        "en-us":"Author Information"
      },
      "properties":{
        "http://example.com/role":"editor"
      }
    },
    {
      "rel":"author",
      "href":"http://example.com/author/john",
      "titles":{
        "default":"The other author"
      }
    },
    {
      "rel":"copyright",
      "template":"http://example.com/copyright?id={uri}"
    }
  ]
}''');
        expect(fromJson == fromXml, isFalse);
        expect(fromJson.subject == fromXml.subject, isTrue);
        expect(fromJson.expires == fromXml.expires, isTrue);
        expect(const IterableEquality().equals(fromJson.aliases, fromXml.aliases), isTrue);
        expect(fromJson.links.first == fromXml.links.first, isTrue);
        expect(const IterableEquality().equals(fromJson.properties, fromXml.properties), isFalse);
        expect(fromJson.property("http://blgx.example.net/ns/version"), equals("1.3"));
        expect(fromJson.property("http://blgx.example.net/ns/version"), equals("1.3"));
        expect(fromXml.properties.contains(new XrdProperty("http://blgx.example.net/ns/version", "1.2")), isTrue);
        expect(fromJson.allLinks("author").last.titles["default"], equals("The other author"));
        expect(fromXml.allLinks("author").last.titles["default"], equals("The other author"));
      });
    });


    group("RFC 7033", () {
      test("3.1.  Identity Provider Discovery for OpenID Connect", () {
        XrdDocument xrd = new XrdDocument.fromJson('''
{
 "subject" : "acct:carol@example.com",
 "links" :
 [
   {
     "rel" : "http://openid.net/specs/connect/1.0/issuer",
     "href" : "https://openid.example.com"
   }
 ]
}''');
        expect(xrd.subject, equals("acct:carol@example.com"));
        expect(xrd.links.first, equals(new XrdLink(rel: "http://openid.net/specs/connect/1.0/issuer",
                                                   href: "https://openid.example.com")));
      });

      test("3.2.  Getting Author and Copyright Information for a Web Page", () {
        XrdDocument xrd = new XrdDocument.fromJson('''
{
 "subject" : "http://blog.example.com/article/id/314",
 "aliases" :
 [
   "http://blog.example.com/cool_new_thing",
   "http://blog.example.com/steve/article/7"
 ],
 "properties" :
 {
   "http://blgx.example.net/ns/version" : "1.3",
   "http://blgx.example.net/ns/ext" : null
 },
 "links" :
 [
   {
     "rel" : "copyright",
     "href" : "http://www.example.com/copyright"
   },
   {
     "rel" : "author",
     "href" : "http://blog.example.com/author/steve",
     "titles" :
     {
       "en-us" : "The Magical World of Steve",
       "fr" : "Le Monde Magique de Steve"
     },
     "properties" :
     {
       "http://example.com/role" : "editor"
     }
   }

 ]
}''');
        expect(xrd.subject, equals("http://blog.example.com/article/id/314"));
        expect(xrd.aliases.last, equals("http://blog.example.com/steve/article/7"));
        expect(xrd.property("http://blgx.example.net/ns/ext"), isNull);
        expect(xrd.link("copyright").href, equals("http://www.example.com/copyright"));
        expect(xrd.link("author").titles["en-us"], equals("The Magical World of Steve"));
        expect(xrd.links.last.propertyMap.containsKey("http://example.com/role"), isTrue);
      });

      test("4.3.  The \"rel\" Parameter", () {
        XrdDocument xrd = new XrdDocument.fromJson('''
{
 "subject" : "acct:bob@example.com",
 "aliases" :
 [
   "https://www.example.com/~bob/"
 ],
 "properties" :
 {
     "http://example.com/ns/role" : "employee"
 },
 "links" :
 [
   {
     "rel" : "http://webfinger.example/rel/profile-page",
     "href" : "https://www.example.com/~bob/"
   },
   {
     "rel" : "http://webfinger.example/rel/businesscard",
     "href" : "https://www.example.com/~bob/bob.vcf"
   }
 ]
}''');
        expect(xrd.subject, equals("acct:bob@example.com"));
        expect(xrd.aliases.last, equals("https://www.example.com/~bob/"));
        expect(xrd.link("http://webfinger.example/rel/profile-page").href, equals("https://www.example.com/~bob/"));
        expect(xrd.link("http://webfinger.example/rel/profile-page").template, isNull);
      });
    });
  });
}