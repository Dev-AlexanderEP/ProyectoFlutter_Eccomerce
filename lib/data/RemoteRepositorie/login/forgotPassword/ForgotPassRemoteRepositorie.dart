// lib/data/RemoteRepositorie/forgot/ForgotPassRemoteRepositorieImpl.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/ApiConstants.dart';

class ForgotPassRemoteRepositorie {
  final http.Client _client;

  ForgotPassRemoteRepositorie({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<bool> sendVerificationCode({
    required String email,
    required String code,
  }) async {
    final uri = Uri.parse(ApiConstants.forgotPasswordEndpoint);

    final resp = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    // Spring devuelve 200 OK sin body cuando todo va bien
    return resp.statusCode == 200;
  }

  @override
  Future<bool> verifyCode({
    required String email,
    required String code,
  }) async {
    final uri = Uri.parse(ApiConstants.verifyCodeEndpoint);

    final resp = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    return resp.statusCode == 200;
  }

}
