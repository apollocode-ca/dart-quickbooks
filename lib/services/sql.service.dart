import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:quickbooks/quickbooks.dart';

class SQLService {
  /// Run a SQL query on Quickbook
  static Future<dynamic> runQuery(
      String code, String accessToken, String query) async {
    return await http.get(
        V3_ENDPOINT_BASE_URL + "$code/query?query=$query&minorversion=40",
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
