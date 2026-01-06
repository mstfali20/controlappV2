class ClimateHistoryEntry {
  const ClimateHistoryEntry({
    required this.dateTime,
    required this.minValue,
    required this.maxValue,
    required this.avgValue,
  });

  final String dateTime;
  final String minValue;
  final String maxValue;
  final String avgValue;
}
