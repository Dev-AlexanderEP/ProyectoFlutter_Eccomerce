import 'dart:math';

import 'package:flutter/material.dart';
import 'package:proyecto_flutter/core/services/login/IAuthService.dart';
import 'package:proyecto_flutter/core/services/login/forgotPassword/IForgotPass.dart';
import 'package:proyecto_flutter/core/services/register/IRegisterService.dart';
import 'package:proyecto_flutter/data/models/RegisterModel.dart';

import '../../../core/constants/ApiResponse.dart';


class AuthController extends ChangeNotifier {
  final IAuthService _authService;
  final IForgotPass _forgotPass;
  final IRegisterService _registerService;

  AuthController({
    required IAuthService authService, 
    required IForgotPass forgotPass,
    required IRegisterService registerService,
  }) : _authService = authService, 
       _forgotPass = forgotPass,
       _registerService = registerService;

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

  Future<bool> sendCodeEmail(String email) async {
    // Generar código aleatorio de 5 dígitos
    final random = Random();
    final code = (10000 + random.nextInt(90000)).toString();
    // Esto asegura que el número siempre tenga 5 dígitos (10000–99999)

    // Llamar al servicio remoto
    return await _forgotPass.sendVerificationCode(
      email: email,
      code: code,
    );
  }
  Future<bool> verifyCodeEmail({
    required String email,
    required String inputCode,
  }) async {
    try {
      final ok = await _forgotPass.verifyCode(
        email: email,
        code: inputCode,
      );

      return ok;
    } catch (e) {
      // Aquí podrías hacer logging o manejar errores específicos
      return false;
    }
  }
  Future<bool> resetPassword({
    required String newPassword,
    String? email,
    String? code,
  }) async {
    final success = await _authService.resetPassword(
      newPassword: newPassword,
      email: email,
      code: code,
    );
    return success;
  }

  // Métodos de registro
  Future<ApiResponse<RegisterResponseModel>?> register(String username, String email, String password) async {
    final result = await _registerService.register(username, email, password);
    return result;
  }


}
