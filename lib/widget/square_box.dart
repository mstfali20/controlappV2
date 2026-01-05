import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SquareBox extends StatelessWidget {
  final String imagePath;
  const SquareBox({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(10)),
      child: Image.asset(
        imagePath,
        fit: BoxFit.fill,

        height: 40.h,
        width: 40.h, // Resmin genişliği
      ),
    );
  }
}
