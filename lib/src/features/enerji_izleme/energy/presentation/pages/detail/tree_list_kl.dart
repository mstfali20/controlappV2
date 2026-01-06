import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/data/tree_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:controlapp/src/core/di/injector.dart';
import 'package:controlapp/src/features/auth/domain/usecases/get_session_usecase.dart';
import 'package:controlapp/src/features/auth/domain/usecases/save_session_usecase.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/domain/usecases/fetch_energy_snapshot_usecase.dart';

class TreeListKlScreen extends StatefulWidget {
  final List<TreeNode> nodes;

  final void Function(int) callback;

  const TreeListKlScreen({
    super.key,
    required this.nodes,
    required this.callback,
  });

  @override
  _TreeListKlScreenState createState() => _TreeListKlScreenState();
}

class _TreeListKlScreenState extends State<TreeListKlScreen> {
  @override
  void initState() {
    super.initState();
    _hydrateSession();
  }

  String? username;
  String? password;
  String? seriall;
  String? serialTitlee;
  bool _isLoading = false;

  void _hydrateSession() {
    setState(() {
      username = userDataConst['username']?.toString();
      password = userDataConst['password']?.toString();
      seriall = serial.isNotEmpty ? serial : null;
      serialTitlee = serialTitle.isNotEmpty ? serialTitle : null;
    });
  }

  Future<void> _persistSession({
    required String deviceId,
    required String deviceTitle,
  }) async {
    final getSession = getIt<GetSessionUseCase>();
    final saveSession = getIt<SaveSessionUseCase>();

    final currentSession = await getSession();
    if (currentSession == null) {
      return;
    }

    final updatedSession = currentSession.copyWith(
      serial: deviceId,
      plcTitle: deviceTitle,
      serialTitle: serialTitlee ?? serialTitle,
      extras: {
        ...currentSession.extras,
        'selected_module': enerjiIzlem,
      },
    );

    await saveSession(SaveSessionParams(session: updatedSession));
  }

  Future<void> _handleSelection({
    required String username,
    required String password,
    required String deviceId,
    required String deviceTitle,
  }) async {
    setState(() {
      _isLoading = true;
    });

    final fetchUseCase = getIt<FetchEnergySnapshotUseCase>();

    try {
      final snapshot = await fetchUseCase(
        FetchEnergySnapshotParams(
          username: username,
          password: password,
          deviceId: deviceId,
        ),
      );

      if (snapshot.isSuccess) {
        anaAnlikVeriMap
          ..clear()
          ..addAll(snapshot.values);

        serial = deviceId;
        seriall = deviceId;
        plcTitle = deviceTitle;
        serialTitle = serialTitlee ?? serialTitle;
        userDataConst['serial'] = deviceId;
        userDataConst['serialTitle'] = serialTitle;
        userDataConst['plcTitle'] = plcTitle;
        userDataConst['selected_module'] = enerjiIzlem;

        await _persistSession(deviceId: deviceId, deviceTitle: deviceTitle);

        widget.callback(2);

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showError(
          snapshot.errorDescription ?? 'Anlık veri alınırken hata oluştu.',
        );
      }
    } catch (error) {
      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: grey,
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        height: (widget.nodes.length) * 90.h,
        padding: EdgeInsets.all(15.h),
        width: MediaQuery.of(context).size.width * 0.60,
        decoration: BoxDecoration(
          color: contolblue,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50.h)),
        ),
        child: ListView.separated(
          scrollDirection: Axis.vertical,
          itemCount: widget.nodes.length,
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            TreeNode node = widget.nodes[index];
            return _buildNodeTile(context, node);
          },
        ),
      ),
    );
  }

  Widget _buildNodeTile(BuildContext context, TreeNode node) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListTile(
          title: Text(
            node.caption,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.h,
                color: Colors.white),
          ),
          onTap: _isLoading
              ? null
              : () async {
                  final effectiveUsername =
                      username ?? userDataConst['username']?.toString();
                  final effectivePassword =
                      password ?? userDataConst['password']?.toString();

                  if (effectiveUsername == null ||
                      effectivePassword == null ||
                      effectiveUsername.isEmpty ||
                      effectivePassword.isEmpty) {
                    _showError(
                      'Kullanıcı bilgileri yükleniyor, lütfen bekleyin.',
                    );
                    return;
                  }

                  serialTitlee = node.caption;
                  serial = node.id;
                  seriall = node.id;
                  plcTitle = node.caption;
                  selectedModule = enerjiIzlem;
                  userDataConst['selected_module'] = enerjiIzlem;
                  userDataConst['serial'] = node.id;
                  userDataConst['serialTitle'] = node.caption;
                  userDataConst['plcTitle'] = node.caption;

                  await _handleSelection(
                    username: effectiveUsername,
                    password: effectivePassword,
                    deviceId: node.id,
                    deviceTitle: node.caption,
                  );
                },
        ),
        const Divider(),
      ],
    );
  }
}
