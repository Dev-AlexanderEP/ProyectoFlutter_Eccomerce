// lib/domain/services/forgot/ForgotPassImpl.dart

import '../../../../data/RemoteRepositorie/login/forgotPassword/ForgotPassRemoteRepositorie.dart';
import 'IForgotPass.dart';


class ForgotPassImpl implements IForgotPass {
  final ForgotPassRemoteRepositorie remoteDataSource;

  ForgotPassImpl({required this.remoteDataSource});

  @override
  Future<bool> sendVerificationCode({
    required String email,
    required String code,
  }) async {
    // Aquí podrías agregar validaciones locales (formato del email, 5 dígitos, etc.)
    return await remoteDataSource.sendVerificationCode(
      email: email,
      code: code,
    );
  }
  @override
  Future<bool> verifyCode({
    required String email,
    required String code,
  }) async {
    // Validaciones locales opcionales
    return await remoteDataSource.verifyCode(
      email: email,
      code: code,
    );
  }
}
