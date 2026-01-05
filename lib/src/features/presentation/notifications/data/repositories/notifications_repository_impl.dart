import '../../domain/entities/alarm_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._remoteDataSource);

  final NotificationsRemoteDataSource _remoteDataSource;

  @override
  Future<List<AlarmNotification>> fetchAlarms({
    required String username,
    required String password,
    String? deviceModelTypeId,
  }) async {
    final response = await _remoteDataSource.fetchAlarms(
      username: username,
      password: password,
      deviceModelTypeId: deviceModelTypeId,
    );

    if (response.errorCode != 0) {
      throw NotificationsException(
        response.errorDescription.isNotEmpty
            ? response.errorDescription
            : 'Beklenmeyen bir hata oluştu.',
      );
    }

    return response.alarms.map((dto) => dto.toEntity()).toList()
      ..sort((a, b) => b.creationDate.compareTo(a.creationDate));
  }
}
