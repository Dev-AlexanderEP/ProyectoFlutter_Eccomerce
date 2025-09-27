import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../core/constants/ApiConstants.dart';

class GoogleLoginRemoteRepositorie {
  final http.Client client;
  final Duration timeout;

  GoogleLoginRemoteRepositorie({
    required this.client,
    this.timeout = const Duration(seconds: 15),
  });

  /// Llama al endpoint de Google Login del backend.
  /// [credential] = ID token de Google (JWT) obtenido del SDK de Google.
  /// [clientId] = el Client ID OAuth 2.0 configurado en Google Cloud (el mismo que usa tu app).
  ///
  /// Éxito (200): retorna el JSON del backend, p. ej.:
  /// {
  ///   "accessToken": "...",
  ///   "email": "...",
  ///   "name": "...",
  ///   "username": "...",
  ///   "roles": "ROLE_USER ..."
  /// }
  ///
  /// Error: retorna null y hace print del detalle.
  Future<Map<String, dynamic>?> googleLogin({
    required String credential,
    required String clientId,
  }) async {
    final url = Uri.parse(ApiConstants.googleLoginEndpoint);

    try {
      final resp = await client
          .post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode({
          'credential': credential,
          'clientId': clientId,
        }),
      )
          .timeout(timeout);

      // Asegura decodificación correcta de UTF8 en todas las plataformas
      final bodyStr = utf8.decode(resp.bodyBytes);

      if (resp.statusCode == 200) {
        return jsonDecode(bodyStr) as Map<String, dynamic>;
      } else {
        print(
            'Error googleLogin: ${resp.statusCode} - $bodyStr (url: ${resp.request?.url})');
        return null;
      }
    } on SocketException catch (e) {
      print('Error de red (googleLogin): $e');
      return null;
    } on FormatException catch (e) {
      print('Error parseando JSON (googleLogin): $e');
      return null;
    } on HttpException catch (e) {
      print('HTTP exception (googleLogin): $e');
      return null;
    }  catch (e) {
      print('Error inesperado (googleLogin): $e');
      return null;
    }
  }
}
