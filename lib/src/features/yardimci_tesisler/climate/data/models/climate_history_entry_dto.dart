class ClimateHistoryEntryDto {
  ClimateHistoryEntryDto({
    required this.dateTime,
    required this.minValue,
    required this.maxValue,
    required this.avgValue,
  });

  factory ClimateHistoryEntryDto.fromJson(Map<String, dynamic> json) {
    return ClimateHistoryEntryDto(
      dateTime: json['Date_Time']?.toString() ?? '',
      minValue: json['Min_Value']?.toString() ?? '0',
      maxValue: json['Max_Value']?.toString() ?? '0',
      avgValue: json['Avg_Value']?.toString() ?? '0',
    );
  }

  final String dateTime;
  final String minValue;
  final String maxValue;
  final String avgValue;
}
