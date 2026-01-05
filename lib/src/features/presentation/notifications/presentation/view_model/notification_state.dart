import 'package:equatable/equatable.dart';

import '../../domain/entities/alarm_notification.dart';

enum NotificationStatus { initial, loading, success, failure }

class NotificationState extends Equatable {
  const NotificationState({
    this.status = NotificationStatus.initial,
    this.alarms = const [],
    this.errorMessage,
  });

  final NotificationStatus status;
  final List<AlarmNotification> alarms;
  final String? errorMessage;

  bool get isLoading => status == NotificationStatus.loading;
  bool get isFailure => status == NotificationStatus.failure;
  bool get isSuccess => status == NotificationStatus.success;

  NotificationState copyWith({
    NotificationStatus? status,
    List<AlarmNotification>? alarms,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      status: status ?? this.status,
      alarms: alarms ?? this.alarms,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, alarms, errorMessage];
}
