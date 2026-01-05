import 'package:equatable/equatable.dart';

import '../../domain/entities/session.dart';

enum SplashStatus { initial, loading, ready, failure }

class SplashState extends Equatable {
  const SplashState({
    this.status = SplashStatus.initial,
    this.error,
    this.targetRoute,
    this.session,
  });

  final SplashStatus status;
  final String? error;
  final String? targetRoute;
  final Session? session;

  bool get isLoading => status == SplashStatus.loading;

  SplashState copyWith({
    SplashStatus? status,
    String? error,
    String? targetRoute,
    Session? session,
    bool clearError = false,
    bool clearRoute = false,
    bool clearSession = false,
  }) {
    return SplashState(
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      targetRoute: clearRoute ? null : (targetRoute ?? this.targetRoute),
      session: clearSession ? null : (session ?? this.session),
    );
  }

  @override
  List<Object?> get props => [status, error, targetRoute, session];
}
