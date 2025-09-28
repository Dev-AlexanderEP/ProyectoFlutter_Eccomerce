import '../../../data/RemoteRepositorie/register/RegisterRemoteRepository.dart';
import '../../../data/models/RegisterModel.dart';
import 'IRegisterService.dart';

class RegisterServiceImpl implements IRegisterService {
  final RegisterRemoteRepository remoteDataSource;

  RegisterServiceImpl({required this.remoteDataSource});

  @override
  Future<RegisterResponseModel?> register(String username, String email, String password) async {
    final result = await remoteDataSource.register(
      username: username,
      email: email,
      password: password,
    );

    if (result != null) {
      return RegisterResponseModel.fromJson(result);
    }
    return null;
  }

  @override
  Future<bool> verifyRegistrationCode(String email, String code) async {
    final result = await remoteDataSource.verifyRegistrationCode(
      email: email,
      code: code,
    );

    if (result != null) {
      return result['success'] ?? false;
    }
    return false;
  }
}
