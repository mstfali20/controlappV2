import 'dart:developer';

import '../datasources/energy_remote_data_source.dart';
import '../models/energy_data_dto.dart';
import '../models/energy_consumption_dto.dart';
import '../models/energy_category_dto.dart';
import '../../domain/entities/energy_snapshot.dart';
import '../../domain/entities/energy_consumption.dart';
import '../../domain/entities/energy_consumption_history.dart';
import '../../domain/entities/energy_consumption_record.dart';
import '../../domain/entities/energy_category_breakdown.dart';
import '../../domain/utils/energy_value_parser.dart';
import '../../domain/repositories/energy_repository.dart';

class EnergyRepositoryImpl implements EnergyRepository {
  EnergyRepositoryImpl(this._remoteDataSource);

  final EnergyRemoteDataSource _remoteDataSource;
  final Map<String, EnergySnapshot> _cache = {};

  @override
  Future<EnergySnapshot> fetchCurrentData({
    required String username,
    required String password,
    required String deviceId,
  }) async {
    try {
      final dto = await _remoteDataSource.fetchCurrentData(
        username: username,
        password: password,
        deviceId: deviceId,
      );
      final snapshot = _mapDto(deviceId, dto);
      _cache[deviceId] = snapshot;
      return snapshot;
    } on EnergyDataException catch (error) {
      log('energy_fetch_failed', error: error);
      rethrow;
    }
  }

  @override
  Future<void> cacheSnapshot(EnergySnapshot snapshot) async {
    _cache[snapshot.deviceId] = snapshot;
  }

  @override
  EnergySnapshot? getCachedSnapshot(String deviceId) => _cache[deviceId];

  EnergySnapshot _mapDto(String deviceId, EnergyDataDto dto) {
    final map = <String, String>{};
    for (final entry in dto.items) {
      final parts = entry.split('=');
      if (parts.length == 2) {
        map[parts[0]] = parts[1];
      }
    }
    return EnergySnapshot(
      deviceId: deviceId,
      values: map,
      errorCode: dto.errorCode,
      errorDescription: dto.errorDescription,
    );
  }

  @override
  Future<EnergyConsumption> fetchConsumptionSummary({
    required String username,
    required String password,
    required String deviceId,
    required String periodType,
    required String type,
    required String totalCheckPt,
    required String term,
  }) async {
    final dto = await _remoteDataSource.fetchConsumptionSummary(
      username: username,
      password: password,
      deviceId: deviceId,
      periodType: periodType,
      type: type,
      totalCheckPt: totalCheckPt,
      term: term,
    );
    return _mapConsumptionDto(deviceId, dto);
  }

  @override
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
  }) async {
    final dto = await _remoteDataSource.fetchConsumptionHistory(
      username: username,
      password: password,
      deviceId: deviceId,
      periodType: periodType,
      type: type,
      totalCheckPt: totalCheckPt,
      term: term,
      startDate: startDate,
      endDate: endDate,
    );

    return _mapHistoryDto(deviceId, dto);
  }

  @override
  Future<EnergyCategoryBreakdown> fetchCategoryBreakdown({
    required String username,
    required String password,
    required String organizationId,
    required String periodType,
    required String term,
  }) async {
    final EnergyCategoryDto dto =
        await _remoteDataSource.fetchCategoricalConsumptions(
      username: username,
      password: password,
      organizationId: organizationId,
      periodType: periodType,
      term: term,
    );

    return EnergyCategoryBreakdown(
      categories: dto.categories,
      errorCode: dto.errorCode,
      errorDescription: dto.errorDescription,
    );
  }

  EnergyConsumption _mapConsumptionDto(
    String deviceId,
    EnergyConsumptionDto dto,
  ) {
    final entries = dto.items
        .map(
          (item) => EnergyConsumptionEntry(
            deviceDescription: item['fld_DeviceDescription']?.toString() ?? '#',
            consumptionValue: item['fld_ConsumptionValue']?.toString() ?? '#',
            consumptionAmount: item['fld_ConsumptionAmount']?.toString() ?? '#',
          ),
        )
        .toList();

    final firstEntry = entries.isNotEmpty ? entries.first : null;
    return EnergyConsumption(
      deviceId: deviceId,
      consumptionValue: firstEntry?.consumptionValue ?? '#',
      consumptionAmount: firstEntry?.consumptionAmount ?? '#',
      deviceDescription: firstEntry?.deviceDescription ?? '#',
      errorCode: dto.errorCode,
      errorDescription: dto.errorDescription,
      entries: entries,
    );
  }

  EnergyConsumptionHistory _mapHistoryDto(
    String deviceId,
    EnergyConsumptionDto dto,
  ) {
    final records = <EnergyConsumptionRecord>[];

    for (final item in dto.items) {
      final record = _mapRecord(item);
      if (record != null) {
        records.add(record);
      }
    }

    return EnergyConsumptionHistory(
      deviceId: deviceId,
      records: records,
      errorCode: dto.errorCode,
      errorDescription: dto.errorDescription,
    );
  }

  EnergyConsumptionRecord? _mapRecord(Map<String, dynamic> raw) {
    final dateRaw = raw['fld_DateTime']?.toString();
    if (dateRaw == null || dateRaw.isEmpty) {
      return null;
    }

    final timestamp = _parseTimestamp(dateRaw);
    if (timestamp == null) {
      return null;
    }

    final valueLabel = raw['fld_ConsumptionValue']?.toString() ?? '#';
    final amountLabel = raw['fld_ConsumptionAmount']?.toString() ?? '#';

    return EnergyConsumptionRecord(
      timestamp: timestamp,
      valueLabel: valueLabel,
      amountLabel: amountLabel,
      value: EnergyValueParser.parse(valueLabel),
      amount: EnergyValueParser.parse(amountLabel),
    );
  }

  DateTime? _parseTimestamp(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(trimmed);
    } catch (_) {
      if (RegExp(r'^\\d{4}$').hasMatch(trimmed)) {
        final year = int.tryParse(trimmed);
        if (year != null) {
          return DateTime(year);
        }
      }
    }
    return null;
  }
}
