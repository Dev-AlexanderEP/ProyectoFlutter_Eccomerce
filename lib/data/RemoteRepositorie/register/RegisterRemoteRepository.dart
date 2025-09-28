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

    try {
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
        return jsonDecode(response.body);
      } else {
        print("Error en registro: ${response.statusCode} - ${response.body}");
        return {
          'success': false,
          'message': 'Error al registrar usuario: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("Excepción al registrar: $e");
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  Future<Map<String, dynamic>?> verifyRegistrationCode({
    required String email,
    required String code,
  }) async {
    final url = Uri.parse(ApiConstants.registerVerifyCodeEndpoint);

    try {
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
        print("Error en verificación: ${response.statusCode} - ${response.body}");
        return {
          'success': false,
          'message': 'Código de verificación inválido',
        };
      }
    } catch (e) {
      print("Excepción al verificar código: $e");
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}
