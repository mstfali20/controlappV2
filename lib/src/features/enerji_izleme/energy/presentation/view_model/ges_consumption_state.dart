import 'package:equatable/equatable.dart';

class GesConsumptionState extends Equatable {
  const GesConsumptionState({
    this.loading = false,
    this.error,
    this.data = const <String, double>{},
  });

  final bool loading;
  final String? error;
  final Map<String, double> data;

  GesConsumptionState copyWith({
    bool? loading,
    String? error,
    Map<String, double>? data,
    bool clearError = false,
  }) {
    return GesConsumptionState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [loading, error, data];
}
