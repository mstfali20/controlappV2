class EnergyConsumptionDto {
  EnergyConsumptionDto({
    required this.errorCode,
    required this.errorDescription,
    required this.items,
  });

  factory EnergyConsumptionDto.fromJson(Map<String, dynamic> json) {
    final data = json['Data'];
    return EnergyConsumptionDto(
      errorCode: json['Error_Code'] as int? ?? -1,
      errorDescription: json['Error_Description']?.toString(),
      items: data is List
          ? data
              .whereType<Map<String, dynamic>>()
              .map(
                  (e) => e.map((key, value) => MapEntry(key.toString(), value)))
              .toList()
          : const <Map<String, dynamic>>[],
    );
  }

  final int errorCode;
  final String? errorDescription;
  final List<Map<String, dynamic>> items;
}
