import 'package:intl/intl.dart';

class EnergyValueParser {
  const EnergyValueParser._();

  static double parse(String? value) {
    if (value == null || value.isEmpty) {
      return 0;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 0;
    }

    final suffixPattern =
        RegExp(r'([-+]?[0-9]+(?:[.,][0-9]+)?)\s*([kKmMbB])(?=\s|\Z)');
    final suffixMatch = suffixPattern.firstMatch(trimmed);
    if (suffixMatch != null) {
      final numberPart = suffixMatch.group(1)!;
      final multiplier = _multiplierForSymbol(suffixMatch.group(2)!);
      final numeric = _parseNumeric(numberPart);
      return numeric != null ? numeric * multiplier : 0;
    }

    final sanitized = trimmed.replaceAll(RegExp(r'[^0-9,.+\-]'), '');
    if (sanitized.isNotEmpty) {
      final localeParsed = _tryParseWithLocales(sanitized);
      if (localeParsed != null) {
        return localeParsed;
      }
    }

    final numberMatch =
        RegExp(r'[-+]?[0-9]+(?:[.,][0-9]+)?').allMatches(trimmed);
    if (numberMatch.isEmpty) {
      return 0;
    }

    if (numberMatch.length > 1) {
      final parts = numberMatch.map((match) => match.group(0)!).toList();
      final combined = _combineGroupedParts(parts);
      if (combined != null) {
        final numeric = _parseNumeric(combined);
        if (numeric != null) {
          return numeric;
        }
      }
    }

    final numberPart = numberMatch.last.group(0)!;
    final numeric = _parseNumeric(numberPart);
    return numeric ?? 0;
  }

  static double _multiplierForSymbol(String symbol) {
    switch (symbol.toLowerCase()) {
      case 'k':
        return 1e3;
      case 'm':
        return 1e6;
      case 'b':
        return 1e9;
      default:
        return 1;
    }
  }

  static double? _tryParseWithLocales(String input) {
    final candidates = _localeCandidatesFor(input);
    for (final locale in candidates) {
      try {
        final value = NumberFormat.decimalPattern(locale).parse(input);
        return value.toDouble();
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  static List<String> _localeCandidatesFor(String input) {
    final lastDot = input.lastIndexOf('.');
    final lastComma = input.lastIndexOf(',');

    if (lastDot != -1 && lastComma != -1) {
      if (lastComma > lastDot) {
        return const ['tr_TR', 'de_DE', 'en_US', 'en_GB'];
      }
      return const ['en_US', 'en_GB', 'tr_TR', 'de_DE'];
    }

    if (lastComma != -1) {
      final digitsAfterComma = input.length - lastComma - 1;
      if (digitsAfterComma == 3) {
        return const ['en_US', 'en_GB', 'tr_TR', 'de_DE'];
      }
      return const ['tr_TR', 'de_DE', 'en_US', 'en_GB'];
    }

    return const ['en_US', 'en_GB', 'tr_TR', 'de_DE'];
  }

  static String? _combineGroupedParts(List<String> parts) {
    if (parts.isEmpty) {
      return null;
    }

    final hasDecimalPart = parts.length >= 2 && parts.last.length <= 2;
    final integerParts =
        hasDecimalPart ? parts.sublist(0, parts.length - 1) : parts;
    if (integerParts.isEmpty) {
      return null;
    }

    final concatenatedIntegers = integerParts.join();
    if (concatenatedIntegers.isEmpty) {
      return null;
    }

    if (!hasDecimalPart) {
      return concatenatedIntegers;
    }

    final decimalPart = parts.last;
    return '$concatenatedIntegers.$decimalPart';
  }

  static double? _parseNumeric(String input) {
    var value = input.trim();
    if (value.isEmpty) {
      return 0;
    }

    final lastDot = value.lastIndexOf('.');
    final lastComma = value.lastIndexOf(',');

    if (lastDot != -1 && lastComma != -1) {
      if (lastDot > lastComma) {
        value = value.replaceAll(',', '');
      } else {
        value = value.replaceAll('.', '').replaceFirst(',', '.');
      }
    } else if (lastComma != -1) {
      value = value.replaceAll('.', '');
      value = value.replaceAll(',', '.');
    } else if (value.indexOf('.') != value.lastIndexOf('.')) {
      final last = value.lastIndexOf('.');
      final integer = value.substring(0, last).replaceAll('.', '');
      final decimal = value.substring(last + 1);
      value = '$integer.$decimal';
    }

    return double.tryParse(value);
  }
}
