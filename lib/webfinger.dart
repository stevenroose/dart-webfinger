// Copyright (c) 2015, Steven Roose. All rights reserved. Use of this source code
// is governed by a the license that can be found in the LICENSE file.

library webfinger;

import "dart:async";
import "dart:convert";

import "package:http/http.dart";


abstract class WebFinger {

  static const String _WEBFINGER_PATH = "/.well-known/webfinger";
  static const String _JRD_MIME = "application/jrd+json";

  // replace these with HttpHeaders and HttpStatus as they become available in package:http
  //  (https://github.com/dart-lang/http/issues/4)
  static const String _HTTP_HEADER_ACCEPT = "accept";
  static const int _HTTP_STATUS_OK = 200;


  final Client _client;
  final JsonDecoder _jsonDecoder;

  const WebFinger(Client client) :
      _client = client,
      _jsonDecoder = const JsonDecoder();

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
    queryBit += rel == null ? "" : "&" + rel.map((r) => "rel=${Uri.encodeQueryComponent(r)}").join("&");
    Uri query = new Uri(scheme: "https",
                        host: resourceUri.host,
                        path: _WEBFINGER_PATH,
                        query: queryBit);
    return _client.get(query, headers: {
      _HTTP_HEADER_ACCEPT: _JRD_MIME
    }).then((Response response) {
      if(response.statusCode == _HTTP_STATUS_OK) {
        return new JRDDocument.fromJSON(_jsonDecoder.convert(response.body));
      } else {
        throw new StateError("HTTP error ${response.statusCode}: ${response.body}");
      }
    });
  }

  /**
   * Shortcut method for querying accounts of the "name@host" format.
   */
  Future<JRDDocument> account(String account, {List<String> rel}) =>
      query("acct:$account", rel: rel);

}

class JRDDocument {
  final String subject;
  final String expires;
  final List<String> aliases;
  final Map<String, String> properties;
  final List<JRDLink> links;

  const JRDDocument({this.subject, this.expires, this.aliases, this.properties, this.links});

  /**
   * Find the preferred link with the given relation.
   *
   * The WebFinger protocol defines that if multiple links are provided with the same "rel", the first one
   * is the one preferred by the user.
   */
  JRDLink findLink(String rel) => links != null ? links.firstWhere((l) => l.rel == rel) : null;

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

}

class JRDLink {
  final String rel;
  final String type;
  final String href;
  final Map<String, String> titles;
  final Map<String, String> properties;

  const JRDLink({this.rel, this.type, this.href, this.titles, this.properties});

  factory JRDLink.fromJSON(Map json) =>
      new JRDLink(rel: json["rel"],
                  type: json["type"],
                  href: json["type"],
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
}