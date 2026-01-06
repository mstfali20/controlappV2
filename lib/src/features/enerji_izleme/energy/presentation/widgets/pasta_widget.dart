import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/src/core/di/injector.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/presentation/view_model/energy_category_cubit.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/presentation/view_model/energy_category_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:pie_chart/pie_chart.dart';

class PastaWidget extends StatelessWidget {
  const PastaWidget({
    super.key,
    required this.organizationId,
    required this.periodId,
    required this.typeId,
    required this.excludeKey,
  });

  final String organizationId;
  final String periodId;
  final String typeId;
  final String excludeKey;

  @override
  Widget build(BuildContext context) {
    final usernameValue =
        users.isNotEmpty ? users : userDataConst['username']?.toString() ?? '';
    final passwordValue =
        pass.isNotEmpty ? pass : userDataConst['password']?.toString() ?? '';

    return BlocProvider(
      create: (_) => EnergyCategoryCubit(fetchUseCase: getIt())
        ..load(
          username: usernameValue,
          password: passwordValue,
          organizationId: organizationId,
          periodType: periodId,
          term: typeId,
        ),
      child: _PastaWidgetView(excludeKey: excludeKey),
    );
  }
}

class _PastaWidgetView extends StatelessWidget {
  const _PastaWidgetView({required this.excludeKey});

  final String excludeKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<EnergyCategoryCubit, EnergyCategoryState>(
      listener: (context, state) {
        if (state.error != null && !state.loading) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
        }
      },
      builder: (context, state) {
        if (state.loading && state.breakdown == null) {
          return const Center(
              child: CircularProgressIndicator(color: contolblue));
        }

        final breakdown = state.breakdown;
        final Map<String, double> filteredData = breakdown == null
            ? {}
            : Map<String, double>.fromEntries(
                breakdown.categories.entries.where(
                  (entry) =>
                      entry.value > 0 && entry.key.trim() != excludeKey.trim(),
                ),
              );

        if (filteredData.isEmpty) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.r),
              color: Colors.grey.shade200,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 64.r,
                  color: Colors.orange,
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.kategorigrafigi,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final total =
            filteredData.values.fold<double>(0, (acc, value) => acc + value);

        return Center(
          child: Container(
            width: screenWidth * 0.7,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PieChart(
                  dataMap: filteredData,
                  colorList: pieColorList.take(filteredData.length).toList(),
                  chartRadius: screenWidth / 1.2,
                  legendOptions: const LegendOptions(showLegends: false),
                  chartValuesOptions: ChartValuesOptions(
                    showChartValuesInPercentage: true,
                    showChartValuesOutside: true,
                    decimalPlaces: 2,
                    chartValueStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Column(
                  children: filteredData.entries.map((entry) {
                    final percentage =
                        total == 0 ? 0 : (entry.value / total) * 100;
                    final index = filteredData.keys.toList().indexOf(entry.key);

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        children: [
                          Container(
                            width: 20.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              color: pieColorList[index % pieColorList.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: contolblue,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
