import 'dart:developer';

import '../../../../../core/presentation/safe_cubit.dart';
import '../../../../auth/domain/usecases/get_session_usecase.dart';
import '../../domain/usecases/fetch_notifications_usecase.dart';
import 'notification_state.dart';

class NotificationCubit extends SafeCubit<NotificationState> {
  NotificationCubit({
    required FetchNotificationsUseCase fetchNotificationsUseCase,
    required GetSessionUseCase getSessionUseCase,
  })  : _fetchNotificationsUseCase = fetchNotificationsUseCase,
        _getSessionUseCase = getSessionUseCase,
        super(const NotificationState());

  final FetchNotificationsUseCase _fetchNotificationsUseCase;
  final GetSessionUseCase _getSessionUseCase;

  Future<void> load({String? deviceModelTypeId, bool force = false}) async {
    if (state.isLoading && !force) {
      return;
    }

    emit(state.copyWith(status: NotificationStatus.loading, clearError: true));

    try {
      final session = await _getSessionUseCase();
      if (session == null) {
        emit(
          state.copyWith(
            status: NotificationStatus.failure,
            errorMessage: 'Oturum bulunamadı. Lütfen yeniden giriş yapın.',
          ),
        );
        return;
      }

      final password = session.password;
      if (password == null || password.isEmpty) {
        emit(
          state.copyWith(
            status: NotificationStatus.failure,
            errorMessage:
                'Kullanıcı bilgileri eksik. Lütfen yeniden giriş yapın.',
          ),
        );
        return;
      }

      final alarms = await _fetchNotificationsUseCase(
        FetchNotificationsParams(
          username: session.username,
          password: password,
          deviceModelTypeId: deviceModelTypeId,
        ),
      );
      emit(
        state.copyWith(
          status: NotificationStatus.success,
          alarms: alarms,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      log('notification_fetch_failed', error: error, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: NotificationStatus.failure,
          errorMessage:
              'Veriler alınırken bir sorun oluştu. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  Future<void> refresh({String? deviceModelTypeId}) {
    return load(deviceModelTypeId: deviceModelTypeId, force: true);
  }
}
