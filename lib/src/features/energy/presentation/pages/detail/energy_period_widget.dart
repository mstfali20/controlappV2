import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/src/features/energy/presentation/widgets/energy_total_card.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnerjiPeriodWidget extends StatefulWidget {
  final String deviceId; // Dışarıdan alınacak olan deviceId

  const EnerjiPeriodWidget({super.key, required this.deviceId});

  @override
  State<EnerjiPeriodWidget> createState() => _EnerjiPeriodWidgetState();
}

class _EnerjiPeriodWidgetState extends State<EnerjiPeriodWidget> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String? username; // Nullable
  String? password; // Nullable
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      password = prefs.getString('password');
    });
  }

  @override
  Widget build(BuildContext context) {
    // final languageProvider = Provider.of<LanguageProvider>(context);

    // Seçili kategoriye göre gösterilecek widget
    String user = username != null ? username! : userDataConst["username"];
    String pass = password != null ? password! : userDataConst["password"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          EnergyTotalCard(
            title: AppLocalizations.of(context)!.bugun,

            gradientStartColor: creamColor,
            gradientEndColor: creamColor,
            username: user, // Dinamik username
            password: pass, // Dinamik password
            periodType: '1', // Dinamik periodType
            deviceId: widget.deviceId, // Dinamik deviceId
            type: '1', // Dinamik type
            totalCheckPt: '0', // Dinamik totalCheckPt
            term: '0', // Dinamik term
          ),
          EnergyTotalCard(
            title: AppLocalizations.of(context)!.buHafta,

            gradientStartColor: creamColor,
            gradientEndColor: creamColor,
            username: user, // Dinamik username
            password: pass, // Dinamik password
            periodType: '2', // Dinamik periodType
            deviceId: widget.deviceId, // Dinamik deviceId
            type: '1', // Dinamik type
            totalCheckPt: '0', // Dinamik totalCheckPt
            term: '0', // Dinamik term
          ),
          EnergyTotalCard(
            title: AppLocalizations.of(context)!.buAy,

            gradientStartColor: creamColor,
            gradientEndColor: creamColor,
            username: user, // Dinamik username
            password: pass, // Dinamik password
            periodType: '3', // Dinamik periodType
            deviceId: widget.deviceId, // Dinamik deviceId
            type: '1', // Dinamik type
            totalCheckPt: '0', // Dinamik totalCheckPt
            term: '0',
          ),
          EnergyTotalCard(
            title: AppLocalizations.of(context)!.buYil,
            gradientStartColor: creamColor,
            gradientEndColor: creamColor,
            username: user, // Dinamik username
            password: pass, // Dinamik password
            periodType: '4', // Dinamik periodType
            deviceId: widget.deviceId, // Dinamik deviceId
            type: '1', // Dinamik type
            totalCheckPt: '0', // Dinamik totalCheckPt
            term: '0',
          ),
        ],
      ),
    );
  }
}
