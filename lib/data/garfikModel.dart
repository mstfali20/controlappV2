class HistoryGrafikData {
  final String
      dateTime; // Tüm tarih formatlarını String'e dönüştürerek tutacağız.
  final String consumptionValue;
  final String consumptionAmount;

  HistoryGrafikData({
    required this.dateTime,
    required this.consumptionValue,
    required this.consumptionAmount,
  });

  // JSON'dan nesne oluşturma
  factory HistoryGrafikData.fromJson(Map<String, dynamic> json) {
    // fld_DateTime formatını kontrol edip uygun şekilde işleme
    String formattedDateTime;
    if (json['fld_DateTime'] is int) {
      // Yıl formatındaysa tam tarih formatına çevir
      formattedDateTime = '${json['fld_DateTime']}-01-01 00:00:00';
    } else {
      // Zaten String ise doğrudan kullan
      formattedDateTime = json['fld_DateTime'] ?? '';
    }

    return HistoryGrafikData(
      dateTime: formattedDateTime,
      consumptionValue: json['fld_ConsumptionValue'] ?? '',
      consumptionAmount: json['fld_ConsumptionAmount'] ?? '',
    );
  }

  // Nesneyi JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'fld_DateTime': dateTime,
      'fld_ConsumptionValue': consumptionValue,
      'fld_ConsumptionAmount': consumptionAmount,
    };
  }
}
