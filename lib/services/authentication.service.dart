import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:quickbooks/quickbooks.dart';

class AuthenticationService {
  static String prepareUrl(String redirectUri, String clientId) {
    var data = {
      "client_id": clientId, // Application token
      "scope": "com.intuit.quickbooks.accounting",
      "redirect_uri": redirectUri,
      "response_type": "code",
      "state": "authState",
    };

    return Uri.https(APP_CENTER_BASE_NO_PROTOCOL, "/connect/oauth2", data)
        .toString();
  }

  /// OAuth2.0 Authentication method
  static Future<dynamic> authenticate(
      String qbToken, String qbSecret, String code, String redirectUri) async {
    var credentials = qbToken + ":" + qbSecret;
    Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
    String encoded = stringToBase64Url.encode(credentials);
    var data = {
      "code": code,
      "redirect_uri": redirectUri,
      "grant_type": "authorization_code"
    };
    return await http.post(TOKEN_URL, body: data, headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
      "Authorization": "Basic " + encoded
    }).then((response) async {
      switch (response.statusCode) {
        case 200:
          return response.body;
          break;

        default:
          throw new ErrorDescription(response.statusCode.toString());
          break;
      }
    });
  }

  static Future<dynamic> disconnect(
      String qbToken, String qbSecret, String accessToken) async {
            print("*********************************");
            print(accessToken);
    var credentials = qbToken + ":" + qbSecret;
    Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
    String encoded = stringToBase64Url.encode(credentials);
    var data = {
      "token": accessToken,
    };
    return await http.post(REVOKE_URL, body: data, headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
      "Authorization": "Basic " + encoded
    }).then((response) async {
      switch (response.statusCode) {
        case 200:
          print(response.statusCode);
          return response.body;
          break;

        default:
          print(response.statusCode);
          throw new ErrorDescription(response.statusCode.toString());
          break;
      }
    });
  }
}
