// lib/features/auth/controllers/RegisterFlowController.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class RegisterFlowController extends ChangeNotifier {
  int _state = 0; // 0: registro, 1: verificación
  String? _username;
  String? _email;
  String? _password;
  DateTime? _expiresAt;

  int get state => _state;
  String? get username => _username;
  String? get email => _email;
  String? get password => _password;
  DateTime? get expiresAt => _expiresAt;

  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _state = prefs.getInt('register_state') ?? 0;
    _username = prefs.getString('register_username');
    _email = prefs.getString('register_email');
    _password = prefs.getString('register_password');
    final expiresMillis = prefs.getInt('register_expires_at');
    if (expiresMillis != null) {
      _expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresMillis);
    }
    notifyListeners();
  }

  Future<void> saveState({
    required int state,
    String? username,
    String? email,
    String? password,
    DateTime? expiresAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('register_state', state);
    if (username != null) await prefs.setString('register_username', username);
    if (email != null) await prefs.setString('register_email', email);
    if (password != null) await prefs.setString('register_password', password);
    if (expiresAt != null) await prefs.setInt('register_expires_at', expiresAt.millisecondsSinceEpoch);
    _state = state;
    _username = username;
    _email = email;
    _password = password;
    _expiresAt = expiresAt;
    notifyListeners();
  }

  Future<void> reset() async {
    await saveState(state: 0, username: null, email: null, password: null, expiresAt: null);
  }
}