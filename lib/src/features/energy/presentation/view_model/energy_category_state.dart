import 'package:equatable/equatable.dart';

import '../../domain/entities/energy_category_breakdown.dart';

class EnergyCategoryState extends Equatable {
  const EnergyCategoryState({
    this.loading = false,
    this.error,
    this.breakdown,
  });

  final bool loading;
  final String? error;
  final EnergyCategoryBreakdown? breakdown;

  EnergyCategoryState copyWith({
    bool? loading,
    String? error,
    EnergyCategoryBreakdown? breakdown,
    bool clearError = false,
  }) {
    return EnergyCategoryState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      breakdown: breakdown ?? this.breakdown,
    );
  }

  @override
  List<Object?> get props => [loading, error, breakdown];
}
