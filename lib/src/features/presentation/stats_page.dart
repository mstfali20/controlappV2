// import 'dart:ui';

// import 'package:controlapp/const/Color.dart';
// import 'package:controlapp/const/fade_zoom.dart';
// import 'package:controlapp/widget/card.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

// import 'package:iconsax/iconsax.dart';

// class StatsPage extends StatelessWidget {
//   const StatsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           SizedBox(height: MediaQuery.paddingOf(context).top + 30),
//           FadeInAnimation(
//             delay: 1,
//             child: Row(
//               children: [
//                 const SizedBox(width: 16),
//                 OutlinedButton(
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.all(25),
//                     minimumSize: const Size(0, 0),
//                     foregroundColor: Colors.black,
//                   ),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Icon(Iconsax.arrow_left),
//                 ),
//                 const Spacer(),
//                 OutlinedButton(
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.all(25),
//                     minimumSize: const Size(0, 0),
//                     foregroundColor: Colors.black,
//                   ),
//                   onPressed: () {},
//                   child: const Icon(Iconsax.export_1),
//                 ),
//                 const SizedBox(width: 10),
//                 OutlinedButton(
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.all(25),
//                     minimumSize: const Size(0, 0),
//                     foregroundColor: Colors.black,
//                   ),
//                   onPressed: () {},
//                   child: const Icon(Iconsax.setting),
//                 ),
//                 const SizedBox(width: 16),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   FadeInAnimation(
//                     delay: 1.5,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 10),
//                         Row(
//                           children: [
//                             const Text(
//                               "Havuz Verileri",
//                               style: TextStyle(
//                                 fontSize: 32,
//                               ),
//                             ),
//                             const Spacer(),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 20,
//                                 vertical: 8,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: bgColor,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: const Row(
//                                 children: [
//                                   Text(
//                                     "Gun",
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   SizedBox(width: 4),
//                                   RotatedBox(
//                                     quarterTurns: 3,
//                                     child: Icon(
//                                       Icons.chevron_left,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   const FadeInAnimation(
//                     delay: 2,
//                     child: SizedBox(
//                       height: 400,
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           BarWidget(
//                             value: .5,
//                             steps: '1,000',
//                           ),
//                           BarWidget(
//                             value: .8,
//                             steps: '1,211',
//                           ),
//                           BarWidget(
//                             value: .9,
//                             steps: '   2,000   ',
//                             isPrimary: true,
//                           ),
//                           BarWidget(
//                             value: .4,
//                             steps: '800',
//                           ),
//                           BarWidget(
//                             value: .4,
//                             steps: '1,000',
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   SingleChildScrollView(
//                     child: Column(children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: FadeInAnimation(
//                           delay: 3,
//                           child: Transform.rotate(
//                             angle: 0,
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(40),
//                               child: BackdropFilter(
//                                 filter:
//                                     ImageFilter.blur(sigmaX: 30, sigmaY: 30),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 20,
//                                     horizontal: 30,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.withOpacity(.9),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       const Expanded(
//                                         flex: 2,
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             FittedBox(
//                                               child: Text(
//                                                 "Havuz Verileri",
//                                                 style: TextStyle(
//                                                   fontSize: 26,
//                                                   fontWeight: FontWeight.w900,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                             ),
//                                             SizedBox(height: 10),
//                                             Row(
//                                               children: [
//                                                 BottomCard(
//                                                   header: "🔥  Sıcaklık",
//                                                   percentage: "  12.0%  ",
//                                                   value: "234",
//                                                   unit: "°C",
//                                                   color: Colors.indigo,
//                                                 ),
//                                               ],
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ]),
//                   ),
//                   SizedBox(height: MediaQuery.paddingOf(context).bottom + 40),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class BarWidget extends StatelessWidget {
//   const BarWidget({
//     super.key,
//     required this.value,
//     required this.steps,
//     this.isPrimary = false,
//   });

//   final double value;
//   final String steps;
//   final bool isPrimary;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 10,
//         vertical: 20,
//       ),
//       height: value * 400,
//       // width: 80,
//       decoration: BoxDecoration(
//         color: isPrimary ? primaryColor : darkGreyColor,
//         borderRadius: const BorderRadius.vertical(
//           top: Radius.circular(20),
//         ),
//       ),
//       child: Column(
//         children: [
//           Text(
//             steps,
//             style: const TextStyle(
//                 fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }
// }
