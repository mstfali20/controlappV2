import '../entities/renewable_energy_consumption_history.dart';

abstract class RenewableEnergyRepository {
  Future<RenewableEnergyConsumptionHistory> fetchConsumptionHistory({
    required String username,
    required String password,
    required String deviceId,
    required String periodType,
    required String type,
    required String totalCheckPt,
    required String term,
    required String startDate,
    required String endDate,
  });
}
