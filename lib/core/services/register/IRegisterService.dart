import '../../../data/models/RegisterModel.dart';
import '../../constants/ApiResponse.dart';

abstract class IRegisterService {
  Future<ApiResponse<RegisterResponseModel>?> register(String username, String email, String password);
}
