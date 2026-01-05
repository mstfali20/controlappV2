import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/src/features/energy/presentation/widgets/energy_total_card.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnerjiFormeriWidget extends StatefulWidget {
  final String deviceId; // Dışarıdan alınacak olan deviceId

  const EnerjiFormeriWidget({super.key, required this.deviceId});

  @override
  State<EnerjiFormeriWidget> createState() => _EnerjiFormeriWidgetState();
}

class _EnerjiFormeriWidgetState extends State<EnerjiFormeriWidget> {
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
    // Seçili kategoriye göre gösterilecek widget
    String user = username != null ? username! : userDataConst["username"];
    String pas = password != null ? password! : userDataConst["password"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          EnergyTotalCard(
            title: AppLocalizations.of(context)!.dun,

            gradientStartColor: creamColor,
            gradientEndColor: creamColor,
            username: user, // Dinamik username
            password: pas, // Dinamik password
            periodType: '1', // Dinamik periodType
            deviceId: widget.deviceId, // Dinamik deviceId
            type: '1', // Dinamik type
            totalCheckPt: '0', // Dinamik totalCheckPt
            term: '1', // Dinamik term
          ),
          EnergyTotalCard(
            title: AppLocalizations.of(context)!.gecenHafta,

            gradientStartColor: creamColor,
            gradientEndColor: creamColor,
            username: user, // Dinamik username
            password: pas, // Dinamik password
            periodType: '2', // Dinamik periodType
            deviceId: widget.deviceId, // Dinamik deviceId
            type: '1', // Dinamik type
            totalCheckPt: '0', // Dinamik totalCheckPt
            term: '1', // Dinamik term
          ),
          EnergyTotalCard(
            title: AppLocalizations.of(context)!.gecenAy,

            gradientStartColor: creamColor,
            gradientEndColor: creamColor,
            username: user, // Dinamik username
            password: pas, // Dinamik password
            periodType: '3', // Dinamik periodType
            deviceId: widget.deviceId, // Dinamik deviceId
            type: '1', // Dinamik type
            totalCheckPt: '0', // Dinamik totalCheckPt
            term: '1',
          ),
          EnergyTotalCard(
            title: AppLocalizations.of(context)!.gecenYil,
            gradientStartColor: creamColor,
            gradientEndColor: creamColor,
            username: user, // Dinamik username
            password: pas, // Dinamik password
            periodType: '4', // Dinamik periodType
            deviceId: widget.deviceId, // Dinamik deviceId
            type: '1', // Dinamik type
            totalCheckPt: '0', // Dinamik totalCheckPt
            term: '1',
          ),
        ],
      ),
    );
  }
}
