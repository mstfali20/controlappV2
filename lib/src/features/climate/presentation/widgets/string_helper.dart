class StringHelper {
  static String shortenValue(String value) {
    // Değeri kontrol et
    if (value.isEmpty) {
      return '##'; // Boşsa ## değerini döndür
    }

    // Değeri kısalt
    double parsedValue = double.tryParse(value) ??
        double.nan; // double.tryParse kullanarak hata durumunda null döner
    String shortenedValue = parsedValue.isNaN
        ? '##'
        : parsedValue.toStringAsFixed(1); // İki ondalık basamağa yuvarla
    return shortenedValue;
  }
}

class StringHelperiki {
  static String shortenValue(String value) {
    // Değeri kontrol et
    if (value.isEmpty) {
      return '##'; // Boşsa ## değerini döndür
    }

    // Değeri kısalt
    double parsedValue = double.tryParse(value) ??
        double.nan; // double.tryParse kullanarak hata durumunda null döner
    String shortenedValue = parsedValue.isNaN
        ? '##'
        : parsedValue.toStringAsFixed(2); // İki ondalık basamağa yuvarla
    return shortenedValue;
  }
}

class StringHelperVirgulsuz {
  static String shortenValue(String value) {
    // Değeri kontrol et
    if (value.isEmpty) {
      return '##'; // Boşsa ## değerini döndür
    }

    // Değeri kısalt
    double parsedValue = double.tryParse(value) ?? double.nan;
    String shortenedValue = parsedValue.isNaN
        ? '##'
        : parsedValue
            .toInt()
            .toString(); // Virgülden sonraki değeri yazmadan tam sayıya dönüştür
    return shortenedValue;
  }
}
