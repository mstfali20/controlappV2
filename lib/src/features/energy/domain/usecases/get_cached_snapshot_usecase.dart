import '../entities/energy_snapshot.dart';
import '../repositories/energy_repository.dart';

class GetCachedSnapshotUseCase {
  GetCachedSnapshotUseCase(this._repository);

  final EnergyRepository _repository;

  EnergySnapshot? call(String deviceId) =>
      _repository.getCachedSnapshot(deviceId);
}
