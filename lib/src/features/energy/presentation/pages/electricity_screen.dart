import 'package:controlapp/src/features/energy/presentation/pages/resource_device_list.dart';
import 'package:flutter/material.dart';
import 'package:controlapp/l10n/app_localizations.dart';

class EnergyScren extends StatelessWidget {
  const EnergyScren({
    super.key,
    required this.energyId,
    required this.periodIndex,
    required this.termIndex,
  });

  final String? energyId;
  final String? periodIndex;
  final String? termIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResourceDeviceList(
      nodeId: energyId,
      periodType: periodIndex ?? '3',
      term: termIndex ?? '1',
      cardColor: Colors.red,
      leadingBuilder: (_) => Image.asset('assets/icons/kwh.png'),
      subtitle: '${l10n.tuketim} ',
      chartColor: Colors.red,
      chartSubtitle: l10n.tuketim,
      valueUnit: 'kWh',
      amountUnit: '₺',
      emptyMessage: l10n.kategorigrafigi,
    );
  }
}
