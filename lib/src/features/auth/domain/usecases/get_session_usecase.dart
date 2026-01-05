import '../entities/session.dart';
import '../repositories/auth_repository.dart';

class GetSessionUseCase {
  const GetSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<Session?> call() {
    return _repository.getSession();
  }
}
