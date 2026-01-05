import 'package:equatable/equatable.dart';

import '../../domain/entities/session.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.error,
    this.session,
    this.redirectRoute,
  });

  final AuthStatus status;
  final String? error;
  final Session? session;
  final String? redirectRoute;

  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    String? error,
    Session? session,
    String? redirectRoute,
    bool clearError = false,
    bool clearRedirect = false,
    bool clearSession = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      session: clearSession ? null : (session ?? this.session),
      redirectRoute:
          clearRedirect ? null : (redirectRoute ?? this.redirectRoute),
    );
  }

  @override
  List<Object?> get props => [status, error, session, redirectRoute];
}
