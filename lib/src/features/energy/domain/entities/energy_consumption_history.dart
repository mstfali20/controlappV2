import 'package:equatable/equatable.dart';

import 'energy_consumption_record.dart';

class EnergyConsumptionHistory extends Equatable {
  const EnergyConsumptionHistory({
    required this.deviceId,
    required this.records,
    this.errorCode = 0,
    this.errorDescription,
  });

  final String deviceId;
  final List<EnergyConsumptionRecord> records;
  final int errorCode;
  final String? errorDescription;

  bool get isSuccess => errorCode == 0;

  @override
  List<Object?> get props => [deviceId, records, errorCode, errorDescription];
}
