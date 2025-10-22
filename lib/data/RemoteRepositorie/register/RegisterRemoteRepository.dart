import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/ApiConstants.dart';

class RegisterRemoteRepository {
  final http.Client client;

  RegisterRemoteRepository({required this.client});

  Future<Map<String, dynamic>?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(ApiConstants.registerEndpoint);

    final response = await client.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "nombreUsuario": username,
        "email": email,
        "contrasenia": password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      print("Error registro: ${response.statusCode} - ${response.body}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyRegistrationCode({
    required String email,
    required String code,
  }) async {
    final url = Uri.parse(ApiConstants.registerVerifyCodeEndpoint);

    final response = await client.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "code": code,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error verificación: ${response.statusCode} - ${response.body}");
      return null;
    }
  }
}