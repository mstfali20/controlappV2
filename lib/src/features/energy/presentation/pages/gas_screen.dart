import 'package:controlapp/src/features/energy/presentation/pages/resource_device_list.dart';
import 'package:flutter/material.dart';
import 'package:controlapp/l10n/app_localizations.dart';

class DogalgazScren extends StatelessWidget {
  const DogalgazScren({
    super.key,
    required this.dogalgazid,
    required this.periodIndex,
    required this.termIndex,
  });

  final String? dogalgazid;
  final String? periodIndex;
  final String? termIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResourceDeviceList(
      nodeId: dogalgazid,
      periodType: periodIndex ?? '3',
      term: termIndex ?? '1',
      cardColor: Colors.grey,
      leadingBuilder: (_) => Image.asset('assets/icons/buhar.png'),
      subtitle: '${l10n.tuketim} ',
      chartColor: Colors.grey,
      chartSubtitle: l10n.tuketim,
      valueUnit: 'm³',
      amountUnit: '₺',
      emptyMessage: l10n.kategorigrafigi,
    );
  }
}
