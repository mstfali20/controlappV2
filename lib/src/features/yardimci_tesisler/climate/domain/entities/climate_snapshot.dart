class ClimateSnapshot {
  const ClimateSnapshot({
    required this.deviceId,
    required this.values,
    required this.errorCode,
    required this.errorDescription,
  });

  final String deviceId;
  final Map<String, String> values;
  final int errorCode;
  final String? errorDescription;

  bool get isSuccess => errorCode == 0;
}
