class SensorDataModel {
  final Map<String, List<SensorData>> data;

  SensorDataModel({required this.data});

  factory SensorDataModel.fromJson(Map<String, dynamic> json) {
    return SensorDataModel(
      data: (json['Data'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>)
              .map((item) => SensorData.fromJson(item))
              .toList(),
        ),
      ),
    );
  }
}

class SensorData {
  final String labelCode;
  final String localization;
  final int hasFlagValue;
  final int dataLength;

  SensorData({
    required this.labelCode,
    required this.localization,
    required this.hasFlagValue,
    required this.dataLength,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      labelCode: json['LabelCode'] ?? '',
      localization: json['Localization'] ?? '',
      hasFlagValue: json['Has_flag_value'] ?? 0,
      dataLength: json['Data_length'] ?? 0,
    );
  }
}
