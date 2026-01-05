import 'package:equatable/equatable.dart';

class EnergyConsumptionRecord extends Equatable {
  const EnergyConsumptionRecord({
    required this.timestamp,
    required this.valueLabel,
    required this.amountLabel,
    required this.value,
    required this.amount,
  });

  final DateTime timestamp;
  final String valueLabel;
  final String amountLabel;
  final double value;
  final double amount;

  @override
  List<Object?> get props =>
      [timestamp, valueLabel, amountLabel, value, amount];
}
