import '../datasources/climate_remote_data_source.dart';
import '../models/climate_history_entry_dto.dart';
import '../models/climate_snapshot_dto.dart';
import '../../domain/entities/climate_history_entry.dart';
import '../../domain/entities/climate_snapshot.dart';
import '../../domain/repositories/climate_repository.dart';

class ClimateRepositoryImpl implements ClimateRepository {
  ClimateRepositoryImpl(this._remoteDataSource);

  final ClimateRemoteDataSource _remoteDataSource;

  @override
  Future<ClimateSnapshot> fetchSnapshot({
    required String username,
    required String password,
    required String deviceId,
  }) async {
    final ClimateSnapshotDto dto = await _remoteDataSource.fetchSnapshot(
      username: username,
      password: password,
      deviceId: deviceId,
    );

    final values = <String, String>{};
    for (final raw in dto.items) {
      final parts = raw.split('=');
      if (parts.length == 2) {
        values[parts[0]] = parts[1];
      }
    }

    return ClimateSnapshot(
      deviceId: deviceId,
      values: values,
      errorCode: dto.errorCode,
      errorDescription: dto.errorDescription,
    );
  }

  @override
  Future<List<ClimateHistoryEntry>> fetchHistory({
    required String username,
    required String password,
    required String deviceId,
    required String labelCode,
    required String period,
  }) async {
    final List<ClimateHistoryEntryDto> dtoList =
        await _remoteDataSource.fetchHistory(
      username: username,
      password: password,
      deviceId: deviceId,
      labelCode: labelCode,
      period: period,
    );

    return dtoList
        .map(
          (dto) => ClimateHistoryEntry(
            dateTime: dto.dateTime,
            minValue: dto.minValue,
            maxValue: dto.maxValue,
            avgValue: dto.avgValue,
          ),
        )
        .toList();
  }
}
