import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTile extends StatelessWidget {
  const CustomTile({
    super.key,
    required this.dotColor,
    required this.title,
    required this.subtitle,
    required this.unit,
    required this.iconPath, // Parametre opsiyonel hale getirildi
  });

  final Color dotColor;
  final String title;
  final String subtitle;
  final String unit;
  final String iconPath; // Opsiyonel parametre

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          iconPath, // Dışardan gelen resmin yolu
          width: 30.h, // Resmin genişliği
          height: 30.h, // Resmin yüksekliği
        ),
        // Container(
        //   margin: const EdgeInsets.only(top: 8),
        //   height: 10,
        //   width: 10,
        //   decoration: BoxDecoration(
        //     color: dotColor,
        //     shape: BoxShape.circle,
        //   ),
        // ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
