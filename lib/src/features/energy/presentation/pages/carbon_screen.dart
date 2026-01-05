import 'package:controlapp/src/features/energy/presentation/widgets/custom_difference_widget.dart';
import 'package:controlapp/src/features/energy/presentation/widgets/custom_karbon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:controlapp/l10n/app_localizations.dart';

class KarbonScren extends StatelessWidget {
  const KarbonScren({
    super.key,
    required this.totalTuketimId,
    required this.uretimTuketimId,
    required this.dogalgazDeviceId,
    required this.periodIndex,
    required this.termIndex,
  });

  final String? totalTuketimId;
  final String? uretimTuketimId;
  final String? dogalgazDeviceId;
  final String? periodIndex;
  final String? termIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    var factoryTitle = l10n.karbonEmisyonu;
    var factorySubtitle = l10n.tuketim;
    var gesTitle = l10n.karbonAzaltimi;
    var gesSubtitle = l10n.uretim;
    var diffTitle = l10n.karbonEmisyonFarki;
    var diffSubtitle = l10n.agacSayisi;

    return Column(
      children: [
        CustomKarbonWidget(
          title: factoryTitle,
          subtitle: factorySubtitle,
          backgroundColor: Colors.grey,
          leading: Image.asset('assets/icons/karbon.png'),
          periodType: periodIndex ?? '3',
          term: termIndex ?? '1',
          deviceId: totalTuketimId ?? '',
          gasDeviceId: dogalgazDeviceId,
          onTap: () {},
        ),
        CustomKarbonWidget(
          title: gesTitle,
          subtitle: gesSubtitle,
          backgroundColor: Colors.green.shade700,
          leading: Icon(Icons.eco, size: 70.sp, color: Colors.white),
          periodType: periodIndex ?? '3',
          term: termIndex ?? '1',
          deviceId: uretimTuketimId ?? '',
          onTap: () {},
        ),
        CustomFarkKarbonWidget(
          title: diffTitle,
          subtitle: diffSubtitle,
          backgroundColor: Colors.grey.shade600,
          leading: Image.asset('assets/icons/ayak.png'),
          periodType: periodIndex ?? '3',
          term: termIndex ?? '1',
          consumptionDeviceId: totalTuketimId ?? '',
          productionDeviceId: uretimTuketimId ?? '',
          gasDeviceId: dogalgazDeviceId,
          onTap: () {},
        ),
      ],
    );
  }
}
