import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:controlapp/const/fade_zoom.dart';

class ProfileModuleTile extends StatelessWidget {
  const ProfileModuleTile({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.trailing,
    this.delay = 1.0,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Widget? trailing;
  final double delay;

  @override
  Widget build(BuildContext context) {
    final hasTrailing = trailing != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: FadeInAnimation(
        delay: delay,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: hasTrailing
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20.h, color: Colors.grey.shade800),
                  SizedBox(width: 10.h),
                  if (hasTrailing)
                    Expanded(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 16.h,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    )
                  else
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16.h,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  if (hasTrailing) trailing!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
