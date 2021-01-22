import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:quickbooks/quickbooks.dart';

/// A Static class to perform SQL related actions
/// on the Quickbooks Online API
class SQLService {
  /// Runs am SQL [query] on Quickbooks Online API
  /// Must be authenticated to run. The company [code] must
  /// be provided.
  static Future<dynamic> runQuery(
      String code, String accessToken, String query) async {
    return await http.get(
        Quickbooks.v3EndpointBaseUrl +
            "$code/query?query=$query&minorversion=40",
        headers: {
          "Accept": "application/json",
          // 'Content-Type': 'application/json',
          "Authorization": "Bearer " + accessToken
        }).then((response) async {
      switch (response.statusCode) {
        case 200:
          return response.body;
          break;

        case 403:
          throw new ErrorDescription("Fordbidden");
          break;

        default:
          throw new ErrorDescription(response.statusCode.toString());
          break;
      }
    });
  }
}
