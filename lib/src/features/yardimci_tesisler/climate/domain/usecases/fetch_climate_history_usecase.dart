import '../entities/climate_history_entry.dart';
import '../repositories/climate_repository.dart';

class FetchClimateHistoryUseCase {
  FetchClimateHistoryUseCase(this._repository);

  final ClimateRepository _repository;

  Future<List<ClimateHistoryEntry>> call(FetchClimateHistoryParams params) {
    return _repository.fetchHistory(
      username: params.username,
      password: params.password,
      deviceId: params.deviceId,
      labelCode: params.labelCode,
      period: params.period,
    );
  }
}

class FetchClimateHistoryParams {
  const FetchClimateHistoryParams({
    required this.username,
    required this.password,
    required this.deviceId,
    required this.labelCode,
    required this.period,
  });

  final String username;
  final String password;
  final String deviceId;
  final String labelCode;
  final String period;

  FetchClimateHistoryParams copyWith({
    String? username,
    String? password,
    String? deviceId,
    String? labelCode,
    String? period,
  }) {
    return FetchClimateHistoryParams(
      username: username ?? this.username,
      password: password ?? this.password,
      deviceId: deviceId ?? this.deviceId,
      labelCode: labelCode ?? this.labelCode,
      period: period ?? this.period,
    );
  }
}
