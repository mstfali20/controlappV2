import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/src/core/di/injector.dart';
import 'package:controlapp/src/features/energy/presentation/view_model/energy_carbon_cubit.dart';
import 'package:controlapp/src/features/energy/presentation/view_model/energy_carbon_state.dart';

class CustomKarbonWidget extends StatelessWidget {
  const CustomKarbonWidget({
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
    this.gasDeviceId,
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
  final String? gasDeviceId;

  @override
  Widget build(BuildContext context) {
    final usernameValue =
        users.isNotEmpty ? users : userDataConst['username']?.toString() ?? '';
    final passwordValue =
        pass.isNotEmpty ? pass : userDataConst['password']?.toString() ?? '';

    return BlocProvider(
      create: (_) => EnergyCarbonCubit(fetchUseCase: getIt())
        ..load(
          username: usernameValue,
          password: passwordValue,
          consumptionDeviceId: deviceId,
          periodType: periodType,
          type: type,
          totalCheckPt: totalCheckPt,
          term: term,
          gasDeviceId: gasDeviceId,
        ),
      child: _CustomKarbonWidgetView(
        title: title,
        backgroundColor: backgroundColor,
        leading: leading,
        onTap: onTap,
        subtitle: subtitle,
      ),
    );
  }
}

class _CustomKarbonWidgetView extends StatelessWidget {
  const _CustomKarbonWidgetView({
    required this.title,
    required this.backgroundColor,
    required this.leading,
    required this.onTap,
    required this.subtitle,
  });

  final String title;
  final Color backgroundColor;
  final Widget leading;
  final VoidCallback onTap;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EnergyCarbonCubit, EnergyCarbonState>(
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
        final isLoading = state.loading && state.consumption == null;
        final formatter = NumberFormat('#,##0.00', 'tr_TR');
        final carbonValue = state.carbonEmissionTon ?? 0;
        final carbonText = '${formatter.format(carbonValue)} Ton';
        final consumptionLabel = state.consumption?.consumptionValue ?? '#';
        final gasAmount = _gasAmountLabel(state);
        final consumptionText = gasAmount != null
            ? '$subtitle $consumptionLabel + $gasAmount'
            : '$subtitle $consumptionLabel';

        return Container(
          margin: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              carbonText,
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
                    if (state.loading && state.consumption == null)
                      const CircularProgressIndicator(color: contolblue)
                    else
                      Expanded(
                        child: Text(
                          consumptionText,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
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

  String? _gasAmountLabel(EnergyCarbonState state) {
    final rawLabel = state.gasConsumption?.consumptionValue?.trim();
    if (rawLabel != null && rawLabel.isNotEmpty && rawLabel != '#') {
      return _normalizeGasValue(rawLabel);
    }

    final gasValue = state.gasValue;
    if (gasValue != null && gasValue > 0) {
      final formatter = NumberFormat('#,##0.##', 'tr_TR');
      final formatted = formatter.format(gasValue);
      return '$formatted m³';
    }
    return null;
  }

  String _normalizeGasValue(String label) {
    final normalized = label.toLowerCase();
    final hasUnit = normalized.contains('m3') || normalized.contains('m³');
    return hasUnit ? label : '$label m³';
  }
}
