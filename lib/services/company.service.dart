import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:quickbooks/Models/company.dart';
import 'package:quickbooks/quickbooks.dart';

/// A Static class to obtain the authenticated company
class CompanyService {
  /// Runs am SQL [query] on Quickbooks Online API
  /// to return the current company
  static Future<Company> getCompany(String code, String accessToken) async {
    final query = "select * from CompanyInfo";
    return await http.get(
        Quickbooks.v3EndpointBaseUrl +
            "$code/query?query=$query&minorversion=40",
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer " + accessToken
        }).then((response) async {
      switch (response.statusCode) {
        case 200:
          var mappedBody =
              jsonDecode(response.body)["QueryResponse"]["CompanyInfo"][0];
          print(response.body);
          return new Company(mappedBody["CompanyName"]);
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
