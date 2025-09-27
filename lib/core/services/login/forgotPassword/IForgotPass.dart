// lib/domain/services/forgot/IForgotPass.dart

/// Contrato para el envío del código de verificación por email.
abstract class IForgotPass {
  /// Envía el [code] (5 dígitos) al [email] mediante el backend.
  /// Devuelve true si el backend respondió 200 OK.
  Future<bool> sendVerificationCode({
    required String email,
    required String code,
  });
  // Verifica si el [code] ingresado por el usuario coincide con el guardado en backend.
  /// Devuelve true si el backend respondió 200 OK.
  Future<bool> verifyCode({
    required String email,
    required String code,
  });
}
