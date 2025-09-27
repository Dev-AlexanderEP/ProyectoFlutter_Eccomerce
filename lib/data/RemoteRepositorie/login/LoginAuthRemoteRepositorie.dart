import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/constants/ApiConstants.dart';

class AuthRemoteRepositorie {
  final http.Client client;

  AuthRemoteRepositorie({required this.client});

  Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse(ApiConstants.loginEndpoint);

    final response = await client.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "username": username,
        "password": password,
        "grantType": "password",
        "withRefreshToken": "true",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error login: ${response.statusCode} - ${response.body}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> refresh(String refreshToken) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/refresh");

    final response = await client.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({"refreshToken": refreshToken}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error refresh: ${response.statusCode} - ${response.body}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> resetPassword({
    required String newPassword,
    String? email,
    String? code,
  }) async {
    final url = Uri.parse(ApiConstants.resetPasswordEndpoint);

    final response = await client.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "newPassword": newPassword,
        if (email != null) "email": email,
        if (code != null) "code": code,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error resetPassword: ${response.statusCode} - ${response.body}");
      return null;
    }
  }
}
