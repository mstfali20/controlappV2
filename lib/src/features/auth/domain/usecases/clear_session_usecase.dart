import '../repositories/auth_repository.dart';

class ClearSessionUseCase {
  const ClearSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() {
    return _repository.clearSession();
  }
}
