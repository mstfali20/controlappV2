import 'package:controlapp/const/Color.dart';
import 'package:controlapp/src/features/energy/presentation/pages/resource_device_list.dart';
import 'package:flutter/material.dart';
import 'package:controlapp/l10n/app_localizations.dart';

class SuScren extends StatelessWidget {
  const SuScren({
    super.key,
    required this.suid,
    required this.periodIndex,
    required this.termIndex,
  });

  final String? suid;
  final String? periodIndex;
  final String? termIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResourceDeviceList(
      nodeId: suid,
      periodType: periodIndex ?? '3',
      term: termIndex ?? '1',
      cardColor: sublue,
      leadingBuilder: (_) => Image.asset('assets/icons/su.png'),
      subtitle: '${l10n.tuketim} ',
      chartColor: sublue,
      chartSubtitle: l10n.tuketim,
      valueUnit: 'm³',
      amountUnit: '₺',
      emptyMessage: l10n.kategorigrafigi,
    );
  }
}
