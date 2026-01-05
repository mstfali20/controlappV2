import '../entities/alarm_notification.dart';

abstract class NotificationsRepository {
  Future<List<AlarmNotification>> fetchAlarms({
    required String username,
    required String password,
    String? deviceModelTypeId,
  });
}
