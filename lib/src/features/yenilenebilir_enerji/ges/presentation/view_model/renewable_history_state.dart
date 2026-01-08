import 'package:equatable/equatable.dart';

import '../../domain/entities/renewable_energy_consumption_history.dart';

class RenewableHistoryState extends Equatable {
  const RenewableHistoryState({
    this.loading = false,
    this.error,
    this.history,
  });

  final bool loading;
  final String? error;
  final RenewableEnergyConsumptionHistory? history;

  RenewableHistoryState copyWith({
    bool? loading,
    String? error,
    RenewableEnergyConsumptionHistory? history,
    bool clearError = false,
  }) {
    return RenewableHistoryState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [loading, error, history];
}
