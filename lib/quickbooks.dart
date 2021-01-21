library quickbooks;

import 'dart:convert';

import 'package:quickbooks/services/sql.service.dart';

import 'services/authentication.service.dart';

const APP_CENTER_BASE = 'https://appcenter.intuit.com';
const APP_CENTER_BASE_NO_PROTOCOL = 'appcenter.intuit.com';
const V3_ENDPOINT_BASE_URL =
    'https://sandbox-quickbooks.api.intuit.com/v3/company/';
const QUERY_OPERATORS = ['=', 'IN', '<', '>', '<=', '>=', 'LIKE'];
const TOKEN_URL = 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer';
const REVOKE_URL = 'https://developer.api.intuit.com/v2/oauth2/tokens/revoke';
const REDIRECT_URL = 'https://appcenter.intuit.com/connect/oauth2';

/// Manager for every API Calls
class Quickbooks {
  // Application QB token
  final String qbToken;
  // Application QB Secret
  final String qbSecret;
  // Application redirect URI
  final String redirectUri;

  // Authenticated Consumer Key
  String consumerCode;
  // Authenticated Consumer Secret
  final String consumerSecret;
  // Authenticated Consumer business id
  String consumerRealmId;
  // Authenticated Consumer access token
  String accessToken;
  String refreshToken;

  // Set to true to see logs
  final bool debug;
  // Set to true to use the sandBox config
  final bool useSandbox;

  String _environment;

  Quickbooks(this.qbSecret, this.qbToken, this.redirectUri,
      {this.debug = false,
      this.useSandbox = false,
      this.consumerCode = '',
      this.consumerSecret = ''}) {
    this._environment = (useSandbox) ? "development" : "production";
  }

  String prepareUri() {
    return AuthenticationService.prepareUrl(this.redirectUri, this.qbToken);
  }

  // Authenticate the user using previous informations gathered via OAuth2
  Future<bool> authenticate(
      String _consumerKey, String _consumerRealmId) async {
    this.consumerCode = _consumerKey;
    this.consumerRealmId = _consumerRealmId;
    if (debug) {
      print("CONSUMER KEY : $_consumerKey");
    }
    var res = await AuthenticationService.authenticate(
            qbToken, qbSecret, consumerCode, redirectUri)
        .then((body) {
      Map<String, dynamic> mappedBody = jsonDecode(body);
      if (debug) {
        print(mappedBody);
      }

      this.accessToken = mappedBody["access_token"];
      this.refreshToken = mappedBody["refresh_token"];
      return true;
    }, onError: (error) {
      if (debug) {
        print("AN ERROR OCCURED : $error");
      }
      return false;
    });

    return res;
  }

  /// Disconnects the current customer
  Future<bool> disconnect() async {
    var res =
        await AuthenticationService.disconnect(qbToken, qbSecret, accessToken)
            .then((body) {
              accessToken = null;
              refreshToken = null;
      return true;
    }, onError: (error) {
      if (debug) {
        print("AN ERROR OCCURED : $error");
      }
      return false;
    });

    return res;
  }

  /// Run an SQL Query in Quickbooks Online
  Future<dynamic> runQuery(String query) async {
    if (this.accessToken.isEmpty) {
      throw new NullThrownError();
    }

    var res =
        SQLService.runQuery(consumerRealmId, accessToken, query).then((body) {
      Map<String, dynamic> mappedBody = jsonDecode(body);
      return mappedBody["QueryResponse"];
    }, onError: (error) {
      throw Error();
    });

    return res;
  }
}
