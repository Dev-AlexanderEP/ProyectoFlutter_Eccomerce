import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://localhost:8080";

  Future<String?> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/token');

    final response = await http.post(
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
      final data = jsonDecode(response.body);
      return data["access_token"]; // depende de cómo responda tu API
    } else {
      print("Error: ${response.statusCode} - ${response.body}");
      return null;
    }
  }
}
