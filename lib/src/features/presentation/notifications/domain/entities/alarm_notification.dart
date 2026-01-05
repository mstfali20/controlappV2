import 'package:equatable/equatable.dart';

class AlarmNotification extends Equatable {
  const AlarmNotification({
    required this.id,
    required this.deviceId,
    required this.deviceDescription,
    required this.deviceOrganization,
    required this.deviceModelName,
    required this.description,
    required this.labelCode,
    required this.confidenceLevel,
    required this.confidenceLabel,
    required this.labelIcon,
    required this.isApproved,
    required this.status,
    required this.statusLabel,
    required this.alarmValue,
    required this.creationDate,
    required this.creationDateText,
    required this.endDateText,
    required this.alarmDuration,
    required this.operator,
    required this.approvedDateText,
    required this.approvedBy,
  });

  final int id;
  final int deviceId;
  final String deviceDescription;
  final String deviceOrganization;
  final String deviceModelName;
  final String description;
  final String labelCode;
  final int confidenceLevel;
  final String confidenceLabel;
  final String labelIcon;
  final bool isApproved;
  final int status;
  final String statusLabel;
  final String alarmValue;
  final DateTime creationDate;
  final String creationDateText;
  final String endDateText;
  final String alarmDuration;
  final String operator;
  final String approvedDateText;
  final String approvedBy;

  bool get isClosed => status == 2;
  bool get isFinished => status == 1;
  bool get isActive => status == 0;

  @override
  List<Object?> get props => [
        id,
        deviceId,
        deviceDescription,
        deviceOrganization,
        deviceModelName,
        description,
        labelCode,
        confidenceLevel,
        confidenceLabel,
        labelIcon,
        isApproved,
        status,
        statusLabel,
        alarmValue,
        creationDate,
        creationDateText,
        endDateText,
        alarmDuration,
        operator,
        approvedDateText,
        approvedBy,
      ];
}
