import '../entities/alarm_notification.dart';
import '../repositories/notifications_repository.dart';

class FetchNotificationsParams {
  const FetchNotificationsParams({
    required this.username,
    required this.password,
    this.deviceModelTypeId,
  });

  final String username;
  final String password;
  final String? deviceModelTypeId;
}

class FetchNotificationsUseCase {
  FetchNotificationsUseCase(this._repository);

  final NotificationsRepository _repository;

  Future<List<AlarmNotification>> call(FetchNotificationsParams params) {
    return _repository.fetchAlarms(
      username: params.username,
      password: params.password,
      deviceModelTypeId: params.deviceModelTypeId,
    );
  }
}
