import 'package:controlapp/const/data.dart' as legacy_data;
import 'package:controlapp/src/features/auth/data/services/organization_service.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:controlapp/src/core/presentation/safe_cubit.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/logging/logger.dart';
import '../../domain/entities/session.dart';
import '../../domain/usecases/clear_session_usecase.dart';
import '../../domain/usecases/get_session_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/save_session_usecase.dart';
import 'splash_state.dart';

class SplashCubit extends SafeCubit<SplashState> {
  SplashCubit({
    required GetSessionUseCase getSessionUseCase,
    required LoginUseCase loginUseCase,
    required SaveSessionUseCase saveSessionUseCase,
    required ClearSessionUseCase clearSessionUseCase,
    required AppLogger logger,
    required FirebaseRemoteConfig remoteConfig,
  })  : _getSessionUseCase = getSessionUseCase,
        _loginUseCase = loginUseCase,
        _saveSessionUseCase = saveSessionUseCase,
        _clearSessionUseCase = clearSessionUseCase,
        _logger = logger,
        _remoteConfig = remoteConfig,
        super(const SplashState());

  final GetSessionUseCase _getSessionUseCase;
  final LoginUseCase _loginUseCase;
  final SaveSessionUseCase _saveSessionUseCase;
  final ClearSessionUseCase _clearSessionUseCase;
  final AppLogger _logger;
  final FirebaseRemoteConfig _remoteConfig;

  Future<void> initialize({String? deviceToken}) async {
    emit(
      state.copyWith(
        status: SplashStatus.loading,
        clearError: true,
        clearRoute: true,
      ),
    );

    final remoteDecision = await _evaluateRemoteConfig();
    if (remoteDecision == _RemoteDecision.maintenance) {
      emit(
        state.copyWith(
          status: SplashStatus.ready,
          targetRoute: '/under',
          clearError: true,
          clearSession: true,
        ),
      );
      return;
    }

    if (remoteDecision == _RemoteDecision.updateRequired) {
      emit(
        state.copyWith(
          status: SplashStatus.ready,
          targetRoute: '/under',
          clearError: true,
          clearSession: true,
        ),
      );
      return;
    }

    final storedSession = await _getSessionUseCase();
    if (storedSession == null) {
      emit(
        state.copyWith(
          status: SplashStatus.ready,
          targetRoute: '/onboarding',
          clearError: true,
          clearSession: true,
        ),
      );
      return;
    }

    _hydrateLegacy(storedSession);

    final storedPassword = storedSession.password;
    final hasStoredPassword = storedPassword?.isNotEmpty ?? false;

    if (!hasStoredPassword) {
      final targetRoute = storedSession.hasValidToken ? '/home' : '/login';
      emit(
        state.copyWith(
          status: SplashStatus.ready,
          session: storedSession,
          targetRoute: targetRoute,
          clearError: true,
        ),
      );
      return;
    }

    try {
      final refreshed = await _loginUseCase(
        LoginParams(
          username: storedSession.username,
          password: storedPassword!,
          deviceToken: deviceToken,
        ),
      );

      final mergedSession = _mergeSessions(storedSession, refreshed);
      _hydrateLegacy(mergedSession);
      await _saveSessionUseCase(
        SaveSessionParams(session: mergedSession),
      );
      emit(
        state.copyWith(
          status: SplashStatus.ready,
          session: mergedSession,
          targetRoute: '/home',
        ),
      );
    } catch (error, stackTrace) {
      _logger.error(
        'splash_silent_login_failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (storedSession.hasValidToken) {
        emit(
          state.copyWith(
            status: SplashStatus.ready,
            session: storedSession,
            targetRoute: '/home',
            clearError: true,
          ),
        );
        return;
      }

      await _clearSessionUseCase();
      emit(
        state.copyWith(
          status: SplashStatus.failure,
          error: error.toString(),
          targetRoute: '/login',
          clearSession: true,
        ),
      );
    }
  }

  void clearError() {
    if (state.error != null) {
      emit(state.copyWith(clearError: true));
    }
  }

  void clearRoute() {
    if (state.targetRoute != null) {
      emit(state.copyWith(clearRoute: true));
    }
  }

  Session _mergeSessions(Session original, Session refreshed) {
    return refreshed.copyWith(
      rememberMe: original.rememberMe,
      serial: original.serial,
      serialTitle: original.serialTitle,
      plcTitle: original.plcTitle,
      selectedOrganizationId: original.selectedOrganizationId,
      token: refreshed.token ?? original.token,
      tokenIssuedAt: refreshed.tokenIssuedAt ?? original.tokenIssuedAt,
      tokenExpiresAt: refreshed.tokenExpiresAt ?? original.tokenExpiresAt,
      treeJson: original.treeJson ?? refreshed.treeJson,
    );
  }

  void _hydrateLegacy(Session session) {
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
    }..removeWhere((_, value) => value == null);

    legacy_data.users = session.user.username;
    legacy_data.pass = session.password ?? '';

    if (session.serial != null) {
      legacy_data.serial = session.serial!;
    }
    if (session.serialTitle != null) {
      legacy_data.serialTitle = session.serialTitle!;
    }
    if (session.plcTitle != null) {
      legacy_data.plcTitle = session.plcTitle!;
    }
    if (session.selectedOrganizationId != null) {
      legacy_data.organizationid = session.selectedOrganizationId!;
    }
    if (session.treeJson != null) {
      legacy_data.treeJson = session.treeJson!;
    }
    if (session.extras['selected_module'] is String) {
      legacy_data.selectedModule = session.extras['selected_module'];
    }

    ensureOrganizationsLoaded();
  }

  Future<_RemoteDecision> _evaluateRemoteConfig() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: Duration.zero,
        ),
      );
      await _remoteConfig.fetchAndActivate();
    } catch (error, stackTrace) {
      _logger.error(
        'remote_config_fetch_failed',
        error: error,
        stackTrace: stackTrace,
      );
      return _RemoteDecision.continueFlow;
    }

    final versionControl = _remoteConfig.getBool('version_control');
    final underMaintenance = _remoteConfig.getBool('under_maintenance');

    if (!versionControl) {
      return _RemoteDecision.continueFlow;
    }

    if (underMaintenance) {
      return _RemoteDecision.maintenance;
    }

    final remoteVersion = _remoteConfig.getString('app_version');
    if (remoteVersion.isEmpty) {
      return _RemoteDecision.continueFlow;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final shouldUpdate = _shouldUpdateApp(
        currentVersion: packageInfo.version,
        remoteVersion: remoteVersion,
      );
      return shouldUpdate
          ? _RemoteDecision.updateRequired
          : _RemoteDecision.continueFlow;
    } catch (error, stackTrace) {
      _logger.error(
        'package_info_fetch_failed',
        error: error,
        stackTrace: stackTrace,
      );
      return _RemoteDecision.continueFlow;
    }
  }

  bool _shouldUpdateApp(
      {required String currentVersion, required String remoteVersion}) {
    try {
      final currentParts = currentVersion.split('.').map(int.parse).toList();
      final remoteParts = remoteVersion.split('.').map(int.parse).toList();
      for (var index = 0; index < 3; index++) {
        final currentPart =
            index < currentParts.length ? currentParts[index] : 0;
        final remotePart = index < remoteParts.length ? remoteParts[index] : 0;
        if (remotePart > currentPart) {
          return true;
        }
        if (remotePart < currentPart) {
          return false;
        }
      }
      return false;
    } catch (error, stackTrace) {
      _logger.error(
        'version_compare_failed',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}

enum _RemoteDecision { continueFlow, maintenance, updateRequired }
