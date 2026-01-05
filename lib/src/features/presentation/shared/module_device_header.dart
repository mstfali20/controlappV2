import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ModuleDeviceHeader extends StatelessWidget {
  const ModuleDeviceHeader({
    super.key,
    required this.moduleTitle,
    this.textAlign = TextAlign.left,
    this.moduleStyle,
    this.deviceStyle,
    this.spacing = 4,
  });

  final String moduleTitle;
  final TextAlign textAlign;
  final TextStyle? moduleStyle;
  final TextStyle? deviceStyle;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final effectiveModule =
        moduleTitle.isNotEmpty ? moduleTitle : 'Modül seçilmedi';

    final CrossAxisAlignment crossAxisAlignment;
    if (textAlign == TextAlign.right) {
      crossAxisAlignment = CrossAxisAlignment.end;
    } else if (textAlign == TextAlign.center) {
      crossAxisAlignment = CrossAxisAlignment.center;
    } else {
      crossAxisAlignment = CrossAxisAlignment.start;
    }

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          effectiveModule,
          textAlign: textAlign,
          style: moduleStyle ??
              TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
        ),
        SizedBox(height: spacing.h),
      ],
    );
  }
}
