import 'package:equatable/equatable.dart';

class EnergyConsumption extends Equatable {
  const EnergyConsumption({
    required this.deviceId,
    required this.consumptionValue,
    required this.consumptionAmount,
    required this.deviceDescription,
    this.errorCode = 0,
    this.errorDescription,
    this.entries = const <EnergyConsumptionEntry>[],
  });

  final String deviceId;
  final String consumptionValue;
  final String consumptionAmount;
  final String deviceDescription;
  final int errorCode;
  final String? errorDescription;
  final List<EnergyConsumptionEntry> entries;

  bool get isSuccess => errorCode == 0;

  @override
  List<Object?> get props => [
        deviceId,
        consumptionValue,
        consumptionAmount,
        deviceDescription,
        errorCode,
        errorDescription,
        entries,
      ];
}

class EnergyConsumptionEntry extends Equatable {
  const EnergyConsumptionEntry({
    required this.deviceDescription,
    required this.consumptionValue,
    required this.consumptionAmount,
  });

  final String deviceDescription;
  final String consumptionValue;
  final String consumptionAmount;

  @override
  List<Object?> get props => [
        deviceDescription,
        consumptionValue,
        consumptionAmount,
      ];
}
