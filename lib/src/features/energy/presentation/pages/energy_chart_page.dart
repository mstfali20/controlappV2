import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart' as legacy_data;
import 'package:controlapp/src/features/energy/data/services/consumption_service.dart';
import 'package:controlapp/data/garfikModel.dart';
import 'package:controlapp/src/core/di/injector.dart';
import 'package:controlapp/src/features/energy/domain/entities/energy_consumption_record.dart';
import 'package:controlapp/src/features/energy/domain/utils/energy_value_parser.dart';
import 'package:controlapp/src/features/energy/presentation/view_model/energy_history_cubit.dart';
import 'package:controlapp/src/features/energy/presentation/widgets/custom_default_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class GrafikPage extends StatefulWidget {
  const GrafikPage({
    super.key,
    required this.barColor,
    required this.title,
    required this.deviceId,
    required this.subtitle,
    required this.birimValue,
    required this.degerValue,
    required this.periodIndex,
  });

  final Color barColor;
  final String title;
  final String subtitle;
  final String deviceId;
  final String birimValue;
  final String degerValue;
  final String periodIndex;

  @override
  State<GrafikPage> createState() => _GrafikPageState();
}

enum EnergyHistoryPeriod { today, daily, monthly, yearly }

enum EnergyHistoryMetric { consumption, amount }

class _GrafikPageState extends State<GrafikPage> {
  late final EnergyHistoryCubit _historyCubit;
  late final String _username;
  late final String _password;
  final ConsumptionService _legacyConsumptionService = ConsumptionService();

  final Map<EnergyHistoryPeriod, List<EnergyConsumptionRecord>> _historyCache =
      {};

  EnergyHistoryPeriod _selectedPeriod = EnergyHistoryPeriod.today;
  EnergyHistoryMetric _selectedMetric = EnergyHistoryMetric.consumption;
  bool _isLoading = false;

  final ScrollController _chartScrollController = ScrollController();
  double? _lastScheduledChartWidth;
  double? _lastScheduledViewportWidth;
  int? _lastScheduledPointCount;
  EnergyHistoryPeriod? _lastScheduledPeriod;
  EnergyHistoryMetric? _lastScheduledMetric;
  double? _lastAppliedScrollOffset;

  String _activeUnitLabel = '';
  String Function(double value) _valueFormatter = _defaultValueFormatter;
  String Function(double value) _axisFormatter = _defaultAxisFormatter;

  static final NumberFormat _defaultValueNumberFormat =
      NumberFormat('#,##0', 'tr_TR');
  static final NumberFormat _defaultAxisNumberFormat =
      NumberFormat('#,##0', 'tr_TR');

  static String _defaultValueFormatter(double value) =>
      _defaultValueNumberFormat.format(value);

  static String _defaultAxisFormatter(double value) =>
      _defaultAxisNumberFormat.format(value);

  static const _historyType = '0';
  static const _totalCheckPoint = '1';
  static const _term = '1';

