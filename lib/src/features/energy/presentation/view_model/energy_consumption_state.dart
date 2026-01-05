import 'package:equatable/equatable.dart';

import '../../domain/entities/energy_consumption.dart';

class EnergyConsumptionState extends Equatable {
  const EnergyConsumptionState({
    this.loading = false,
    this.error,
    this.data,
  });

  final bool loading;
  final String? error;
  final EnergyConsumption? data;

  EnergyConsumptionState copyWith({
    bool? loading,
    String? error,
    EnergyConsumption? data,
    bool clearError = false,
  }) {
    return EnergyConsumptionState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [loading, error, data];
}
