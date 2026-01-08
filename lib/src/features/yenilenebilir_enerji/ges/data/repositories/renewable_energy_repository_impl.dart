import 'dart:developer';

import 'package:controlapp/src/features/yenilenebilir_enerji/ges/data/models/renewable_energy_consumption_dto.dart';

import '../../domain/entities/renewable_energy_consumption_history.dart';
import '../../domain/entities/renewable_energy_consumption_record.dart';
import '../../domain/repositories/renewable_energy_repository.dart';
import '../datasources/renewable_energy_remote_data_source.dart';

class RenewableEnergyRepositoryImpl implements RenewableEnergyRepository {
  RenewableEnergyRepositoryImpl(this._remoteDataSource);

  final RenewableEnergyRemoteDataSource _remoteDataSource;

  @override
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

  RenewableEnergyConsumptionHistory _mapHistoryDto(
    String deviceId,
    RenewableEnergyConsumptionDto dto,
  ) {
    final records = <RenewableEnergyConsumptionRecord>[];
    for (final item in dto.items) {
      final record = _mapRecord(item);
      if (record != null) {
        records.add(record);
      }
    }
    return RenewableEnergyConsumptionHistory(
      deviceId: deviceId,
      records: records,
      errorCode: dto.errorCode,
      errorDescription: dto.errorDescription,
    );
  }

  RenewableEnergyConsumptionRecord? _mapRecord(Map<String, dynamic> raw) {
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
    return RenewableEnergyConsumptionRecord(
      timestamp: timestamp,
      valueLabel: valueLabel,
      amountLabel: amountLabel,
      value: double.tryParse(valueLabel.replaceAll(',', '.')) ?? 0,
      amount: double.tryParse(amountLabel.replaceAll(',', '.')) ?? 0,
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
      if (RegExp(r'^\d{4}$').hasMatch(trimmed)) {
        final year = int.tryParse(trimmed);
        if (year != null) {
          return DateTime(year);
        }
      }
    }
    return null;
  }
}
