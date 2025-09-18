import 'package:flutter/material.dart';
import 'package:proyecto_flutter/core/services/login/IAuthService.dart';


class AuthController extends ChangeNotifier {
  final IAuthService _authService;

  AuthController({required IAuthService authService})
      : _authService = authService;

  String? _token;
  String? get token => _token;

  Future<bool> login(String username, String password) async {
    final result = await _authService.login(username, password);
    if (result != null) {
      _token = result.accessToken;
      notifyListeners();
      return true;
    }
    return false;
  }
}
