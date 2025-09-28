import 'package:http/http.dart' as http;
import 'IAuthService.dart';
import '../../../data/models/AuthResponseModel.dart';

class TempAuthService implements IAuthService {
  final http.Client client;

  TempAuthService({required this.client});

  @override
  Future<AuthResponseModel?> login(String username, String password) async {
    // Simular delay de red real
    await Future.delayed(Duration(milliseconds: 1200));
    
    // Simular login exitoso
    print("✅ [TEMP] Login simulado exitoso para: $username");
    
    return AuthResponseModel(
      accessToken: 'temp_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'temp_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(Duration(milliseconds: 500));
    print("✅ [TEMP] Logout simulado exitoso");
  }

  @override
  Future<AuthResponseModel?> refreshToken(String refreshToken) async {
    await Future.delayed(Duration(milliseconds: 800));
    
    print("✅ [TEMP] Refresh token simulado exitoso");
    
    return AuthResponseModel(
      accessToken: 'temp_new_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'temp_new_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<bool> resetPassword({
    String? email,
    required String newPassword,
    String? code,
  }) async {
    await Future.delayed(Duration(milliseconds: 1000));
    
    print("✅ [TEMP] Reseteo de contraseña simulado exitoso para: $email");
    
    return true; // Siempre exitoso en modo temporal
  }
}
