import 'package:controlapp/const/Color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VeriCardEnerjy {
  final String header;
  final String percentage;
  final Color color;
  final String value;
  final String unit;
  final String title;
  final String? iconPath; // Opsiyonel parametre

  const VeriCardEnerjy({
    required this.header,
    required this.percentage,
    required this.color,
    required this.value,
    required this.unit,
    required this.title,
    this.iconPath,
  });
}

class VeriCardEnerjyList extends StatelessWidget {
  final String title;
  final List<VeriCardEnerjy> veriCardDataList;
  final bool showIconButton;
  final VoidCallback? onPressed;

  const VeriCardEnerjyList({
    super.key,
    required this.title,
    required this.veriCardDataList,
    this.showIconButton = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2.0.h),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: veriCardDataList.map((data) {
                return VeriCard(
                  header: data.header,
                  percentage: data.percentage,
                  color: data.color,
                  value: data.value,
                  unit: data.unit,
                  iconPath: data.iconPath,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class VeriCard extends StatelessWidget {
  final String header;
  final String percentage;
  final Color color;
  final String value;
  final String unit;
  final String? iconPath; // Opsiyonel parametre

  const VeriCard({
    super.key,
    required this.header,
    required this.percentage,
    required this.color,
    required this.value,
    required this.unit,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.h),
          decoration: BoxDecoration(
            color:
                creamColor, // Örneğin buraya creamColor yerine orange renk ekledim
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (iconPath != null) // Resim varsa göster
                          Image.asset(
                            iconPath!, // Dışardan gelen resmin yolu
                            width: 30.h, // Resmin genişliği
                            height: 30.h, // Resmin yüksekliği
                          ),
                        const SizedBox(width: 8),
                        Text(
                          header,
                          style: TextStyle(
                            fontSize: 19.h,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 19.h,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(
                          width: 15.h,
                        ),
                        Text(
                          unit,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 19.h,
                          ),
                        ),
                      ],
                    )
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
