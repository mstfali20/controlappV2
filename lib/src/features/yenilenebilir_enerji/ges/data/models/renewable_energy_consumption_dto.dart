class RenewableEnergyConsumptionDto {
  RenewableEnergyConsumptionDto({
    required this.errorCode,
    required this.errorDescription,
    required this.items,
  });

  factory RenewableEnergyConsumptionDto.fromJson(Map<String, dynamic> json) {
    final data = json['Data'];
    return RenewableEnergyConsumptionDto(
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
