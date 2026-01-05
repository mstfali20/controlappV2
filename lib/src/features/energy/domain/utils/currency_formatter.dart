import 'package:intl/intl.dart';

import 'energy_value_parser.dart';

class CurrencyFormatter {
  const CurrencyFormatter._();

  static final NumberFormat _smallValueFormatter =
      NumberFormat.currency(locale: 'tr_TR', symbol: '', decimalDigits: 2);
  static final NumberFormat _groupedValueFormatter =
      (NumberFormat.decimalPattern('tr_TR')
        ..minimumFractionDigits = 0
        ..maximumFractionDigits = 2);
  static final NumberFormat _compactValueFormatter =
      NumberFormat.compactCurrency(
    locale: 'tr_TR',
    symbol: '',
    decimalDigits: 1,
  );

  static String format(
    double value, {
    bool includeSymbol = true,
    bool allowCompact = true,
  }) {
    if (!value.isFinite) {
      return includeSymbol ? '0 ₺' : '0';
    }

    final absValue = value.abs();
    String formatted;
    if (allowCompact && absValue >= 1000000) {
      formatted = _compactValueFormatter.format(value);
    } else if (absValue >= 1000) {
      formatted = _groupedValueFormatter.format(value);
    } else {
      formatted = _smallValueFormatter.format(value);
    }

    final normalized = formatted.replaceAll(' ', ' ').trim();
    return includeSymbol ? '$normalized ₺' : normalized;
  }

  static String formatLabel(
    String? label, {
    bool includeSymbol = true,
    bool allowCompact = false,
  }) {
    if (label == null) {
      return includeSymbol ? '0 ₺' : '0';
    }

    final trimmed = label.trim();
    if (trimmed.isEmpty) {
      return includeSymbol ? '0 ₺' : '0';
    }

    if (!_hasDigit(trimmed)) {
      return trimmed;
    }

    final parsedValue = EnergyValueParser.parse(trimmed);
    if (parsedValue == 0 && _hasNonZeroDigit(trimmed)) {
      return trimmed;
    }

    return format(
      parsedValue,
      includeSymbol: includeSymbol,
      allowCompact: allowCompact,
    );
  }

  static bool _hasDigit(String input) {
    return RegExp(r'\d').hasMatch(input);
  }

  static bool _hasNonZeroDigit(String input) {
    return RegExp(r'[1-9]').hasMatch(input);
  }
}
