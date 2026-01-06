import 'package:equatable/equatable.dart';

import '../../domain/entities/energy_consumption_history.dart';

class EnergyHistoryState extends Equatable {
  const EnergyHistoryState({
    this.loading = false,
    this.error,
    this.history,
  });

  final bool loading;
  final String? error;
  final EnergyConsumptionHistory? history;

  EnergyHistoryState copyWith({
    bool? loading,
    String? error,
    EnergyConsumptionHistory? history,
    bool clearError = false,
  }) {
    return EnergyHistoryState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [loading, error, history];
}
