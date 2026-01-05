import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/src/core/di/injector.dart';
import 'package:controlapp/src/features/energy/domain/utils/currency_formatter.dart';
import 'package:controlapp/src/features/energy/presentation/view_model/energy_consumption_cubit.dart';
import 'package:controlapp/src/features/energy/presentation/view_model/energy_consumption_state.dart';

class CustomMainWidget extends StatelessWidget {
  const CustomMainWidget({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.leading,
    required this.onTap,
    required this.periodType,
    required this.deviceId,
    required this.term,
    required this.subtitle,
    this.type = '1',
    this.totalCheckPt = '0',
    this.consumptionValueFormatter,
  });

  final String title;
  final Color backgroundColor;
  final Widget leading;
  final VoidCallback onTap;
  final String periodType;
  final String deviceId;
  final String term;
  final String subtitle;
  final String type;
  final String totalCheckPt;
  final String Function(String rawValue)? consumptionValueFormatter;

  @override
  Widget build(BuildContext context) {
    final usernameValue =
        users.isNotEmpty ? users : userDataConst['username']?.toString() ?? '';
    final passwordValue =
        pass.isNotEmpty ? pass : userDataConst['password']?.toString() ?? '';

    return BlocProvider(
      create: (_) => EnergyConsumptionCubit(fetchUseCase: getIt())
        ..load(
          username: usernameValue,
          password: passwordValue,
          deviceId: deviceId,
          periodType: periodType,
          type: type,
          totalCheckPt: totalCheckPt,
          term: term,
        ),
      child: _CustomMainWidgetView(
        title: title,
        backgroundColor: backgroundColor,
        leading: leading,
        onTap: onTap,
        subtitle: subtitle,
        consumptionValueFormatter: consumptionValueFormatter,
      ),
    );
  }
}

class _CustomMainWidgetView extends StatelessWidget {
  const _CustomMainWidgetView({
    required this.title,
    required this.backgroundColor,
    required this.leading,
    required this.onTap,
    required this.subtitle,
    this.consumptionValueFormatter,
  });

  final String title;
  final Color backgroundColor;
  final Widget leading;
  final VoidCallback onTap;
  final String subtitle;
  final String Function(String rawValue)? consumptionValueFormatter;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EnergyConsumptionCubit, EnergyConsumptionState>(
      listener: (context, state) {
        if (state.error != null && !state.loading) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.error!),
              ),
            );
        }
      },
      builder: (context, state) {
        final isLoading = state.loading && state.data == null;
        final amount = state.data?.consumptionAmount ?? '#';
        final formattedAmount = CurrencyFormatter.formatLabel(amount);
        final value = state.data?.consumptionValue ?? '#';
        final displayValue =
            consumptionValueFormatter != null
                ? consumptionValueFormatter!(value)
                : value;

        return Container(
          margin: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(5.r),
              bottomRight: Radius.circular(5.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 70.w,
                        height: 70.h,
                        child: leading,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          if (isLoading)
                            const CircularProgressIndicator(color: contolblue)
                          else
                            Text(
                              formattedAmount,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 33.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (state.loading && state.data == null)
                      const CircularProgressIndicator(color: contolblue)
                    else
                      Expanded(
                        child: Text(
                          '$subtitle $displayValue',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.bar_chart_rounded,
                        size: 24.sp,
                        color: Colors.white,
                      ),
                      onPressed: onTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
