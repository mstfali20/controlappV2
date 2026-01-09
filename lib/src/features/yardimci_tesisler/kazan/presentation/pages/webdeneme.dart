// import 'package:controlapp/src/features/presentation/role/pages/webmimik.dart';
// import 'package:flutter/material.dart';

// class WebKazanWidget extends StatelessWidget {
//   const WebKazanWidget({super.key});

//   static const _mimikUrl =
//       'https://web.controlapp.net.tr/em_mimic_diagram.php?uname=controlapp&p=1234';

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (ctx, constraints) {
//         final maxW = constraints.maxWidth.isFinite
//             ? constraints.maxWidth
//             : MediaQuery.of(ctx).size.width;
//         final h = maxW / (3 / 2); // 3:2 oran → sonlu yükseklik

//         return SizedBox(
//           width: maxW,
//           height: h,
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: const WebMimikInline(
//               url: _mimikUrl,
//               showToolbar: true, // pinch + butonlu zoom
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
