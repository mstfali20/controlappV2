import '../entities/climate_history_entry.dart';
import '../entities/climate_snapshot.dart';

abstract class ClimateRepository {
  Future<ClimateSnapshot> fetchSnapshot({
    required String username,
    required String password,
    required String deviceId,
  });

  Future<List<ClimateHistoryEntry>> fetchHistory({
    required String username,
    required String password,
    required String deviceId,
    required String labelCode,
    required String period,
  });
}
