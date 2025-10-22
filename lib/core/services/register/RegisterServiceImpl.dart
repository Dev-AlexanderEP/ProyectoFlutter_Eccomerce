import '../../../data/RemoteRepositorie/register/RegisterRemoteRepository.dart';
import '../../../data/models/RegisterModel.dart';
import '../../constants/ApiResponse.dart';
import 'IRegisterService.dart';

class RegisterServiceImpl implements IRegisterService {
  final RegisterRemoteRepository remoteDataSource;

  RegisterServiceImpl({required this.remoteDataSource});

  @override
  Future<ApiResponse<RegisterResponseModel>?> register(String username, String email, String password) async {
    final result = await remoteDataSource.register(
      username: username,
      email: email,
      password: password,
    );

    if (result != null) {
      return RegisterResponseModel.fromApiResponseJson(result);
    }
    return null;
  }
}
