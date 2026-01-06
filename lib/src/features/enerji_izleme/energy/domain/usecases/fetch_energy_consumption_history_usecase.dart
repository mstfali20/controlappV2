import '../entities/energy_consumption_history.dart';
import '../repositories/energy_repository.dart';

class FetchEnergyConsumptionHistoryParams {
  const FetchEnergyConsumptionHistoryParams({
    required this.username,
    required this.password,
    required this.deviceId,
    required this.periodType,
    required this.type,
    required this.totalCheckPt,
    required this.term,
    required this.startDate,
    required this.endDate,
  });

  final String username;
  final String password;
  final String deviceId;
  final String periodType;
  final String type;
  final String totalCheckPt;
  final String term;
  final String startDate;
  final String endDate;
}

class FetchEnergyConsumptionHistoryUseCase {
  FetchEnergyConsumptionHistoryUseCase(this._repository);

  final EnergyRepository _repository;

  Future<EnergyConsumptionHistory> call(
    FetchEnergyConsumptionHistoryParams params,
  ) {
    return _repository.fetchConsumptionHistory(
      username: params.username,
      password: params.password,
      deviceId: params.deviceId,
      periodType: params.periodType,
      type: params.type,
      totalCheckPt: params.totalCheckPt,
      term: params.term,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
