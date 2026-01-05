import '../../domain/entities/alarm_notification.dart';

class NotificationsResponseDto {
  const NotificationsResponseDto({
    required this.errorCode,
    required this.errorDescription,
    required this.alarms,
  });

  factory NotificationsResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['Data'] as List<dynamic>? ?? [];
    return NotificationsResponseDto(
      errorCode: _parseInt(json['Error_Code']),
      errorDescription: json['Error_Description']?.toString().trim() ?? '',
      alarms: data
          .map((item) => AlarmNotificationDto.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
    );
  }

  final int errorCode;
  final String errorDescription;
  final List<AlarmNotificationDto> alarms;
}

class AlarmNotificationDto {
  const AlarmNotificationDto({
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
    required this.creationDateText,
    required this.endDateText,
    required this.alarmDuration,
    required this.operator,
    required this.approvedDateText,
    required this.approvedBy,
  });

  factory AlarmNotificationDto.fromJson(Map<String, dynamic> json) {
    return AlarmNotificationDto(
      id: _parseInt(json['Alarm_Id']),
      deviceId: _parseInt(json['Device_Id']),
      deviceDescription: json['Device_Description']?.toString().trim() ?? '',
      deviceOrganization: json['Device_Organization']?.toString().trim() ?? '',
      deviceModelName: json['Device_Model_Name']?.toString().trim() ?? '',
      description: json['Alarm_Description']?.toString().trim() ?? '',
      labelCode: json['Label_Code']?.toString().trim() ?? '',
      confidenceLevel: _parseInt(json['Alarm_Conf_Level']),
      confidenceLabel:
          json['Alarm_Conf_Level_Localization']?.toString().trim() ?? '',
      labelIcon: json['Label_Icon']?.toString().trim() ?? '',
      isApproved: _parseInt(json['Approved']) == 1,
      status: _parseInt(json['Alarm_Status']),
      statusLabel: json['Alarm_Status_Localization']?.toString().trim() ?? '',
      alarmValue: json['Alarm_Value']?.toString().trim() ?? '',
      creationDateText: json['Creation_Date_Time']?.toString().trim() ?? '',
      endDateText: json['End_Date_Time']?.toString().trim() ?? '',
      alarmDuration: json['Alarm_Time']?.toString().trim() ?? '',
      operator: json['User_Who_Does_Operation']?.toString().trim() ?? '',
      approvedDateText: json['Approved_Date_Time']?.toString().trim() ?? '',
      approvedBy: json['User_Who_Approved']?.toString().trim() ?? '',
    );
  }

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
  final String creationDateText;
  final String endDateText;
  final String alarmDuration;
  final String operator;
  final String approvedDateText;
  final String approvedBy;

  AlarmNotification toEntity() {
    return AlarmNotification(
      id: id,
      deviceId: deviceId,
      deviceDescription: deviceDescription,
      deviceOrganization: deviceOrganization,
      deviceModelName: deviceModelName,
      description: description,
      labelCode: labelCode,
      confidenceLevel: confidenceLevel,
      confidenceLabel: confidenceLabel,
      labelIcon: labelIcon,
      isApproved: isApproved,
      status: status,
      statusLabel: statusLabel,
      alarmValue: alarmValue,
      creationDate: _parseDate(creationDateText),
      creationDateText: creationDateText,
      endDateText: endDateText,
      alarmDuration: alarmDuration,
      operator: operator,
      approvedDateText: approvedDateText,
      approvedBy: approvedBy,
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime _parseDate(String raw) {
  if (raw.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
  final normalized = raw.replaceFirst(' ', 'T');
  return DateTime.tryParse(normalized) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
