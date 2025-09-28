import 'package:http/http.dart' as http;
import 'IRegisterService.dart';
import '../../../data/models/RegisterModel.dart';

class TempRegisterService implements IRegisterService {
  final http.Client client;

  TempRegisterService({required this.client});

  @override
  Future<RegisterResponseModel?> register(String username, String email, String password) async {
    // Simular delay de red real
    await Future.delayed(Duration(milliseconds: 1500));
    
    // Simular respuesta exitosa del backend
    print("✅ [TEMP] Registro simulado exitoso para: $username ($email)");
    
    return RegisterResponseModel(
      success: true,
      message: 'Usuario registrado exitosamente (MODO TEMPORAL)',
      userId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  @override
  Future<bool> verifyRegistrationCode(String email, String code) async {
    await Future.delayed(Duration(milliseconds: 1000));
    
    // Simular verificación exitosa
    print("✅ [TEMP] Código verificado para: $email, código: $code");
    
    return true; // Siempre exitoso en modo temporal
  }
}
