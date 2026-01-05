import 'package:controlapp/const/Color.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/bottom_card.dart';
import 'package:controlapp/src/features/climate/presentation/widgets/string_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:controlapp/l10n/app_localizations.dart';

class FiltreWidget extends StatelessWidget {
  final int fillPercentage;

  const FiltreWidget({super.key, required this.fillPercentage});

  @override
  Widget build(BuildContext context) {
    double maxHeight = 400.h;
    double maxWidth = 150.h;
    double circular = 3.h;
    double padingg = 1.h;

    Color fillcolor;

    // Fill percentage'a göre renk belirleme
    if (fillPercentage <= 30) {
      fillcolor = Colors.green;
    } else if (fillPercentage <= 60) {
      fillcolor = Colors.blue;
    } else {
      fillcolor = Colors.red;
    }

    double actualHeight = maxHeight * (fillPercentage / 100);

    return Column(
      children: [
        Row(
          children: [
            BottomCard(
              header: AppLocalizations.of(context)!.filtreKirliligi,
              percentage: "  12.0%  ",
              value: StringHelper.shortenValue('$fillPercentage'),
              unit: "%",
              color: Colors.indigo,
            ),
            SizedBox(width: 20.h),
            Column(
              children: [
                Container(
                  height: maxHeight,
                  width: maxWidth,
                  padding: EdgeInsets.all(padingg),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(circular),
                  ),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: actualHeight,
                    width: maxWidth,
                    padding: EdgeInsets.all(padingg),
                    decoration: BoxDecoration(
                      color: fillcolor,
                      borderRadius: BorderRadius.circular(circular),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        if (fillPercentage > 60)
          Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: Column(
              children: [
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.h,
                  ),
                  decoration: BoxDecoration(
                    color: creamColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Filtre Bakım Zamanı",
                              textAlign: TextAlign
                                  .center, // Yazıyı ortalamak için textAlign özelliğini kullanıyoruz

                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 28.h,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
