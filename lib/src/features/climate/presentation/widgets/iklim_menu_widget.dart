import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:controlapp/src/features/presentation/home/view_model/home_cubit.dart';

import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/data/xmlModel.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/climate_xml_list_screen.dart';

class IklimMenuWidget extends StatelessWidget {
  const IklimMenuWidget({
    super.key,
    required this.organisation,
    required this.loadAndParseXml,
  });

  final String organisation;
  final Future<List<XmlModel>> Function() loadAndParseXml;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.1,
        top: 5,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.white,
            size: 30.sp,
          ),
          padding: EdgeInsets.zero,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () {
            final homeCubit = context.read<HomeCubit>();
            showDialog(
              barrierColor: Colors.transparent,
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return Scaffold(
                  backgroundColor: Colors.white70,
                  body: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FutureBuilder<List<XmlModel>>(
                          future: loadAndParseXml(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: contolblue,
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Hata: ${snapshot.error}'),
                              );
                            }

                            final nodes = snapshot.data;
                            if (nodes == null || nodes.isEmpty) {
                              return const Center(
                                child: Text('Veri bulunamadı.'),
                              );
                            }

                            final root = nodes.firstWhere(
                              (node) =>
                                  node.caption == userDataConst['firm_name'],
                              orElse: XmlModel.empty,
                            );

                            final organization = root.children.firstWhere(
                              (child) => child.caption == organisation,
                              orElse: XmlModel.empty,
                            );

                            final devices = _collectDevices(organization);
                            if (devices.isEmpty) {
                              return const Center(
                                child: Text(
                                  'Seçilebilecek cihaz bulunamadı.',
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            return Flexible(
                              child: BlocProvider.value(
                                value: homeCubit,
                                child: ClimateXmlListScreen(
                                  nodes: devices,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<XmlModel> _collectDevices(XmlModel root) {
    final result = <XmlModel>[];

    void traverse(XmlModel node) {
      if (node.classType == 'obm_device') {
        result.add(node);
      }
      for (final child in node.children) {
        traverse(child);
      }
    }

    traverse(root);
    return result;
  }
}
