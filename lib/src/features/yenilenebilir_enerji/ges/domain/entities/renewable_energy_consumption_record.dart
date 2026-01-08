import 'package:equatable/equatable.dart';

class RenewableEnergyConsumptionRecord extends Equatable {
  const RenewableEnergyConsumptionRecord({
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
  List<Object?> get props => [timestamp, valueLabel, amountLabel, value, amount];
}
