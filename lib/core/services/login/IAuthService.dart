

import '../../../data/models/AuthResponseModel.dart';

/// Contrato que define lo que el AuthRepository debe ofrecer.
/// La UI o el Controller siempre dependerá de esta interfaz, no de la implementación.
abstract class IAuthService {
  Future<AuthResponseModel?> login(String username, String password);
  Future<void> logout();
  Future<AuthResponseModel?> refreshToken(String refreshToken);

  Future<bool> resetPassword({
    // si tu backend acepta email+code directamente:
    String? email,
    required String newPassword,
    String? code,
  });
}
