import 'package:controlapp/const/Color.dart';
import 'package:controlapp/data/tree_node.dart';
import 'package:controlapp/src/features/presentation/home/view_model/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClimateTreeListScreen extends StatefulWidget {
  const ClimateTreeListScreen({
    super.key,
    required this.nodes,
    this.onDeviceSelected,
  });

  final List<TreeNode> nodes;
  final VoidCallback? onDeviceSelected;

  @override
  State<ClimateTreeListScreen> createState() => _ClimateTreeListScreenState();
}

class _ClimateTreeListScreenState extends State<ClimateTreeListScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.nodes.length * 90.h,
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
            itemCount: widget.nodes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final node = widget.nodes[index];
              return _buildNodeTile(context, node);
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildNodeTile(BuildContext context, TreeNode node) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            node.caption,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.h,
              color: Colors.white,
            ),
          ),
          onTap: _isLoading
              ? null
              : () async {
                  setState(() {
                    _isLoading = true;
                  });

                  final cubit = context.read<HomeCubit>();
                  await cubit.changeDevice(
                    deviceId: node.id,
                    deviceTitle: node.caption,
                    plcTitle: node.title,
                    module: HomeCubit.climateModuleCaption,
                  );

                  if (!mounted) {
                    return;
                  }

                  widget.onDeviceSelected?.call();
                  Navigator.pop(context);

                  setState(() {
                    _isLoading = false;
                  });
                },
        ),
        const Divider(),
      ],
    );
  }
}
