import 'package:controlapp/const/Color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomCard extends StatefulWidget {
  final String header;
  final String percentage;
  final Color color;
  final String value;
  final String unit;
  final String? iconPath; // Opsiyonel parametre

  const BottomCard({
    super.key,
    required this.header,
    required this.percentage,
    required this.color,
    required this.value,
    required this.unit,
    this.iconPath, // Parametre opsiyonel hale getirildi
  });

  @override
  _BottomCardState createState() => _BottomCardState();
}

class _BottomCardState extends State<BottomCard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.iconPath != null) // Resim varsa göster
                  Image.asset(
                    widget.iconPath!, // Dışardan gelen resmin yolu
                    width: 30.h, // Resmin genişliği
                    height: 30.h, // Resmin yüksekliği
                  ),
                if (widget.iconPath != null)
                  const SizedBox(width: 8), // Resim varsa araya boşluk ekler
                Text(
                  widget.header,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.h,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
              ),
              decoration: BoxDecoration(
                color: creamColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 8.h),
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.value,
                            style: TextStyle(
                              fontSize: 25.h,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(
                            width: 12.h,
                          ),
                          Text(
                            widget.unit,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 25.h,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