  @override
  void initState() {
    super.initState();
    _historyCubit = EnergyHistoryCubit(fetchUseCase: getIt());
    _username = legacy_data.users.isNotEmpty
        ? legacy_data.users
        : legacy_data.userDataConst['username']?.toString() ?? '';
    _password = legacy_data.pass.isNotEmpty
        ? legacy_data.pass
        : legacy_data.userDataConst['password']?.toString() ?? '';
    final preferredPeriod = _periodFromType(widget.periodIndex);
    _selectedPeriod = EnergyHistoryPeriod.today;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadHistoryFor(_selectedPeriod, force: true);
      if (!mounted) {
        return;
      }
      final preloadOrder = <EnergyHistoryPeriod>{
        preferredPeriod,
        ...EnergyHistoryPeriod.values,
      }..remove(_selectedPeriod);

      for (final period in preloadOrder) {
        unawaited(_loadHistoryFor(period, silent: true));
      }
    });
  }

  @override
  void dispose() {
    _chartScrollController.dispose();
    _historyCubit.close();
    super.dispose();
  }

  Future<void> _loadHistoryFor(
    EnergyHistoryPeriod period, {
    bool force = false,
    bool silent = false,
  }) async {
    if (!force && _historyCache.containsKey(period)) {
      return;
    }

    if (period == EnergyHistoryPeriod.yearly) {
      await _loadYearlyHistory(force: force, silent: silent);
      return;
    }

    if (!silent) {
      setState(() => _isLoading = true);
    }

    final range = _dateRangeFor(period);
    if (period == EnergyHistoryPeriod.today) {
      log(
        'Loading today history: start=${range.start.toIso8601String()} end=${range.end.toIso8601String()} periodType=${_periodType(period)} device=${widget.deviceId}',
      );
    }
    final history = await _historyCubit.load(
      username: _username,
      password: _password,
      deviceId: widget.deviceId,
      periodType: _periodType(period),
      type: _historyType,
      totalCheckPt: _totalCheckPoint,
      term: _term,
      startDate: _formatDate(range.start),
      endDate: _formatDate(range.end),
    );

    if (!mounted) {
      return;
    }

    if (!silent) {
      setState(() => _isLoading = false);
    }

    if (history != null && history.isSuccess) {
      final filtered = _filterRecords(history.records);
      setState(() {
        _historyCache[period] = filtered;
      });
    } else if (!silent) {
      final l10n = AppLocalizations.of(context);
      final message = history?.errorDescription ??
          l10n?.veriAlmaHata ??
          'Veriler alınamadı.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  List<EnergyConsumptionRecord> _recordsFor(EnergyHistoryPeriod period) {
    return _historyCache[period] ?? const [];
  }

  List<EnergyConsumptionRecord> _filterRecords(
    List<EnergyConsumptionRecord> records,
  ) {
    return records
        .where((record) => record.value > 0 || record.amount > 0)
        .toList();
  }

  Future<void> _loadYearlyHistory({
    bool force = false,
    bool silent = false,
  }) async {
    if (!force && _historyCache.containsKey(EnergyHistoryPeriod.yearly)) {
      return;
    }

    if (!silent) {
      setState(() => _isLoading = true);
    }

    try {
      final range = _dateRangeFor(EnergyHistoryPeriod.yearly);
      final legacyData = await _legacyConsumptionService.fetchConsumptionData(
        username: _username,
        password: _password,
        periodType: '4',
        deviceId: widget.deviceId,
        type: _historyType,
        totalCheckPt: _totalCheckPoint,
        term: _term,
        startDate: _formatDate(range.start),
        endDate: _formatDate(range.end),
      );

      final records = _filterRecords(_mapLegacyHistoryToRecords(legacyData));
      setState(() {
        _historyCache[EnergyHistoryPeriod.yearly] = records;
        _isLoading = false;
      });
    } catch (error) {
      if (!silent) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context);
        final message = l10n?.veriAlmaHata ?? 'Veriler alınamadı.';
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  List<EnergyConsumptionRecord> _mapLegacyHistoryToRecords(
    List<HistoryGrafikData> legacyData,
  ) {
    final records = <EnergyConsumptionRecord>[];
    for (final item in legacyData) {
      final timestamp = _parseLegacyTimestamp(item.dateTime);
      if (timestamp == null) {
        continue;
      }
      final valueLabel = item.consumptionValue;
      final amountLabel = item.consumptionAmount;
      records.add(
        EnergyConsumptionRecord(
          timestamp: timestamp,
          valueLabel: valueLabel,
          amountLabel: amountLabel,
          value: EnergyValueParser.parse(valueLabel),
          amount: EnergyValueParser.parse(amountLabel),
        ),
      );
    }

    records.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return records;
  }

  DateTime? _parseLegacyTimestamp(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(trimmed);
    } catch (_) {
      if (RegExp(r'^\d{4}$').hasMatch(trimmed)) {
        final year = int.tryParse(trimmed);
        if (year != null) {
          return DateTime(year);
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final records = _recordsFor(_selectedPeriod);
    final rawSeries = _buildSeries(_selectedPeriod, records, l10n);
    final rawTotal = _totalForSelectedMetric(records);

    final scaling = _selectedMetric == EnergyHistoryMetric.amount
        ? _determineAmountScaling(rawSeries.values, rawTotal)
        : _determineConsumptionScaling(rawSeries.values, rawTotal);

    final series = _ChartSeries(
      labels: rawSeries.labels,
      values: scaling.applyToValues(rawSeries.values),
    );
    final totalValue = scaling.applyToTotal(rawTotal);
    _activeUnitLabel = scaling.unitLabel;
    _valueFormatter = scaling.valueFormatterFor();
    _axisFormatter = scaling.axisFormatterFor(
      series.maxValue,
    );

    final formattedTotal = '${_valueFormatter(totalValue)} ${_activeUnitLabel}';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildPeriodSelector(l10n),
              SizedBox(height: 5.h),
              Align(
                alignment: Alignment.centerRight,
                child: _buildMetricSelector(),
              ),
              SizedBox(height: 5.h),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16.w),
                  child: _isLoading && series.labels.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(color: contolblue),
                        )
                      : _buildChartSection(
                          series,
                          l10n,
                          _activeUnitLabel,
                        ),
                ),
              ),
              SizedBox(height: 2.h),
              Flexible(
                flex: 0,
                child: CustomDefaultWidget(
                  title: widget.title,
                  subtitle: 'Toplam:',
                  backgroundColor: widget.barColor,
                  leading: Image.asset('assets/icons/kwh.png'),
                  value: totalValue,
                  unit: _activeUnitLabel,
                  numberFormat: scaling.numberPattern,
                  formattedValue: formattedTotal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.all(14.h),
            foregroundColor: Colors.black,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Icon(Iconsax.arrow_left),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(AppLocalizations l10n) {
    return Center(
      child: Wrap(
        spacing: 12.w,
        runSpacing: 8.h,
        children: EnergyHistoryPeriod.values.map((period) {
          final isSelected = _selectedPeriod == period;
          return GestureDetector(
            onTap: () {
              if (_selectedPeriod == period) {
                return;
              }
              setState(() => _selectedPeriod = period);
              _loadHistoryFor(period);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: 18.w,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                color: isSelected ? contolblue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(40.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: contolblue.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : const [],
              ),
              child: Text(
                _periodLabel(period, l10n),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricSelector() {
    return Wrap(
      spacing: 10.w,
      children: [
        ChoiceChip(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          label: Text(widget.birimValue),
          selected: _selectedMetric == EnergyHistoryMetric.consumption,
          selectedColor: contolblue,
          backgroundColor: Colors.grey.shade200,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(48)),
          ),
          labelStyle: TextStyle(
            color: _selectedMetric == EnergyHistoryMetric.consumption
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedMetric = EnergyHistoryMetric.consumption);
            }
          },
        ),
        ChoiceChip(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          label: Text(widget.degerValue),
          selected: _selectedMetric == EnergyHistoryMetric.amount,
          selectedColor: contolblue,
          backgroundColor: Colors.grey.shade200,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(48)),
          ),
          labelStyle: TextStyle(
            color: _selectedMetric == EnergyHistoryMetric.amount
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedMetric = EnergyHistoryMetric.amount);
            }
          },
        ),
      ],
    );
  }

  void _scheduleChartScroll(
    double chartWidth,
    double viewportWidth,
    int pointCount,
  ) {
    if (viewportWidth <= 0) {
      return;
    }

    final shouldSchedule = _lastScheduledChartWidth != chartWidth ||
        _lastScheduledViewportWidth != viewportWidth ||
        _lastScheduledPointCount != pointCount ||
        _lastScheduledPeriod != _selectedPeriod ||
        _lastScheduledMetric != _selectedMetric;

    if (!shouldSchedule) {
      return;
    }

    _lastScheduledChartWidth = chartWidth;
    _lastScheduledViewportWidth = viewportWidth;
    _lastScheduledPointCount = pointCount;
    _lastScheduledPeriod = _selectedPeriod;
    _lastScheduledMetric = _selectedMetric;

    final targetOffset =
        chartWidth <= viewportWidth ? 0.0 : chartWidth - viewportWidth;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_chartScrollController.hasClients) {
        return;
      }
      final maxExtent = _chartScrollController.position.maxScrollExtent;
      final clampedOffset = targetOffset.clamp(0.0, maxExtent);
      if (_lastAppliedScrollOffset == null ||
          (clampedOffset - _lastAppliedScrollOffset!).abs() > 1.0) {
        _chartScrollController.jumpTo(clampedOffset);
        _lastAppliedScrollOffset = clampedOffset;
      }
    });
  }

  Widget _buildChartSection(
    _ChartSeries series,
    AppLocalizations l10n,
    String unitLabel,
  ) {
    if (series.labels.isEmpty) {
      return Center(
        child: Text(
          l10n.altVeriBulunamadi,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      );
    }

    final chartTitle =
        '${_periodLabel(_selectedPeriod, l10n)} ${widget.subtitle}';
    final isToday = _selectedPeriod == EnergyHistoryPeriod.today;
    final baseWidth = isToday ? 55.0 : 70.0;
    final chartWidth = math.max(series.labels.length * baseWidth, 320.0);
    final availableHeight = MediaQuery.of(context).size.height;
    final chartHeight = math.min(availableHeight * 0.40, 400.h);

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        _scheduleChartScroll(chartWidth, viewportWidth, series.labels.length);
        final availableHeight = MediaQuery.of(context).size.height;
        final chartHeight = math.min(availableHeight * 0.40, 400.h);

        return SingleChildScrollView(
          controller: _chartScrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chartTitle,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30.h),
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: widget.barColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: chartHeight,
                  child: isToday
                      ? LineChart(
                          _buildLineChartData(series, unitLabel),
                          duration: const Duration(milliseconds: 350),
                        )
                      : BarChart(
                          _buildChartData(series, unitLabel),
                          duration: const Duration(milliseconds: 350),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  BarChartData _buildChartData(
    _ChartSeries series,
    String unitLabel,
  ) {
    final maxValue = series.maxValue <= 0 ? 10.0 : series.maxValue * 1.2;
    final step = _calculateStep(maxValue);
    final now = DateTime.now();

    final barGroups = List.generate(series.labels.length, (index) {
      final value = math.max(series.values[index], 0).toDouble();
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            width: 22,
            gradient: LinearGradient(
              colors: [
                widget.barColor.withOpacity(0.4),
                widget.barColor,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      );
    });

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxValue,
      minY: 0,
      gridData: FlGridData(
        show: true,
        horizontalInterval: step,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.2),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: barGroups,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final label = _selectedPeriod == EnergyHistoryPeriod.daily
                ? DateFormat('dd.MM.yyyy').format(
                    DateTime(now.year, now.month, group.x.toInt() + 1),
                  )
                : series.labels[group.x.toInt()];
            final valueLabel = _valueFormatter(rod.toY);
            return BarTooltipItem(
              '$label\n$valueLabel $unitLabel',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 70,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= series.labels.length) {
                return const SizedBox.shrink();
              }

              final valueLabel = _valueFormatter(series.values[index]);

              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedPeriod == EnergyHistoryPeriod.daily
                          ? DateFormat('dd.MM')
                              .format(DateTime(now.year, now.month, index + 1))
                          : series.labels[index],
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Transform.rotate(
                      angle: -math.pi / 4,
                      child: Text(
                        '$valueLabel $unitLabel',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          shadows: const [
                            Shadow(
                              offset: Offset(0.5, 0.5),
                              blurRadius: 1,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 56,
            getTitlesWidget: (value, meta) {
              if (value < 0 || (value % step).abs() > step * 0.1) {
                return const SizedBox.shrink();
              }
              final label = _formatAxisTick(value.toDouble());
              return Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  LineChartData _buildLineChartData(
    _ChartSeries series,
    String unitLabel,
  ) {
    final adjustedMax = series.maxValue <= 0 ? 1.0 : series.maxValue * 1.2;
    final minSeriesValue = series.values.isEmpty
        ? 0.0
        : series.values.reduce((a, b) => math.min(a, b));
    final double baseline = minSeriesValue <= 0
        ? 0.0
        : math.min(minSeriesValue * 0.9, adjustedMax * 0.9);
    final step = _calculateStep(adjustedMax);
    final stride = _lineLabelStride(series.labels.length);

    final spots = List.generate(series.values.length, (index) {
      final value = math.max(series.values[index], 0).toDouble();
      return FlSpot(index.toDouble(), value);
    });

    return LineChartData(
      minX: 0,
      maxX: spots.isEmpty ? 1 : spots.last.x,
      minY: baseline,
      maxY: adjustedMax,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        horizontalInterval: step,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.18),
          strokeWidth: 1,
          dashArray: const [6, 6],
        ),
        drawVerticalLine: false,
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 56,
            getTitlesWidget: (value, meta) {
              if (value < 0 || !_isMultipleOf(value, step)) {
                return const SizedBox.shrink();
              }
              final label = _formatAxisTick(value);
              return Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if ((value - index).abs() > 0.001 ||
                  index < 0 ||
                  index >= series.labels.length) {
                return const SizedBox.shrink();
              }

              if (index % stride != 0 && index != series.labels.length - 1) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Text(
                  series.labels[index],
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => Colors.black87,
          getTooltipItems: (touchedSpots) {
            return touchedSpots
                .map((barSpot) {
                  final index = barSpot.x.toInt();
                  if ((barSpot.x - index).abs() > 0.001 ||
                      index < 0 ||
                      index >= series.labels.length) {
                    return null;
                  }
                  final label = series.labels[index];
                  final valueLabel = _valueFormatter(barSpot.y);
                  return LineTooltipItem(
                    '$label\n$valueLabel $unitLabel',
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
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 5,
          isStrokeCapRound: true,
          gradient: LinearGradient(
            colors: [
              widget.barColor.withOpacity(0.2),
              widget.barColor,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final isLast = index == spots.length - 1;
              return FlDotCirclePainter(
                radius: isLast ? 5 : 3.5,
                color: Colors.white,
                strokeWidth: isLast ? 3 : 2,
                strokeColor: widget.barColor,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                widget.barColor.withOpacity(0.28),
                widget.barColor.withOpacity(0.06),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            cutOffY: 0,
            applyCutOffY: true,
          ),
          shadow: Shadow(
            color: widget.barColor.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ),
      ],
    );
  }

  _ChartSeries _buildSeries(
    EnergyHistoryPeriod period,
    List<EnergyConsumptionRecord> records,
    AppLocalizations l10n,
  ) {
    switch (period) {
      case EnergyHistoryPeriod.today:
        return _buildTodaySeries(records);
      case EnergyHistoryPeriod.daily:
        return _buildDailySeries(records);
      case EnergyHistoryPeriod.monthly:
        return _buildMonthlySeries(records, l10n);
      case EnergyHistoryPeriod.yearly:
        return _buildYearlySeries(records);
    }
  }

  _ChartSeries _buildTodaySeries(List<EnergyConsumptionRecord> records) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final labels = List<String>.generate(24, (index) {
      final hour = startOfDay.add(Duration(hours: index));
      return DateFormat('HH:mm').format(hour);
    });
    final values = List<double>.filled(24, 0);

    for (final record in records) {
      if (record.timestamp.year == now.year &&
          record.timestamp.month == now.month &&
          record.timestamp.day == now.day &&
          !record.timestamp.isAfter(now)) {
        final hourIndex = record.timestamp.hour;
        if (hourIndex >= 0 && hourIndex < values.length) {
          values[hourIndex] += math.max(_metricValue(record), 0);
        }
      }
    }

    final visibleCount = math.min(now.hour + 1, values.length);
    final trimmedCount = math.max(visibleCount, 1);
    final visibleLabels = labels.sublist(0, trimmedCount);
    final visibleValues = List<double>.from(values.sublist(0, trimmedCount));

    if (visibleValues.isNotEmpty) {
      final lastIndex = visibleValues.length - 1;
      if (visibleValues[lastIndex] == 0) {
        final lastKnown = visibleValues.lastWhere(
          (value) => value > 0,
          orElse: () => 0,
        );
        if (lastKnown > 0) {
          visibleValues[lastIndex] = lastKnown;
        }
      }
    }

    return _ChartSeries(labels: visibleLabels, values: visibleValues);
  }

  _ChartSeries _buildDailySeries(List<EnergyConsumptionRecord> records) {
    final now = DateTime.now();
    final visibleDays = now.day;
    final labels =
        List<String>.generate(visibleDays, (index) => '${index + 1}');
    final values = List<double>.filled(visibleDays, 0);

    for (final record in records) {
      if (record.timestamp.year == now.year &&
          record.timestamp.month == now.month) {
        final dayIndex = record.timestamp.day - 1;
        if (dayIndex >= 0 && dayIndex < values.length) {
          values[dayIndex] += math.max(_metricValue(record), 0);
        }
      }
    }

    return _ChartSeries(labels: labels, values: values);
  }

  _ChartSeries _buildMonthlySeries(
    List<EnergyConsumptionRecord> records,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();
    final monthLabels = [
      l10n.ocak,
      l10n.subat,
      l10n.mart,
      l10n.nisan,
      l10n.mayis,
      l10n.haziran,
      l10n.temmuz,
      l10n.agustos,
      l10n.eylul,
      l10n.ekim,
      l10n.kasim,
      l10n.aralik,
    ];

    final values = List<double>.filled(now.month, 0);
    for (final record in records) {
      if (record.timestamp.year == now.year) {
        final monthIndex = record.timestamp.month - 1;
        if (monthIndex >= 0 && monthIndex < values.length) {
          values[monthIndex] += math.max(_metricValue(record), 0);
        }
      }
    }

    return _ChartSeries(
      labels: monthLabels.sublist(0, values.length),
      values: values,
    );
  }

  _ChartSeries _buildYearlySeries(List<EnergyConsumptionRecord> records) {
    final Map<int, double> accumulator = {};
    for (final record in records) {
      final year = record.timestamp.year;
      accumulator[year] =
          (accumulator[year] ?? 0) + math.max(_metricValue(record), 0);
    }

    if (accumulator.isEmpty) {
      final currentYear = DateTime.now().year;
      return _ChartSeries(labels: [currentYear.toString()], values: [0]);
    }

    final sortedYears = accumulator.keys.toList()..sort();
    final labels = sortedYears.map((year) => year.toString()).toList();
    final values = sortedYears.map((year) => accumulator[year]!).toList();

    return _ChartSeries(labels: labels, values: values);
  }

  double _metricValue(EnergyConsumptionRecord record) {
    if (_selectedMetric == EnergyHistoryMetric.amount) {
      return record.amount;
    }
    return record.value;
  }

  double _totalForSelectedMetric(List<EnergyConsumptionRecord> records) {
    return records.fold<double>(
      0,
      (previousValue, element) =>
          previousValue + math.max(_metricValue(element), 0),
    );
  }

  _MetricScaling _determineConsumptionScaling(
    List<double> values,
    double total,
  ) {
    final normalizedUnit = widget.birimValue.trim().toLowerCase();
    final isDaily = _selectedPeriod == EnergyHistoryPeriod.today ||
        _selectedPeriod == EnergyHistoryPeriod.daily;
    final magnitudes = <double>[...values, total]
        .where((value) => value.isFinite)
        .map((value) => value.abs())
        .toList();
    final maxMagnitude = magnitudes.isEmpty ? 0 : magnitudes.reduce(math.max);

    if (normalizedUnit.contains('m3') || normalizedUnit.contains('m³')) {
      var scaleFactor = 1.0;
      var unitLabel = widget.birimValue;

      if (isDaily) {
        if (maxMagnitude >= 1000) {
          final rawTier = (math.log(maxMagnitude) / math.ln10).floor() ~/ 3;
          final tier = rawTier.clamp(0, 3) as int;
          scaleFactor = 1 / math.pow(10, tier * 3);
        }
      } else {
        if (maxMagnitude >= 1e12) {
          scaleFactor = 1 / 1e9;
        } else if (maxMagnitude >= 1e9) {
          scaleFactor = 1 / 1e6;
        } else if (maxMagnitude >= 1e6) {
          scaleFactor = 1 / 1e3;
        }
        if (scaleFactor < 1) {
          unitLabel = unitLabel.replaceAll('m3', 'ton').replaceAll('m³', 'ton');
        }
      }

      final scaledMax = maxMagnitude * scaleFactor;
      final pattern = scaledMax < 1
          ? '#,##0.###'
          : scaledMax < 100
              ? '#,##0.#'
              : '#,##0';

      int maxFractionDigits;
      switch (pattern) {
        case '#,##0.###':
          maxFractionDigits = 3;
          break;
        case '#,##0.#':
          maxFractionDigits = 1;
          break;
        default:
          maxFractionDigits = 0;
      }

      final shouldFloor = !isDaily && scaleFactor < 1 && scaledMax >= 10;

      return _MetricScaling(
        unitLabel: unitLabel,
        scaleFactor: scaleFactor,
        numberPattern: pattern,
        minFractionDigits: 0,
        maxFractionDigits: maxFractionDigits,
        roundDown: shouldFloor,
      );
    }

    final isKwhUnit = normalizedUnit.contains('kwh');
    final needsFinePrecision = maxMagnitude < 10;

    if (isKwhUnit && maxMagnitude >= 1e6) {
      return _MetricScaling(
        unitLabel: 'MWh',
        scaleFactor: 1 / 1000,
        numberPattern: '#,##0',
        minFractionDigits: 0,
        maxFractionDigits: 0,
        roundDown: true,
      );
    }

    if (isKwhUnit) {
      return _MetricScaling(
        unitLabel: widget.birimValue,
        scaleFactor: 1.0,
        numberPattern: '#,##0',
        minFractionDigits: 0,
        maxFractionDigits: 0,
        roundDown: true,
      );
    }

    return _MetricScaling(
      unitLabel: widget.birimValue,
      scaleFactor: 1 / 1000,
      numberPattern: '#,##0',
      minFractionDigits: 0,
      maxFractionDigits: 0,
      roundDown: true,
    );
  }

  _MetricScaling _determineAmountScaling(
    List<double> values,
    double total,
  ) {
    // Monetary values are displayed without kuruş so we floor to whole TL.
    return _MetricScaling(
      unitLabel: widget.degerValue,
      scaleFactor: 1.0,
      numberPattern: '#,##0',
      minFractionDigits: 0,
      maxFractionDigits: 0,
      roundDown: true,
    );
  }

  String _periodLabel(EnergyHistoryPeriod period, AppLocalizations l10n) {
    switch (period) {
      case EnergyHistoryPeriod.today:
        return l10n.bugun;
      case EnergyHistoryPeriod.daily:
        return l10n.gunluk;
      case EnergyHistoryPeriod.monthly:
        return l10n.aylik;
      case EnergyHistoryPeriod.yearly:
        return l10n.yillik;
    }
  }

  String _periodType(EnergyHistoryPeriod period) {
    switch (period) {
      case EnergyHistoryPeriod.today:
        return '0';
      case EnergyHistoryPeriod.daily:
        return '1';
      case EnergyHistoryPeriod.monthly:
        return '3';
      case EnergyHistoryPeriod.yearly:
        return '4';
    }
  }

  EnergyHistoryPeriod _periodFromType(String periodType) {
    switch (periodType) {
      case '0':
        return EnergyHistoryPeriod.today;
      case '3':
        return EnergyHistoryPeriod.monthly;
      case '4':
        return EnergyHistoryPeriod.yearly;
      case '1':
      default:
        return EnergyHistoryPeriod.daily;
    }
  }

  _DateRange _dateRangeFor(EnergyHistoryPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case EnergyHistoryPeriod.today:
        final start = DateTime(now.year, now.month, now.day);
        final end = start.add(const Duration(days: 1));
        return _DateRange(start, end);
      case EnergyHistoryPeriod.daily:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        return _DateRange(start, end);
      case EnergyHistoryPeriod.monthly:
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        return _DateRange(start, end);
      case EnergyHistoryPeriod.yearly:
        final start = DateTime(now.year - 5, 1, 1);
        final end = DateTime(now.year + 5, 12, 31);
        return _DateRange(start, end);
    }
  }

  double _calculateStep(double maxValue) {
    if (maxValue <= 0) {
      return 1.0;
    }

    final roughStep = maxValue / 5;
    if (roughStep <= 1) {
      return 1.0;
    }

    final exponent =
        math.pow(10, (math.log(roughStep) / math.ln10).floor()).toDouble();
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

  String _formatAxisTick(double value) => _axisFormatter(value);

  int _lineLabelStride(int totalPoints) {
    if (totalPoints <= 6) {
      return 1;
    }
    if (totalPoints <= 12) {
      return 2;
    }
    return 3;
  }

  bool _isMultipleOf(double value, double step) {
    if (step == 0) {
      return value == 0;
    }
    final ratio = value / step;
    return (ratio - ratio.round()).abs() < 0.05;
  }

  static String _formatDate(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date.toLocal());
}

class _MetricScaling {
  _MetricScaling({
    required this.unitLabel,
    this.scaleFactor = 1.0,
    this.numberPattern = '#,##0',
    this.minFractionDigits,
    this.maxFractionDigits,
    this.roundDown = false,
    this.maxIntegerGroups,
    this.trailingZeroCount = 0,
  }) : _numberFormatter = NumberFormat(numberPattern, 'tr_TR') {
    if (minFractionDigits != null) {
      _numberFormatter.minimumFractionDigits = minFractionDigits!;
    }
    if (maxFractionDigits != null) {
      _numberFormatter.maximumFractionDigits = maxFractionDigits!;
    }
  }

  factory _MetricScaling.identity({
    required String unitLabel,
    String valuePattern = '#,##0',
    int? minFractionDigits,
    int? maxFractionDigits,
    bool roundDown = false,
    int? maxIntegerGroups,
    int trailingZeroCount = 0,
  }) {
    return _MetricScaling(
      unitLabel: unitLabel,
      scaleFactor: 1.0,
      numberPattern: valuePattern,
      minFractionDigits: minFractionDigits,
      maxFractionDigits: maxFractionDigits,
      roundDown: roundDown,
      maxIntegerGroups: maxIntegerGroups,
      trailingZeroCount: trailingZeroCount,
    );
  }

  final String unitLabel;
  final double scaleFactor;
  final String numberPattern;
  final int? minFractionDigits;
  final int? maxFractionDigits;
  final bool roundDown;
  final int? maxIntegerGroups;
  final int trailingZeroCount;

  final NumberFormat _numberFormatter;

  List<double> applyToValues(List<double> values) => values.map(scale).toList();

  double applyToTotal(double total) => scale(total);

  String Function(double) valueFormatterFor() => (scaledValue) {
        final display = roundDown
            ? (scaledValue >= 0
                ? scaledValue.floorToDouble()
                : scaledValue.ceilToDouble())
            : scaledValue;
        final trimmed = _trimGroups(_numberFormatter.format(display));
        return _appendZeros(trimmed);
      };

  String Function(double) axisFormatterFor(double maxValue) {
    final formatter = NumberFormat(numberPattern, 'tr_TR');
    if (minFractionDigits != null) {
      formatter.minimumFractionDigits = minFractionDigits!;
    }
    if (maxFractionDigits != null) {
      formatter.maximumFractionDigits = maxFractionDigits!;
    }

    return (scaledValue) {
      final display = roundDown
          ? (scaledValue >= 0
              ? scaledValue.floorToDouble()
              : scaledValue.ceilToDouble())
          : scaledValue;
      final trimmed = _trimGroups(formatter.format(display));
      return _appendZeros(trimmed);
    };
  }

  double scale(double value) => value * scaleFactor;

  String _trimGroups(String formatted) {
    final maxGroups = maxIntegerGroups;
    if (maxGroups == null) {
      return formatted;
    }

    var core = formatted;
    final isNegative = core.startsWith('-');
    if (isNegative) {
      core = core.substring(1);
    }

    final symbols = _numberFormatter.symbols;
    final decimalSeparator = symbols.DECIMAL_SEP;
    final groupSeparator = symbols.GROUP_SEP;

    var decimalPart = '';
    if (decimalSeparator.isNotEmpty) {
      final decimalIndex = core.indexOf(decimalSeparator);
      if (decimalIndex != -1) {
        decimalPart = core.substring(decimalIndex);
        core = core.substring(0, decimalIndex);
      }
    }

    if (groupSeparator.isEmpty) {
      return isNegative ? '-$core$decimalPart' : '$core$decimalPart';
    }

    final parts = core.split(groupSeparator);
    if (parts.length <= maxGroups) {
      return formatted;
    }

    final trimmed = parts.take(maxGroups).join(groupSeparator);
    return isNegative ? '-$trimmed$decimalPart' : '$trimmed$decimalPart';
  }

  String _appendZeros(String formatted) {
    if (trailingZeroCount <= 0) {
      return formatted;
    }

    final symbols = _numberFormatter.symbols;
    final decimalSeparator = symbols.DECIMAL_SEP;
    if (decimalSeparator.isNotEmpty && formatted.contains(decimalSeparator)) {
      return formatted;
    }

    final groupSeparator = symbols.GROUP_SEP;
    final separator = groupSeparator.isNotEmpty ? groupSeparator : '';
    final zeroGroup = '0' * trailingZeroCount;

    final sign = formatted.startsWith('-') ? '-' : '';
    final core = sign.isEmpty ? formatted : formatted.substring(1);
    return '$sign$core$separator$zeroGroup';
  }
}

class _DateRange {
  const _DateRange(this.start, this.end);

  final DateTime start;
  final DateTime end;
}

class _ChartSeries {
  const _ChartSeries({required this.labels, required this.values});

  final List<String> labels;
  final List<double> values;

  double get maxValue =>
      values.isEmpty ? 0 : values.reduce((a, b) => math.max(a, b));
}
