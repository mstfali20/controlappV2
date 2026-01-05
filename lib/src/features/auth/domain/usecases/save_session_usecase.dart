import '../entities/session.dart';
import '../repositories/auth_repository.dart';

class SaveSessionParams {
  const SaveSessionParams({
    required this.session,
  });

  final Session session;
}

class SaveSessionUseCase {
  const SaveSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(SaveSessionParams params) {
    return _repository.saveSession(params.session);
  }
}
