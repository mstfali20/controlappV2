import 'package:controlapp/const/fade_zoom.dart';
import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/bottom_card.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
// import 'package:rive/rive.dart' as rive;
// Diğer importlar buraya eklenebilir

class FanlarDetail extends StatefulWidget {
  const FanlarDetail({super.key});

  @override
  State<FanlarDetail> createState() => _FanlarDetailState();
}

class _FanlarDetailState extends State<FanlarDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 30),
          FadeInAnimation(
            delay: 1,
            child: Row(
              children: [
                SizedBox(width: 30.h),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.all(25.h),
                    minimumSize: const Size(0, 0),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Iconsax.arrow_left),
                ),
                SizedBox(width: 30.h),
                const Text(
                  "Fanlar ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    child: Column(children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: 20.h,
                        ),
                        child: FadeInAnimation(
                          delay: 2.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 20.h, horizontal: 3.h),
                            decoration: BoxDecoration(
                              color: grey,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      BottomCard(
                                        header: "Aspiratörler",
                                        percentage: "  12.0%  ",
                                        value: StringHelperVirgulsuz.shortenValue(
                                            '${anaAnlikVeriMap['IOAspGostergeRPM']}'),
                                        unit: "RPM",
                                        color: Colors.indigo,
                                      ),
                                      SizedBox(width: 5.h),
                                      const Column(
                                        children: [
                                          /* GiffyBottomSheet.image(
                                            flutter.Image(
                                              image: const AssetImage(
                                                  'assets/pervaneGif.gif'),
                                              height: 130.h,
                                              width: 130.h,
                                              fit: BoxFit.cover,
                                            ),
                                          ), */
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 40.h),
                        child: FadeInAnimation(
                          delay: 2.5,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 20.h, horizontal: 2.h),
                            decoration: BoxDecoration(
                              color: grey,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      BottomCard(
                                        header: "Vantilatörler",
                                        percentage: "  12.0%  ",
                                        value: StringHelperVirgulsuz.shortenValue(
                                            '${anaAnlikVeriMap['IOVantilatorGostergeRPM']}'),
                                        unit: "RPM",
                                        color: Colors.indigo,
                                      ),
                                      SizedBox(width: 5.h),
                                      const Column(
                                        children: [
                                          /*  GiffyBottomSheet.image(
                                            flutter.Image(
                                              image: const AssetImage(
                                                  'assets/pervaneGif.gif'),
                                              height: 130.h,
                                              width: 130.h,
                                              fit: BoxFit.cover,
                                            ),
                                          ), */
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  SizedBox(height: MediaQuery.paddingOf(context).bottom + 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BarWidget extends StatelessWidget {
  const BarWidget({
    super.key,
    required this.value,
    required this.steps,
    this.isPrimary = false,
  });

  final double value;
  final String steps;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20,
      ),
      height: value * 400,
      // width: 80,
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primaryColor : AppColors.darkGreyColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Text(
            steps,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
