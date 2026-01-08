import 'dart:async';
import 'dart:developer';

import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart' as legacy_data;
import 'package:controlapp/src/core/di/injector.dart';
import 'package:controlapp/src/features/yenilenebilir_enerji/ges/domain/entities/renewable_energy_consumption_history.dart';
import 'package:controlapp/src/features/yenilenebilir_enerji/ges/domain/entities/renewable_energy_consumption_record.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:controlapp/src/features/yenilenebilir_enerji/ges/domain/renewable_history_period.dart';
import 'package:controlapp/src/features/yenilenebilir_enerji/ges/presentation/view_model/renewable_history_cubit.dart';
import 'package:controlapp/src/features/yenilenebilir_enerji/ges/presentation/view_model/renewable_history_state.dart';
import 'package:controlapp/src/features/yenilenebilir_enerji/ges/presentation/widgets/renewable_ges_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class RenewableGrafikPage extends StatefulWidget {
  const RenewableGrafikPage({
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
  final int periodIndex;

  @override
  State<RenewableGrafikPage> createState() => _RenewableGrafikPageState();
}

class _RenewableGrafikPageState extends State<RenewableGrafikPage> {
  late final RenewableHistoryCubit _historyCubit;
  late final String _username;
  late final String _password;

  final Map<RenewableHistoryPeriod, RenewableEnergyConsumptionHistory?>
      _historyCache = {};
  bool _isLoading = false;
  RenewableHistoryPeriod _selectedPeriod = RenewableHistoryPeriod.today;

  static final NumberFormat _kwhFormat = NumberFormat('#,##0.0', 'tr_TR');
  static final NumberFormat _tlFormat = NumberFormat('#,##0', 'tr_TR');

  @override
  void initState() {
    super.initState();
    _historyCubit = RenewableHistoryCubit(fetchUseCase: getIt());
    _username = legacy_data.users.isNotEmpty
        ? legacy_data.users
        : legacy_data.userDataConst['username']?.toString() ?? '';
    _password = legacy_data.pass.isNotEmpty
        ? legacy_data.pass
        : legacy_data.userDataConst['password']?.toString() ?? '';
    _selectedPeriod = RenewableHistoryPeriod.values[
        widget.periodIndex.clamp(0, RenewableHistoryPeriod.values.length - 1)];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistoryFor(_selectedPeriod, force: true);
    });
  }

  @override
  void dispose() {
    _historyCubit.close();
    super.dispose();
  }

  Future<void> _loadHistoryFor(
    RenewableHistoryPeriod period, {
    bool force = false,
  }) async {
    if (!force && _historyCache.containsKey(period)) {
      return;
    }
    if (_username.isEmpty || _password.isEmpty) {
      _showError('missing_credentials');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final range = _dateRangeFor(period);
      final history = await _historyCubit.load(
        username: _username,
        password: _password,
        deviceId: widget.deviceId,
        periodType: _periodType(period),
        type: '0',
        totalCheckPt: '1',
        term: '1',
        startDate: _formatDate(range.start),
        endDate: _formatDate(range.end),
      );
      if (!mounted) return;
      if (history != null && history.isSuccess) {
        _historyCache[period] = history;
      } else {
        _historyCache[period] = null;
        _showError(history?.errorDescription ?? 'veri_alinamadi');
      }
    } catch (error) {
      _historyCache[period] = null;
      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<RenewableEnergyConsumptionRecord> _recordsFor(
      RenewableHistoryPeriod period) {
    return _historyCache[period]?.records ?? const [];
  }

  double _totalKwh(List<RenewableEnergyConsumptionRecord> records) =>
      records.fold<double>(0, (prev, record) => prev + record.value);

  double _totalTl(List<RenewableEnergyConsumptionRecord> records) =>
      records.fold<double>(0, (prev, record) => prev + record.amount);

  _RenewableChartPayload _chartPayloadForPeriod(
    List<RenewableEnergyConsumptionRecord> records,
    RenewableHistoryPeriod period,
    AppLocalizations l10n,
  ) {
    switch (period) {
      case RenewableHistoryPeriod.today:
        return _buildTodayPayload(records);
      case RenewableHistoryPeriod.daily:
        return _buildDailyPayload(records);
      case RenewableHistoryPeriod.monthly:
        return _buildMonthlyPayload(records, l10n);
      case RenewableHistoryPeriod.yearly:
        return _buildYearlyPayload(records);
    }
  }

  _RenewableChartPayload _buildTodayPayload(
      List<RenewableEnergyConsumptionRecord> records) {
    final values = List<double>.filled(24, 0);
    for (final record in records) {
      final hour = record.timestamp.hour;
      if (hour >= 0 && hour < values.length) {
        values[hour] += record.value;
      }
    }
    final labels = List<String>.generate(24, (index) => '${index.toString().padLeft(2, '0')}:00');
    return _RenewableChartPayload(values: values, labels: labels);
  }

  _RenewableChartPayload _buildDailyPayload(
      List<RenewableEnergyConsumptionRecord> records) {
    final now = DateTime.now();
    final values = List<double>.filled(now.day, 0);
    for (final record in records) {
      if (record.timestamp.year == now.year &&
          record.timestamp.month == now.month) {
        final dayIndex = record.timestamp.day - 1;
        if (dayIndex >= 0 && dayIndex < values.length) {
          values[dayIndex] += record.value;
        }
      }
    }
    final labels = List<String>.generate(now.day, (index) => '${index + 1}');
    return _RenewableChartPayload(values: values, labels: labels);
  }

  _RenewableChartPayload _buildMonthlyPayload(
    List<RenewableEnergyConsumptionRecord> records,
    AppLocalizations l10n,
  ) {
    final values = List<double>.filled(12, 0);
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
    final currentYear = DateTime.now().year;
    for (final record in records) {
      if (record.timestamp.year == currentYear) {
        final monthIndex = record.timestamp.month - 1;
        if (monthIndex >= 0 && monthIndex < values.length) {
          values[monthIndex] += record.value;
        }
      }
    }
    return _RenewableChartPayload(values: values, labels: monthLabels);
  }

  _RenewableChartPayload _buildYearlyPayload(
      List<RenewableEnergyConsumptionRecord> records) {
    final totals = <int, double>{};
    for (final record in records) {
      final year = record.timestamp.year;
      totals[year] = (totals[year] ?? 0) + record.value;
    }
    if (totals.isEmpty) {
      final currentYear = DateTime.now().year;
      return _RenewableChartPayload(values: const [], labels: [currentYear.toString()]);
    }
    final sortedYears = totals.keys.toList()..sort();
    final values = sortedYears.map((year) => totals[year]!).toList();
    final labels = sortedYears.map((year) => year.toString()).toList();
    return _RenewableChartPayload(values: values, labels: labels);
  }

  String _summaryFormatter(double value) => _kwhFormat.format(value);

  String _periodType(RenewableHistoryPeriod period) {
    switch (period) {
      case RenewableHistoryPeriod.today:
        return '0';
      case RenewableHistoryPeriod.daily:
        return '1';
      case RenewableHistoryPeriod.monthly:
        return '3';
      case RenewableHistoryPeriod.yearly:
        return '4';
    }
  }

  _DateRange _dateRangeFor(RenewableHistoryPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case RenewableHistoryPeriod.today:
        final start = DateTime(now.year, now.month, now.day);
        final end = start.add(const Duration(days: 1));
        return _DateRange(start, end);
      case RenewableHistoryPeriod.daily:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        return _DateRange(start, end);
      case RenewableHistoryPeriod.monthly:
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        return _DateRange(start, end);
      case RenewableHistoryPeriod.yearly:
        final start = DateTime(now.year - 5, 1, 1);
        final end = DateTime(now.year + 5, 12, 31);
        return _DateRange(start, end);
    }
  }

  static String _formatDate(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date.toLocal());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final records = _recordsFor(_selectedPeriod);
    final payload = _chartPayloadForPeriod(records, _selectedPeriod, l10n);
    final totalKwh = _totalKwh(records);
    final totalTl = _totalTl(records);
    final formattedTotalKwh = _summaryFormatter(totalKwh);
    final formattedTotalTl = _tlFormat.format(totalTl);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 14.h),
              RenewablePeriodTabs(
                tabs: const ['Bugün', 'Günlük', 'Aylık', 'Yıllık'],
                activeIndex: _selectedPeriod.index,
                onChange: (index) {
                  final period = RenewableHistoryPeriod.values[index];
                  if (_selectedPeriod == period) {
                    return;
                  }
                  setState(() {
                    _selectedPeriod = period;
                  });
                  _loadHistoryFor(period);
                },
              ),
              SizedBox(height: 12.h),
              RenewableSummaryRow(
                kwhLabel: formattedTotalKwh,
                tlLabel: formattedTotalTl,
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: RenewableProductionChart(
                  values: payload.values,
                  labels: payload.labels,
                  period: _selectedPeriod,
                  isLoading: _isLoading,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Text(
                    widget.birimValue,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    widget.degerValue,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _RenewableChartPayload {
  const _RenewableChartPayload({
    required this.values,
    required this.labels,
  });

  final List<double> values;
  final List<String> labels;
}

class _DateRange {
  const _DateRange(this.start, this.end);

  final DateTime start;
  final DateTime end;
}
