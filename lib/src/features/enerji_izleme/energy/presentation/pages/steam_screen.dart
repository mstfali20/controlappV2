import 'package:controlapp/src/features/enerji_izleme/energy/presentation/pages/resource_device_list.dart';
import 'package:flutter/material.dart';
import 'package:controlapp/l10n/app_localizations.dart';

class BuharScren extends StatelessWidget {
  const BuharScren({
    super.key,
    required this.buharid,
    required this.periodIndex,
    required this.termIndex,
  });

  final String? buharid;
  final String? periodIndex;
  final String? termIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResourceDeviceList(
      nodeId: buharid,
      periodType: periodIndex ?? '3',
      term: termIndex ?? '1',
      cardColor: Colors.grey,
      leadingBuilder: (_) => Image.asset('assets/icons/buhar.png'),
      subtitle: '${l10n.tuketim} ',
      chartColor: Colors.grey,
      chartSubtitle: l10n.tuketim,
      valueUnit: 'm3',
      amountUnit: '₺',
      emptyMessage: l10n.kategorigrafigi,
    );
  }
}
