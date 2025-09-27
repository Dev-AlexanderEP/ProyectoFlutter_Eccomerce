
import '../../../data/RemoteRepositorie/login/LoginAuthRemoteRepositorie.dart';
import '../../../data/models/AuthResponseModel.dart';
import 'IAuthService.dart';

class AuthServiceImpl implements IAuthService {
  final AuthRemoteRepositorie remoteDataSource;

  AuthServiceImpl({required this.remoteDataSource});

  @override
  Future<AuthResponseModel?> login(String username, String password) async {
    final result = await remoteDataSource.login(
      username: username,
      password: password,
    );

    if (result != null) {
      return AuthResponseModel.fromJson(result);
    }
    return null;
  }

  @override
  Future<void> logout() async {
    // Aquí puedes limpiar tokens de SecureStorage o notificar al backend
    print("Logout ejecutado (aquí borras tokens locales).");
  }

  @override
  Future<AuthResponseModel?> refreshToken(String refreshToken) async {
    final result = await remoteDataSource.refresh(refreshToken);
    if (result != null) {
      return AuthResponseModel.fromJson(result);
    }
    return null;
  }
  @override
  Future<bool> resetPassword({
    required String newPassword,
    String? email,
    String? code,
  }) async {
    final result = await remoteDataSource.resetPassword(newPassword: newPassword, email: email, code: code);
    if (result != null) {
      return true;
    }
    return false;
    // Implementa la lógica para resetear la contraseña.
    // Esto podría implicar llamar a otro endpoint en remoteDataSource.
    // print("Reset password ejecutado (implementa la lógica aquí).");
  }
}
