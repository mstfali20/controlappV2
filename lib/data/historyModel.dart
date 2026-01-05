class HistoryData {
  final String dateTime;
  final String minValue;
  final String maxValue;
  final String avgValue;

  HistoryData({
    required this.dateTime,
    required this.minValue,
    required this.maxValue,
    required this.avgValue,
  });

  factory HistoryData.fromJson(Map<String, dynamic> json) {
    return HistoryData(
      dateTime: json['Date_Time'],
      minValue: json['Min_Value'],
      maxValue: json['Max_Value'],
      avgValue: json['Avg_Value'], // Düzgün bir şekilde double olarak geliyor
    );
  }
}
