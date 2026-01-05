import '../entities/session.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  const LoginParams({
    required this.username,
    required this.password,
    this.deviceToken,
  });

  final String username;
  final String password;
  final String? deviceToken;
}

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Session> call(LoginParams params) {
    return _repository.login(
      params.username,
      params.password,
      deviceToken: params.deviceToken,
    );
  }
}
