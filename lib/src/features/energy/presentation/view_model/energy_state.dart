import 'package:equatable/equatable.dart';

import '../../domain/entities/energy_snapshot.dart';

class EnergyState extends Equatable {
  const EnergyState({
    this.loading = false,
    this.error,
    this.snapshot,
  });

  final bool loading;
  final String? error;
  final EnergySnapshot? snapshot;

  EnergyState copyWith({
    bool? loading,
    String? error,
    EnergySnapshot? snapshot,
    bool clearError = false,
  }) {
    return EnergyState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      snapshot: snapshot ?? this.snapshot,
    );
  }

  @override
  List<Object?> get props => [loading, error, snapshot];
}
