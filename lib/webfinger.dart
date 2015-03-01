// Copyright (c) 2015, Steven Roose. All rights reserved. Use of this source code
// is governed by a the license that can be found in the LICENSE file.

library webfinger;


import "dart:async";
import "dart:convert";

import "package:collection/equality.dart";
import "package:http/http.dart";


class WebFinger {

  static const String _WEBFINGER_PATH = "/.well-known/webfinger";
  static const String _JRD_MIME = "application/jrd+json";

  // replace these with HttpHeaders and HttpStatus as they become available in package:http
  //  (https://github.com/dart-lang/http/issues/4)
  static const String _HTTP_HEADER_ACCEPT = "accept";
  static const int _HTTP_STATUS_OK = 200;


  final Client _client;

  const WebFinger(Client client) : _client = client;

  /**
   * Perform a WebFinger query for the given [resource].
   *
   * If [rel] is provided, only those relations will be requested from the WebFinger provider. Depending on whether
   * or not the provider supports the parameter, only those relations will be in the resulting JRD document.
   */
  Future<JRDDocument> query(dynamic/*Uri|String*/ resource, {List<String> rel}) {
    // parse uri, throws if not a valid format
    Uri resourceUri = resource is Uri ? resource : Uri.parse(resource);
    // manually building a URI with multiple rel keys in the query (dart:core.Uri does not support that)
    String queryBit = "resource=$resourceUri";
    queryBit += rel == null ? "" : ("&" + rel.map((r) => "rel=${Uri.encodeQueryComponent(r)}").join("&"));
    Uri query = new Uri(scheme: "https", // "A client MUST query the WebFinger resource using HTTPS only.", RFC 7033
                        host: _getHost(resourceUri),
                        path: _WEBFINGER_PATH,
                        query: queryBit);
    return _client.get(query, headers: {
      _HTTP_HEADER_ACCEPT: _JRD_MIME
    }).then((Response response) {
      if(response.statusCode == _HTTP_STATUS_OK) {
        return new JRDDocument.fromJSON(const JsonDecoder().convert(response.body));
      } else {
        throw new StateError("HTTP error ${response.statusCode}: ${response.body}");
      }
    });
  }

  String _getHost(Uri uri) {
    if(uri.host != null && uri.host != "")
      return uri.host;
    // now we have an URI of the form "scheme:user@host"
    return uri.path.split("@")[1];
  }

  /**
   * Shortcut method for querying accounts of the "name@host" format.
   */
  Future<JRDDocument> account(String account, {List<String> rel}) {
    Uri address = Uri.parse(account);
    if(address.authority == "") {
      if(address.scheme == "") {
        return query(address.replace(scheme: "acct"), rel: rel);
      } else {
        return query(address, rel: rel);
      }
    }
    throw new ArgumentError("Please provide a valid account identifier.");
  }

}

class JRDDocument {
  final String subject;
  final String expires;
  final Iterable<String> aliases;
  final Map<String, String> properties;
  final Iterable<JRDLink> links;

  JRDDocument({String this.subject, String this.expires, Iterable<String> this.aliases, Map<String, String> this.properties, Iterable<JRDLink> links})
      : this.links = links != null ? links : new List<JRDLink>();

  /**
   * Find the preferred link with the given relation.
   *
   * The WebFinger protocol defines that if multiple links are provided with the same "rel", the first one
   * is the one preferred by the user.
   */
  JRDLink link(String rel) => links.firstWhere((l) => l.rel == rel);

  /**
   * Decode from the JSON format described in [RFC 6415](https://tools.ietf.org/html/rfc6415).
   */
  factory JRDDocument.fromJSON(Map json) =>
      new JRDDocument(subject: json["subject"],
                      expires: json["expires"],
                      aliases: json["aliases"],
                      properties: json["properties"],
                      links: json.containsKey("links") ? json["links"].map((l) => new JRDLink.fromJSON(l)) : null);

  /**
   * Encode to the JSON format described in [RFC 6415](https://tools.ietf.org/html/rfc6415).
   */
  Map<String, Object> toJSON() {
    Map<String, Object> json = new Map<String, Object>();
    if(subject != null)
      json["subject"] = subject;
    if(expires != null)
      json["expires"] = expires;
    if(aliases != null)
      json["aliases"] = aliases;
    if(properties != null)
      json["properties"] = properties;
    if(links != null)
      json["links"] = links.map((l) => l.toJSON());
    return json;
  }

  @override
  String toString() => toJSON().toString();

  @override
  bool operator ==(other) => other is JRDDocument && const DeepCollectionEquality().equals(
      [subject, expires, aliases, properties, links],
      [other.subject, other.expires, other.aliases, other.properties, other.links]);

  @override
  int get hashCode => const DeepCollectionEquality().hash(
      [subject, expires, aliases, properties, links]);

}

class JRDLink {
  final String rel;
  final String type;
  final String href;
  final Map<String, String> titles;
  final Map<String, String> properties;

  JRDLink({String this.rel, String this.type, String this.href, Map<String, String> this.titles, Map<String, String> this.properties}) {
    if(rel == null) {
      throw new ArgumentError("The rel parameter is required.");
    }
  }

  factory JRDLink.fromJSON(Map json) =>
      new JRDLink(rel: json["rel"],
                  type: json["type"],
                  href: json["href"],
                  titles: json["titles"],
                  properties: json["properties"]);

  Map<String, Object> toJSON() {
    Map<String, Object> json = new Map<String, Object>();
    if(rel != null)
      json["rel"] = rel;
    if(type != null)
      json["type"] = type;
    if(href != null)
      json["href"] = href;
    if(titles != null)
      json["titles"] = titles;
    if(properties != null)
      json["properties"] = properties;
    return json;
  }

  @override
  String toString() => toJSON().toString();

  @override
  bool operator ==(other) => other is JRDLink && const DeepCollectionEquality().equals(
      [rel, type, href, titles, properties],
      [other.rel, other.type, other.titles, other.properties]);

  @override
  int get hashCode => const DeepCollectionEquality().hash(
      [rel, type, href, titles, properties]);
}