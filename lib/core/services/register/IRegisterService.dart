import '../../../data/models/RegisterModel.dart';

abstract class IRegisterService {
  Future<RegisterResponseModel?> register(String username, String email, String password);
  Future<bool> verifyRegistrationCode(String email, String code);
}
