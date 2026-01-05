import 'package:controlapp/src/core/presentation/safe_cubit.dart';

import 'package:controlapp/const/data.dart' as legacy_data;
import 'package:controlapp/src/features/auth/data/services/organization_service.dart';

import '../../../../core/logging/logger.dart';
import '../../domain/entities/session.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/save_session_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends SafeCubit<AuthState> {
  AuthCubit({
    required LoginUseCase loginUseCase,
    required SaveSessionUseCase saveSessionUseCase,
    required AppLogger logger,
  })  : _loginUseCase = loginUseCase,
        _saveSessionUseCase = saveSessionUseCase,
        _logger = logger,
        super(const AuthState());

  final LoginUseCase _loginUseCase;
  final SaveSessionUseCase _saveSessionUseCase;
  final AppLogger _logger;

  Future<Session?> login({
    required String username,
    required String password,
    required bool rememberMe,
    String? deviceToken,
  }) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        clearError: true,
        clearRedirect: true,
      ),
    );

    try {
      final session = await _loginUseCase(
        LoginParams(
          username: username,
          password: password,
          deviceToken: deviceToken,
        ),
      );

      final updatedSession = session.copyWith(
        username: username,
        password: session.password,
        rememberMe: rememberMe,
      );

      _hydrateLegacyCache(updatedSession);

      await _saveSessionUseCase(
        SaveSessionParams(session: updatedSession),
      );

      emit(
        state.copyWith(
          status: AuthStatus.success,
          session: updatedSession,
        ),
      );
      return updatedSession;
    } catch (error, stackTrace) {
      _logger.error(
        'auth_login_failed',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          error: error.toString(),
          clearRedirect: true,
          clearSession: true,
        ),
      );
      return null;
    }
  }

  void clearError() {
    if (state.error != null) {
      emit(state.copyWith(clearError: true));
    }
  }

  void clearRedirect() {
    if (state.redirectRoute != null) {
      emit(state.copyWith(clearRedirect: true));
    }
  }

  Future<void> cacheSession(Session session) async {
    await _saveSessionUseCase(SaveSessionParams(session: session));
    emit(state.copyWith(session: session, status: state.status));
  }
}

void _hydrateLegacyCache(Session session) {
  legacy_data.userDataConst = {
    'username': session.user.username,
    'name': session.user.name,
    'lastname': session.user.lastname,
    'email': session.user.email,
    'image_url': session.user.imageUrl,
    'user_id': session.user.userId,
    'firm_name': session.user.firmName,
    'firm_id': session.user.firmId,
    'password': session.password ?? '',
    if (session.extras['selected_module'] != null)
      'selected_module': session.extras['selected_module'],
  }..removeWhere((_, value) => value == null);

  legacy_data.users = session.user.username;
  legacy_data.pass = session.password ?? '';
  if (session.extras['selected_module'] is String) {
    legacy_data.selectedModule = session.extras['selected_module'];
  }

  ensureOrganizationsLoaded();
}
