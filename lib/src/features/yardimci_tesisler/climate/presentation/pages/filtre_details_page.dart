import 'package:controlapp/const/fade_zoom.dart';
import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:controlapp/src/features/yardimci_tesisler/climate/presentation/widgets/filtre_widget.dart';
import 'package:controlapp/src/features/yardimci_tesisler/climate/presentation/widgets/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
// Diğer importlar buraya eklenebilir

class FiltreDetail extends StatefulWidget {
  const FiltreDetail({super.key});

  @override
  State<FiltreDetail> createState() => _FiltreDetailState();
}

class _FiltreDetailState extends State<FiltreDetail> {
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
                Text(
                  AppLocalizations.of(context)!.filtreKirliligi,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25.h,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    child: Column(children: [
                      Padding(
                        padding: EdgeInsets.all(1.0.h),
                        child: FadeInAnimation(
                          delay: 2.5,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12.h, horizontal: 20.h),
                            decoration: BoxDecoration(
                              color: creamColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              children: [
                                // Text(
                                //   "Filtre Kirlilik",
                                //   textAlign: TextAlign.center,
                                //   style: TextStyle(
                                //     fontSize: 22,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: 10.h, bottom: 10.h),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10.h, horizontal: 10.h),
                                    decoration: BoxDecoration(
                                      color: grey,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(20.h),
                                      child: FiltreWidget(
                                          fillPercentage: int.tryParse(
                                                  StringHelperVirgulsuz
                                                      .shortenValue(
                                                          '${anaAnlikVeriMap['IOFiltreFarkBasinc']}')) ??
                                              0), //IOFiltreFarkBasinc
                                    ),
                                  ),
                                ),
                              ],
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
