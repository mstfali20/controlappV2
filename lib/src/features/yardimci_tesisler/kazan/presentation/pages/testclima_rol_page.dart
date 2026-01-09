// import 'package:controlapp/const/data.dart';
// import 'package:controlapp/src/features/presentation/role/pages/webmimik.dart';
// import 'package:controlapp/src/features/presentation/role/widgets/testkazan.dart';
// import 'package:flutter/material.dart';

// class KazanWidget extends StatefulWidget {
//   const KazanWidget({super.key});

//   @override
//   State<KazanWidget> createState() => _KazanWidgetState();
// }

// class _KazanWidgetState extends State<KazanWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final width = constraints.maxWidth.isFinite
//             ? constraints.maxWidth
//             : MediaQuery.of(context).size.width;
//         final height = width / (3 / 2); // 3:2

//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // 1. alan (mevcut etkileşimli kazan haritası)
//             SizedBox(
//               width: width,
//               height: height,
//               child: KazanInteractiveSection(data: anaAnlikVeriMap),
//             ),

//             const SizedBox(height: 12),

//             // 2. alan (web mimik - sadece tasarım)
//             SizedBox(
//               width: width,
//               height: height, // 3:2
//               child: const WebMimikInline(
//                 url:
//                     'https://web.controlapp.net.tr/em_mimic_diagram.php?uname=controlapp&p=1234',
//               ),
//             )
//           ],
//         );
//       },
//     );
//   }
// }
