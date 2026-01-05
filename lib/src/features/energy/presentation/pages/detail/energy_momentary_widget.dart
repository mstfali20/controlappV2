import 'dart:developer';
import 'package:controlapp/src/features/energy/presentation/widgets/veri_card_enerjy.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:controlapp/src/features/energy/domain/utils/device_type_helper.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/string_helper.dart';
import 'package:flutter/material.dart';

class EnerjiMomentaryWidget extends StatefulWidget {
  final String deviceId; // Dışarıdan alınacak olan deviceId
  final String kw; // Dışarıdan alınacak olan deviceId
  final String akim; // Dışarıdan alınacak olan deviceId deviceType
  final String deviceType;
  final String subuhar;
  const EnerjiMomentaryWidget(
      {super.key,
      required this.deviceId,
      required this.kw,
      required this.akim,
      required this.deviceType,
      required this.subuhar});

  @override
  State<EnerjiMomentaryWidget> createState() => _EnerjiMomentaryWidgetState();
}

class _EnerjiMomentaryWidgetState extends State<EnerjiMomentaryWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String getDevicetypeUnit(int deviceType) {
      // Elektrik ölçüm cihazları
      if ([1, 2, 3, 11, 41].contains(deviceType)) {
        return AppLocalizations.of(context)!.guc;
      }
      // Doğalgaz/Buhar ölçüm cihazları
      else if ([12, 22, 42, 14].contains(deviceType)) {
        return "";
      }
      // Su ölçüm cihazları/Basınçlı hava debimetresi
      else if ([
        13,
        21,
        43,
      ].contains(deviceType)) {
        return AppLocalizations.of(context)!.endeks;
      }
      // Bilinmeyen cihaz tipi
      else {
        return "Unknown";
      }
    }

    // Seçili kategoriye göre gösterilecek widget
    log(widget.deviceType.toString());
    return VeriCardEnerjyList(
      showIconButton: true,
      title: AppLocalizations.of(context)!.tuketim,
      veriCardDataList: [
        VeriCardEnerjy(
          iconPath: Stringdeger.getDeviceImageUnit(
            int.tryParse(widget.deviceType) ??
                1, // String'i int'e dönüştür, başarısız olursa 0 kullan
          ),
          header: getDevicetypeUnit(
            int.tryParse(widget.deviceType) ??
                1, // String'i int'e dönüştür, başarısız olursa 0 kullan
          ),
          percentage: "  12.0%  ",
          color: Colors.indigo,
          value: widget.kw.isNotEmpty
              ? StringHelper.shortenValue(widget.kw)
              : StringHelper.shortenValue(widget.subuhar),
          unit: Stringdeger.getDeviceTypeUnit(
            int.tryParse(widget.deviceType) ??
                0, // String'i int'e dönüştür, başarısız olursa 0 kullan
          ),
          title: AppLocalizations.of(context)!.guc,
        ),
        if (widget.akim.isNotEmpty)
          VeriCardEnerjy(
            iconPath: "assets/icons/Akım.png",

            header: AppLocalizations.of(context)!.akim,
            percentage: "  9.2%  ",
            color: Colors.red,
            value: StringHelper.shortenValue(
              widget.akim,
            ),
            unit: " A",
            title: AppLocalizations.of(context)!.akim,

            // Başlık eklendi
          ),
        // Diğer VeriCardData öğeleri buraya eklenebilir
      ],
    );
  }
}
