import 'package:flutter/material.dart';

import '../../../core/services/AuthService.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _token;
  String? get token => _token;

  Future<bool> login(String username, String password) async {
    final result = await _authService.login(username, password);
    if (result != null) {
      _token = result;
      notifyListeners();
      return true;
    }
    return false;
  }
}