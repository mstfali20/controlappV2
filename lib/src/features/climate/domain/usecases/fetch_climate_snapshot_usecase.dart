import '../entities/climate_snapshot.dart';
import '../repositories/climate_repository.dart';

class FetchClimateSnapshotUseCase {
  FetchClimateSnapshotUseCase(this._repository);

  final ClimateRepository _repository;

  Future<ClimateSnapshot> call(FetchClimateSnapshotParams params) {
    return _repository.fetchSnapshot(
      username: params.username,
      password: params.password,
      deviceId: params.deviceId,
    );
  }
}

class FetchClimateSnapshotParams {
  const FetchClimateSnapshotParams({
    required this.username,
    required this.password,
    required this.deviceId,
  });

  final String username;
  final String password;
  final String deviceId;
}
