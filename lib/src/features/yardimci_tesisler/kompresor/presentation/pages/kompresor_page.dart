import 'package:controlapp/const/Color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KompresorPage extends StatelessWidget {
  const KompresorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Text(
            'Kompresor',
            style: TextStyle(
              fontSize: 18.h,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ),
    );
  }
}
