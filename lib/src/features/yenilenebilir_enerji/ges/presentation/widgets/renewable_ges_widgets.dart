import 'dart:math' as math;

import 'package:controlapp/const/Color.dart';
import 'package:controlapp/data/tree_node.dart';
import 'package:controlapp/src/features/yenilenebilir_enerji/ges/domain/renewable_history_period.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class RenewableGesLocationTabs extends StatelessWidget {
  const RenewableGesLocationTabs({
    super.key,
    required this.tabs,
    required this.activeTab,
    required this.onSelect,
  });

  final List<String> tabs;
  final String activeTab;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final label = tabs[index];
          final isSelected = label == activeTab;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected ? contolblue : Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: contolblue),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: contolblue.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : const [],
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : contolblue,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RenewablePeriodTabs extends StatelessWidget {
  const RenewablePeriodTabs({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onChange,
  });

  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (index) {
        final label = tabs[index];
        final isActive = index == activeIndex;
        return Padding(
          padding: EdgeInsets.only(right: index == tabs.length - 1 ? 0 : 8.w),
          child: GestureDetector(
            onTap: () => onChange(index),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isActive ? contolblue : Colors.transparent,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: contolblue),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : contolblue,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class RenewableSummaryRow extends StatelessWidget {
  const RenewableSummaryRow({
    super.key,
    required this.kwhLabel,
    required this.tlLabel,
  });

  final String kwhLabel;
  final String tlLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Toplam Enerji',
            value: '$kwhLabel kWh',
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _SummaryCard(
            label: 'Toplam Reçete',
            value: '$tlLabel TL',
          ),
        ),
      ],
    );
  }
}

class RenewableGesMetric {
  const RenewableGesMetric({
    required this.icon,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final String value;
  final String unit;
}

class RenewableGesCard extends StatelessWidget {
  const RenewableGesCard({
    super.key,
    required this.device,
    required this.value,
    required this.periodLabel,
    required this.productionLabel,
    required this.metrics,
    this.onTap,
  });

  final TreeNode device;
  final double? value;
  final String periodLabel;
  final String productionLabel;
  final List<RenewableGesMetric> metrics;
  final VoidCallback? onTap;

  static final _powerFormat = NumberFormat('#,##0.0', 'tr_TR');

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isFinite;
    final powerLabel = hasValue ? _powerFormat.format(value!) : '--';

    final body = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF35BA64), Color(0xFF47C86A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flash_on,
                  color: Colors.white,
                  size: 26.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.caption,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      periodLabel,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            '$powerLabel kW',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '$periodLabel PV Üretimi: ${this.productionLabel}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.sp,
            ),
          ),
          if (metrics.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: metrics.map((metric) {
                return Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          metric.icon,
                          color: Colors.white,
                          size: 18.r,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        metric.value,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        metric.unit,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
    if (onTap == null) {
      return body;
    }
    return GestureDetector(
      onTap: onTap,
      child: body,
    );
  }
}

class RenewableProductionChart extends StatelessWidget {
  const RenewableProductionChart({
    super.key,
    required this.values,
    required this.labels,
    required this.period,
    this.isLoading = false,
    this.barColor = const Color(0xFF35BA64),
  });

  final List<double> values;
  final List<String> labels;
  final RenewableHistoryPeriod period;
  final bool isLoading;
  final Color barColor;

  bool get _hasData => values.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final chartMax = _hasData ? values.reduce(math.max) * 1.2 : 1.0;
    final topValue = math.max(chartMax, 1.0);
    final verticalInterval = _calculateStep(topValue);
    final isToday = period == RenewableHistoryPeriod.today;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: barColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'GES üretim grafiği',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 190.h,
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: contolblue),
                  )
                : !_hasData
                    ? Center(
                        child: Text(
                          'Veri bulunamadı',
                          style: TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      )
                    : isToday
                        ? _buildLineChart(topValue, verticalInterval)
                        : _buildBarChart(topValue, verticalInterval),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(double maxY, double interval) {
    final spots = values
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.25),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              getTitlesWidget: (value, _) => Text(
                _axisFormatter.format(value),
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Text(
                    labels[index],
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            color: barColor,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [barColor.withOpacity(0.3), barColor.withOpacity(0.1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            getTooltipItems: (touchedSpots) {
              return touchedSpots
                  .map((spot) {
                    final index = spot.x.toInt();
                    if ((spot.x - index).abs() > 0.001 ||
                        index < 0 ||
                        index >= labels.length) {
                      return null;
                    }
                    final label = labels[index];
                    final valueLabel =
                        NumberFormat('#,##0.0', 'tr_TR').format(spot.y);
                    return LineTooltipItem(
                      '$label\n$valueLabel kW',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  })
                  .whereType<LineTooltipItem>()
                  .toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(double maxY, double interval) {
    final barGroups = values.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            width: 18,
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [barColor.withOpacity(0.6), barColor],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              getTitlesWidget: (value, _) => Text(
                _axisFormatter.format(value),
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    labels[index],
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = group.x.toInt() >= 0 && group.x.toInt() < labels.length
                  ? labels[group.x.toInt()]
                  : '';
              return BarTooltipItem(
                '$label\n${NumberFormat('#,##0.0', 'tr_TR').format(rod.toY)} kW',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

final NumberFormat _axisFormatter = NumberFormat('#,##0', 'tr_TR');

double _calculateStep(double maxValue) {
  if (maxValue <= 0) {
    return 1.0;
  }
  final roughStep = maxValue / 5;
  if (roughStep <= 1) {
    return 1.0;
  }
  final exponent = math.pow(10, (math.log(roughStep) / math.ln10).floor()).toDouble();
  final normalized = roughStep / exponent;
  double stepUnit;
  if (normalized < 1.5) {
    stepUnit = 1.0;
  } else if (normalized < 3) {
    stepUnit = 2.0;
  } else if (normalized < 7) {
    stepUnit = 5.0;
  } else {
    stepUnit = 10.0;
  }
  return (stepUnit * exponent).toDouble();
}
