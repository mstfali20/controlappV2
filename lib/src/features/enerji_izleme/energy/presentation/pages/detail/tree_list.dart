import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/data/tree_node.dart';
import 'energy_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:controlapp/src/core/di/injector.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/domain/usecases/fetch_energy_snapshot_usecase.dart';

class TreeListScreen extends StatefulWidget {
  final List<TreeNode> nodes;

  const TreeListScreen({super.key, required this.nodes});

  @override
  // ignore: library_private_types_in_public_api
  _TreeListScreenState createState() => _TreeListScreenState();
}

class _TreeListScreenState extends State<TreeListScreen> {
  String? username;
  String? password;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _hydrateSession();
  }

  void _hydrateSession() {
    setState(() {
      username = userDataConst['username']?.toString();
      password = userDataConst['password']?.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        height: (widget.nodes.length - 1) * 90.h,
        padding: EdgeInsets.all(15.h),
        width: MediaQuery.of(context).size.width * 0.60,
        decoration: BoxDecoration(
          color: contolblue,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50.h)),
        ),
        child: Stack(
          children: [
            ListView.separated(
              scrollDirection: Axis.vertical,
              itemCount: widget.nodes.length - 1,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                TreeNode node = widget.nodes[index + 1];
                return _buildNodeTile(context, node);
              },
            ),
            if (_isLoading) _buildLoadingIndicator(), // Yükleniyor göstergesi
          ],
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
                  setState(() {
                    _isLoading = true;
                  });

                  final isError = await _fetchDataAndNavigate(node);

                  if (!isError) {
                    Navigator.push(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(
                        builder: (context) => EnerjiDetail(
                          data: node,
                          title: node.caption,
                        ),
                      ),
                    );
                  }

                  setState(() {
                    _isLoading = false;
                  });
                },
        ),
        const Divider(),
      ],
    );
  }

  Future<bool> _fetchDataAndNavigate(TreeNode node) async {
    final effectiveUsername = username ?? userDataConst['username']?.toString();
    final effectivePassword = password ?? userDataConst['password']?.toString();

    if (effectiveUsername == null ||
        effectivePassword == null ||
        effectiveUsername.isEmpty ||
        effectivePassword.isEmpty) {
      _showSnackBar(
        'Kullanıcı bilgileri bulunamadı. Lütfen giriş yapınız.',
        isError: true,
      );
      return true;
    }

    final fetchUseCase = getIt<FetchEnergySnapshotUseCase>();

    try {
      for (final child in node.children) {
        final snapshot = await fetchUseCase(
          FetchEnergySnapshotParams(
            username: effectiveUsername,
            password: effectivePassword,
            deviceId: child.id,
          ),
        );

        if (snapshot.isSuccess) {
          final values = snapshot.values;
          setState(() {
            child.akim = values['InsCurTotal'] ?? child.akim;
            child.kwa = values['InsActPowerTotal'] ?? child.kwa;
            child.subuhar = values['EnergyTotalRawIndexValue'] ?? child.subuhar;
          });
        }
      }
      return false;
    } catch (error) {
      _showSnackBar(error.toString(), isError: true);
      return true;
    }
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Çark rengi
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.red : grey,
        content: Text(
          message,
          style: TextStyle(
            color: creamColor,
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
