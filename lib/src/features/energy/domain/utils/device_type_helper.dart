class Stringdeger {
  static String getDeviceTypeUnit(int deviceType) {
    // Elektrik ölçüm cihazları
    if ([1, 2, 3, 11, 41].contains(deviceType)) {
      return "kw";
    }
    // Doğalgaz/Buhar ölçüm cihazları
    else if ([12, 22, 42].contains(deviceType)) {
      return "m³";
    } else if ([14].contains(deviceType)) {
      return "ton";
    }
    // Su ölçüm cihazları/Basınçlı hava debimetresi
    else if ([13, 21, 43].contains(deviceType)) {
      return "m³";
    }
    // Bilinmeyen cihaz tipi
    else {
      return "Unknown";
    }
  }

  static String getDeviceImageUnit(int deviceType) {
    // Elektrik ölçüm cihazları
    if ([1, 2, 3, 11, 41].contains(deviceType)) {
      return "assets/icons/kW-3.png";
    }
    // Doğalgaz/Buhar ölçüm cihazları
    else if ([12, 22, 42, 14].contains(deviceType)) {
      return "assets/icons/Buhar_Icon.png";
    }
    // Su ölçüm cihazları/Basınçlı hava debimetresi
    else if ([13, 21, 43].contains(deviceType)) {
      return "assets/icons/Su_2.png";
    }
    // Bilinmeyen cihaz tipi
    else {
      return "assets/icons/HavaHızı-3.png";
    }
  }

  // static String getDevicetypeUnit(int deviceType) {
  //   // Elektrik ölçüm cihazları
  //   if ([1, 2, 3, 11, 41].contains(deviceType)) {
  //     return "Güç";
  //   }
  //   // Doğalgaz/Buhar ölçüm cihazları
  //   else if ([12, 22, 42].contains(deviceType)) {
  //     return "";
  //   }
  //   // Su ölçüm cihazları/Basınçlı hava debimetresi
  //   else if ([13, 21, 43].contains(deviceType)) {
  //     return "Endeks";
  //   }
  //   // Bilinmeyen cihaz tipi
  //   else {
  //     return "Unknown";
  //   }
  // }
}
