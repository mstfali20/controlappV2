class ClimateSnapshotDto {
  ClimateSnapshotDto({
    required this.errorCode,
    required this.errorDescription,
    required this.items,
  });

  factory ClimateSnapshotDto.fromJson(Map<String, dynamic> json) {
    final data = json['Data'];
    return ClimateSnapshotDto(
      errorCode: json['Error_Code'] as int? ?? -1,
      errorDescription: json['Error_Description']?.toString(),
      items: data is List
          ? data.map((dynamic item) => item.toString()).toList()
          : const <String>[],
    );
  }

  final int errorCode;
  final String? errorDescription;
  final List<String> items;
}
