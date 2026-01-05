class EnergyCategoryDto {
  EnergyCategoryDto({
    required this.errorCode,
    required this.errorDescription,
    required this.categories,
  });

  factory EnergyCategoryDto.fromJson(Map<String, dynamic> json) {
    final data = json['Data'];
    final categories = <String, double>{};

    if (data is Map) {
      data.forEach((key, value) {
        if (key == null) {
          return;
        }
        final keyString = key.toString();
        if (value is List && value.isNotEmpty) {
          final numeric = _parseDouble(value.first);
          if (numeric != null) {
            categories[keyString] = numeric;
          }
        } else if (value is num) {
          categories[keyString] = value.toDouble();
        } else if (value != null) {
          final numeric = _parseDouble(value);
          if (numeric != null) {
            categories[keyString] = numeric;
          }
        }
      });
    }

    return EnergyCategoryDto(
      errorCode: json['Error_Code'] as int? ?? -1,
      errorDescription: json['Error_Description']?.toString(),
      categories: categories,
    );
  }

  final int errorCode;
  final String? errorDescription;
  final Map<String, double> categories;

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    final raw = value.toString().trim();
    if (raw.isEmpty) {
      return null;
    }
    final sanitized = raw.replaceAll(RegExp(r'[^0-9,.-]'), '');
    if (sanitized.isEmpty) {
      return null;
    }

    if (sanitized.contains(',') && sanitized.contains('.')) {
      if (sanitized.lastIndexOf(',') > sanitized.lastIndexOf('.')) {
        final normalized = sanitized.replaceAll('.', '').replaceAll(',', '.');
        return double.tryParse(normalized);
      }
      return double.tryParse(sanitized.replaceAll(',', ''));
    }

    if (sanitized.contains(',')) {
      final normalized = sanitized.replaceAll(',', '.');
      return double.tryParse(normalized) ??
          double.tryParse(sanitized.replaceAll(',', ''));
    }

    return double.tryParse(sanitized);
  }
}
