import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:controlapp/const/fade_zoom.dart';

class ProfileModuleTile extends StatelessWidget {
  const ProfileModuleTile({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.delay = 1.0,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final double delay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FadeInAnimation(
        delay: delay,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
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
                    Icon(icon),
                    SizedBox(width: 10.h),
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
