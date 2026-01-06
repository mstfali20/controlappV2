import 'package:controlapp/const/data.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/presentation/pages/energy_chart_page.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/presentation/widgets/custom_main_widget.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/presentation/widgets/pasta_widget.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class OverviewScreen extends StatefulWidget {
  final String? totalTuketimId; // TotalTuketimId değişkeni
  final String? buharTuketimId; // BuharTuketimId değişkeni
  final String? suTuketimId; // SuTuketimId değişkeni
  final String? dogalgazTuketimId; // DogalgazTuketimId değişkeni
  final String? uretimTuketimId; // UretimTuketimId değişkeni
  final String? gesfark; // UretimTuketimId değişkeni
  final String? periodIndex; // UretimTuketimId değişkeni
  final String? termIndex; // UretimTuketimId değişkeni

  const OverviewScreen({
    super.key,
    required this.totalTuketimId,
    required this.buharTuketimId,
    required this.suTuketimId,
    required this.dogalgazTuketimId,
    required this.uretimTuketimId,
    required this.gesfark,
    required this.periodIndex,
    required this.termIndex,
  });

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  @override
  Widget build(BuildContext context) {
    // Seçili kategoriye göre gösterilecek widget

    return Column(
      children: [
        // Seçilen kategoriye göre gösterilen widget
        Column(
          children: [
            CustomMainWidget(
              title: AppLocalizations.of(context)!.fabrikatoplamtuketim,
              subtitle: AppLocalizations.of(context)!.tuketim,
              backgroundColor: Colors.green,
              leading: Image.asset('assets/icons/kwh.png'),
              periodType: widget.periodIndex.toString(),
              term: widget.termIndex.toString(),
              deviceId: widget.totalTuketimId.toString(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GrafikPage(
                      barColor: Colors.red,
                      title: AppLocalizations.of(context)!.fabrikatoplamtuketim,
                      subtitle: AppLocalizations.of(context)!.tuketim,
                      deviceId: widget.totalTuketimId.toString(),
                      birimValue: 'kWh',
                      degerValue: '₺',
                      periodIndex: widget.periodIndex.toString(),
                    ),
                  ),
                );
              },
            ),
            CustomMainWidget(
              title: AppLocalizations.of(context)!.gesUretim,
              subtitle: AppLocalizations.of(context)!.uretim,
              backgroundColor: Colors.green,
              leading: Image.asset('assets/icons/kwh.png'),
              periodType: widget.periodIndex.toString(),
              term: widget.termIndex.toString(),
              deviceId: widget.uretimTuketimId.toString(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GrafikPage(
                      barColor: Colors.green,
                      title: AppLocalizations.of(context)!.gesUretim,
                      subtitle: AppLocalizations.of(context)!.uretim,
                      deviceId: widget.uretimTuketimId.toString(),
                      birimValue: "kWh",
                      degerValue: "₺",
                      periodIndex: widget.periodIndex.toString(),
                    ),
                  ),
                );
              },
            ),
            CustomMainWidget(
              title: AppLocalizations.of(context)!.gesUretimFarki,
              subtitle: AppLocalizations.of(context)!.fark,
              backgroundColor: Colors.green,
              leading: Image.asset('assets/icons/kwh.png'),
              periodType: widget.periodIndex.toString(),
              term: widget.termIndex.toString(),
              deviceId: widget.gesfark.toString(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GrafikPage(
                      barColor: Colors.green,
                      title: AppLocalizations.of(context)!.gesUretimFarki,
                      subtitle: AppLocalizations.of(context)!.fark,
                      deviceId: widget.gesfark.toString(),
                      birimValue: 'kWh',
                      degerValue: '₺',
                      periodIndex: widget.periodIndex.toString(),
                    ),
                  ),
                );
              },
              // Grafik gösterim fonksiyonu
            ),
            PastaWidget(
              organizationId: organizationid,
              periodId: widget.periodIndex.toString(),
              typeId: widget.termIndex.toString(),
              excludeKey: "GES", // Exclude the specified key
            )
          ],
        ),
        // SizedBox(height: MediaQuery.paddingOf(context).bottom + 100.h),
      ],
    );
  }
}
