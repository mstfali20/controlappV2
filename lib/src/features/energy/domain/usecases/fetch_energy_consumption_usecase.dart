import '../entities/energy_consumption.dart';
import '../repositories/energy_repository.dart';

class FetchEnergyConsumptionParams {
  const FetchEnergyConsumptionParams({
    required this.username,
    required this.password,
    required this.deviceId,
    required this.periodType,
    required this.type,
    required this.totalCheckPt,
    required this.term,
  });

  final String username;
  final String password;
  final String deviceId;
  final String periodType;
  final String type;
  final String totalCheckPt;
  final String term;
}

class FetchEnergyConsumptionUseCase {
  FetchEnergyConsumptionUseCase(this._repository);

  final EnergyRepository _repository;

  Future<EnergyConsumption> call(FetchEnergyConsumptionParams params) {
    return _repository.fetchConsumptionSummary(
      username: params.username,
      password: params.password,
      deviceId: params.deviceId,
      periodType: params.periodType,
      type: params.type,
      totalCheckPt: params.totalCheckPt,
      term: params.term,
    );
  }
}
