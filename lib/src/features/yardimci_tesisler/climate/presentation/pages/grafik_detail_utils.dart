// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:controlapp/const/data.dart';
// import 'package:controlapp/const/Color.dart';
// import 'package:controlapp/src/features/climate/data/services/history_post.dart';
// import 'package:controlapp/data/historyModel.dart';
// import 'package:controlapp/views/v2scren/widget/grafikWidget.dart';

// Future<void> grafikdenemeFunction(BuildContext context, String title, String labelcode,
//     String unit, Color grafikcolor) async {
//   final HistoryPost historyPost = HistoryPost();
//   try {
//     String selectedPeriod = "Gün";
//     String period = '24';
//     int indexColor = 0;
//     List<HistoryData> historyDataList = [];

//     showModalBottomSheet(
//       backgroundColor: Colors.transparent,
//       context: context,
//       builder: (builder) {
//         int state = 0;
//         log("------------");
//         log(serial.toString());
//         log(seriall.toString());
//         log("------------");
//         return StatefulBuilder(
//           builder: (BuildContext context, void Function(void Function()) setState) {
//             if (state == 0) {
//               state++;
//               historyPost
//                   .fetchHistoryApi(
//                 userDataConst["username"],
//                 userDataConst["password"],
//                 seriall != null ? seriall! : serial,
//                 labelcode,
//                 period,
//               )
//                   .then((dataList) {
//                 setState(() {
//                   historyDataList = dataList;
//                 });
//               });
//             }

//             return Container(
//               padding: EdgeInsets.only(
//                 left: 25.h,
//                 right: 25.h,
//                 top: 20.h,
//                 bottom: 40.h,
//               ),
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height / 1.2,
//               decoration: BoxDecoration(
//                 color: white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(40.h),
//                   topRight: Radius.circular(40.h),
//                 ),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               title,
//                               style: TextStyle(
//                                 fontSize: 22.h,
//                                 fontWeight: FontWeight.w900,
//                                 color: black,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       InkWell(
//                         onTap: () {
//                           Navigator.pop(context);
//                         },
//                         child: Icon(
//                           Icons.close,
//                           size: 30.h,
//                           color: black,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 10.h),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: List.generate(4, (index) {
//                             String option;
//                             switch (index) {
//                               case 0:
//                                 option = 'Gün';
//                                 break;
//                               case 1:
//                                 option = 'Hafta';
//                                 break;
//                               case 2:
//                                 option = 'Ay';
//                                 break;
//                               case 3:
//                                 option = 'Yıl';
//                                 break;
//                               default:
//                                 option = 'Gün';
//                                 break;
//                             }
//                             return GestureDetector(
//                               onTap: () async {
//                                 setState(() {
//                                   indexColor = index;
//                                   selectedPeriod = option;
//                                 });
//                                 switch (selectedPeriod) {
//                                   case 'Gün':
//                                     period = '24';
//                                     break;
//                                   case 'Hafta':
//                                     period = '168';
//                                     break;
//                                   case 'Ay':
//                                     period = '720';
//                                     break;
//                                   case 'Yıl':
//                                     period = '8760';
//                                     break;
//                                   default:
//                                     period = '24';
//                                 }
//                                 historyPost
//                                     .fetchHistoryApi(
//                                   userDataConst["username"],
//                                   userDataConst["password"],
//                                   seriall != null ? seriall! : serial,
//                                   labelcode,
//                                   period,
//                                 )
//                                     .then((dataList) {
//                                   setState(() {
//                                     historyDataList = dataList;
//                                   });
//                                 });
//                               },
//                               child: Container(
//                                 height: 40,
//                                 width: 80,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: indexColor == index ? contolblue : Colors.white,
//                                 ),
//                                 alignment: Alignment.center,
//                                 child: Text(
//                                   option,
//                                   style: TextStyle(
//                                     color: indexColor == index ? Colors.white : Colors.black,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Expanded(
//                     child: GrafikWidget(
//                       historyDataList: historyDataList,
//                       period: period,
//                       unit: unit,
//                       grafikcolor: grafikcolor,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   } catch (e) {
//     log('Error: $e');
//   }
// }
