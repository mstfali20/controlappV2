import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DamperKanat extends StatelessWidget {
  const DamperKanat({super.key, required this.fillPercentage});

  final double fillPercentage;

  @override
  Widget build(BuildContext context) {
    // Konteynerin maksimum yüksekliği
    double maxHeight = 50.h;
    double maxWidth = 150.h;
    double circular = 3.h;
    double padingg = 1.h;
    Color damperkanat = Colors.blue.withOpacity(0.6);

    // Doluluk yüzdesine göre gerçek yüksekliği hesaplayın
    double actualHeight = maxHeight * (fillPercentage / 80);

    return Row(
      children: [
        Column(
          children: [
            Container(
              height: maxHeight,
              width: maxWidth,
              padding: EdgeInsets.all(padingg),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(circular),
              ),
              alignment: Alignment.bottomCenter,
              child: Container(
                height: actualHeight,
                width: maxWidth,
                padding: EdgeInsets.all(padingg),
                decoration: BoxDecoration(
                  color: damperkanat,
                  borderRadius: BorderRadius.circular(circular),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [],
                ),
              ),
            ),
            Container(
              height: maxHeight,
              width: maxWidth,
              padding: EdgeInsets.all(padingg),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(circular),
              ),
              alignment: Alignment.bottomCenter,
              child: Container(
                height: actualHeight,
                width: maxWidth,
                padding: EdgeInsets.all(padingg),
                decoration: BoxDecoration(
                  color: damperkanat,
                  borderRadius: BorderRadius.circular(circular),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [],
                ),
              ),
            ),
            Container(
              height: maxHeight,
              width: maxWidth,
              padding: EdgeInsets.all(padingg),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(circular),
              ),
              alignment: Alignment.bottomCenter,
              child: Container(
                height: actualHeight,
                width: maxWidth,
                padding: EdgeInsets.all(padingg),
                decoration: BoxDecoration(
                  color: damperkanat,
                  borderRadius: BorderRadius.circular(circular),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
