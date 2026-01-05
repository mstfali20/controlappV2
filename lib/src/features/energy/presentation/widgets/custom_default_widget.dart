import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CustomDefaultWidget extends StatelessWidget {
  const CustomDefaultWidget({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.leading,
    required this.subtitle,
    required this.value,
    this.unit,
    this.numberFormat = '#,##0',
    this.formattedValue,
  });

  final String title;
  final Color backgroundColor;
  final Widget leading;
  final String subtitle;
  final double value;
  final String? unit;
  final String numberFormat;
  final String? formattedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(child: leading),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  _buildValueLabel(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildValueLabel() {
    if (formattedValue != null && formattedValue!.isNotEmpty) {
      return '$subtitle $formattedValue';
    }
    final formatted = NumberFormat(numberFormat, 'tr_TR').format(value);
    final suffix = unit == null || unit!.isEmpty ? '' : ' ${unit!}';
    return '$subtitle $formatted$suffix';
  }
}
