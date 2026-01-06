import '../entities/energy_snapshot.dart';
import '../entities/energy_consumption.dart';
import '../entities/energy_consumption_history.dart';
import '../entities/energy_category_breakdown.dart';

abstract class EnergyRepository {
  Future<EnergySnapshot> fetchCurrentData({
    required String username,
    required String password,
    required String deviceId,
  });

  Future<void> cacheSnapshot(EnergySnapshot snapshot);

  EnergySnapshot? getCachedSnapshot(String deviceId);

  Future<EnergyConsumption> fetchConsumptionSummary({
    required String username,
    required String password,
    required String deviceId,
    required String periodType,
    required String type,
    required String totalCheckPt,
    required String term,
  });

  Future<EnergyConsumptionHistory> fetchConsumptionHistory({
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

  Future<EnergyCategoryBreakdown> fetchCategoryBreakdown({
    required String username,
    required String password,
    required String organizationId,
    required String periodType,
    required String term,
  });
}
