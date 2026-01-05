class ConsumptionData {
  final int errorCode;
  final String errorDescription;
  final List<Consumption> data;

  ConsumptionData({
    required this.errorCode,
    required this.errorDescription,
    required this.data,
  });

  // JSON'dan model objesine çevirme fonksiyonu
  factory ConsumptionData.fromJson(Map<String, dynamic> json) {
    return ConsumptionData(
      errorCode: json['Error_Code'] ?? 0,
      errorDescription: json['Error_Description'] ?? '',
      data: (json['Data'] as List)
          .map((item) => Consumption.fromJson(item))
          .toList(),
    );
  }

  // Model objesini JSON'a çevirme fonksiyonu
  Map<String, dynamic> toJson() {
    return {
      'Error_Code': errorCode,
      'Error_Description': errorDescription,
      'Data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class Consumption {
  final String consumptionValue;
  final String consumptionAmount;
  final String deviceDescription;

  Consumption({
    required this.consumptionValue,
    required this.consumptionAmount,
    required this.deviceDescription,
  });

  // JSON'dan model objesine çevirme fonksiyonu
  factory Consumption.fromJson(Map<String, dynamic> json) {
    return Consumption(
      consumptionValue: json['fld_ConsumptionValue'] ?? '',
      consumptionAmount: json['fld_ConsumptionAmount'] ?? '',
      deviceDescription: json['fld_DeviceDescription'] ?? '',
    );
  }

  // Model objesini JSON'a çevirme fonksiyonu
  Map<String, dynamic> toJson() {
    return {
      'fld_ConsumptionValue': consumptionValue,
      'fld_ConsumptionAmount': consumptionAmount,
      'fld_DeviceDescription': deviceDescription,
    };
  }
}
