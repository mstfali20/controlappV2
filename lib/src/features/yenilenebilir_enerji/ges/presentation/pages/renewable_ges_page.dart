import 'dart:async';
import 'dart:developer';

import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/data/tree_node.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:controlapp/src/core/di/injector.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/presentation/pages/energy_chart_page.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/domain/entities/energy_consumption.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/domain/entities/energy_consumption_history.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/domain/entities/energy_consumption_record.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/domain/entities/energy_snapshot.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/domain/usecases/fetch_energy_consumption_history_usecase.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/domain/usecases/fetch_energy_consumption_usecase.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/domain/usecases/fetch_energy_snapshot_usecase.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/domain/usecases/get_cached_snapshot_usecase.dart';
import 'package:controlapp/src/features/enerji_izleme/energy/domain/utils/energy_value_parser.dart';
import 'package:controlapp/src/features/presentation/home/view_model/home_cubit.dart';
import 'package:controlapp/src/features/yenilenebilir_enerji/ges/domain/renewable_ges_tree_helper.dart';
import 'package:controlapp/src/features/yenilenebilir_enerji/ges/domain/renewable_history_period.dart';
import 'package:controlapp/src/features/yenilenebilir_enerji/ges/presentation/view_models/renewable_ges_view_model.dart';
import 'package:controlapp/src/features/yenilenebilir_enerji/ges/presentation/widgets/renewable_ges_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class RenewableGesPage extends StatefulWidget {
  const RenewableGesPage({super.key});

  @override
  State<RenewableGesPage> createState() => _RenewableGesPageState();
}

class _RenewableGesPageState extends State<RenewableGesPage> {
  late final RenewableGesTreeHelper _treeHelper;
  late final RenewableGesViewModel _viewModel;
  late final FetchEnergyConsumptionHistoryUseCase _historyUseCase;
  late final FetchEnergyConsumptionUseCase _consumptionUseCase;
  late final FetchEnergySnapshotUseCase _snapshotUseCase;
  late final GetCachedSnapshotUseCase _cachedSnapshotUseCase;

  bool _isLoadingDevices = true;
  List<TreeNode> _displayDevices = const [];
  final Map<String, Map<RenewableHistoryPeriod, EnergyConsumptionHistory?>>
      _deviceHistoryCache = {};
  final Map<String, Map<RenewableHistoryPeriod, EnergyConsumption?>>
      _deviceSummaryCache = {};
  final Map<String, EnergySnapshot?> _deviceSnapshotCache = {};
  final Set<String> _loadingHistoryDevices = {};
  final Set<String> _loadingSummaryDevices = {};
  final Set<String> _loadingSnapshotDevices = {};
  int _lastPeriodIndex = 0;
  String? _deviceError;

  static final _summaryNumberFormat = NumberFormat('#,##0.0', 'tr_TR');
  static final _tlNumberFormat = NumberFormat('#,##0', 'tr_TR');

  RenewableHistoryPeriod get _currentPeriod =>
      _periodFromIndex(_viewModel.activeChartPeriodIndex);

  @override
  void initState() {
    super.initState();
    _treeHelper = const RenewableGesTreeHelper();
    _historyUseCase = getIt<FetchEnergyConsumptionHistoryUseCase>();
    _consumptionUseCase = getIt<FetchEnergyConsumptionUseCase>();
    _snapshotUseCase = getIt<FetchEnergySnapshotUseCase>();
    _cachedSnapshotUseCase = getIt<GetCachedSnapshotUseCase>();
    _viewModel = RenewableGesViewModel();
    _viewModel.addListener(_onViewModelChanged);
    _initialize();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  Future<void> _initialize() async {
    await _loadGesDevices();
  }

  Future<void> _loadGesDevices() async {
    try {
      final root = _parseTree();
      if (root == null) {
        setState(() => _deviceError = 'tree_missing');
        return;
      }

      log(
        'renewable tree root: ${root.caption} children: ${root.children.map((child) => '${child.caption} (${child.classType})').join(', ')}',
      );

      final devices =
          _treeHelper.collect(root, context.read<HomeCubit>().state);
      if (devices.isEmpty) {
        setState(() => _deviceError = 'ges_device_not_found');
        return;
      }

      _populateDevices(devices);
    } catch (error) {
      setState(() => _deviceError = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoadingDevices = false);
      }
    }
  }

  void _populateDevices(List<TreeNode> devices) {
    final selection = _selectDevices(devices);
    final locations = _buildLocations(selection.displayDevices);
    log(
      'selection display=${selection.displayDevices.length} primary=${selection.primaryDevices.length}',
    );

    setState(() {
      _displayDevices = List<TreeNode>.unmodifiable(selection.displayDevices);
      _deviceError = null;
    });
    _viewModel.setLocations(locations);
    unawaited(_loadAllDeviceHistories(force: true));
    unawaited(_loadAllDeviceSummaries(force: true));
    unawaited(_loadAllDeviceSnapshots(force: true));
  }

  Future<void> _loadAllDeviceHistories({bool force = false}) async {
    final period = _currentPeriod;
    for (final device in _displayDevices) {
      if (device.id.isEmpty) {
        continue;
      }
      unawaited(_loadHistoryForDevice(device, period, force: force));
    }
  }

  Future<void> _loadAllDeviceSummaries({bool force = false}) async {
    final period = _currentPeriod;
    for (final device in _displayDevices) {
      if (device.id.isEmpty) {
        continue;
      }
      unawaited(_loadSummaryForDevice(device, period, force: force));
    }
  }

  Future<void> _loadAllDeviceSnapshots({bool force = false}) async {
    for (final device in _displayDevices) {
      if (device.id.isEmpty) {
        continue;
      }
      unawaited(_loadSnapshotForDevice(device, force: force));
    }
  }

  Future<void> _loadHistoryForDevice(
    TreeNode device,
    RenewableHistoryPeriod period, {
    bool force = false,
  }) async {
    final deviceCache = _deviceHistoryCache.putIfAbsent(device.id, () => {});
    if (!force && deviceCache.containsKey(period)) {
      return;
    }
    if (device.id.isEmpty) {
      return;
    }
    _setHistoryLoading(device.id, true);
    try {
      final credentials = _loadCredentials();
      if (credentials == null) {
        deviceCache[period] = null;
        return;
      }
      final range = _dateRangeFor(period);
      final history = await _historyUseCase(
        FetchEnergyConsumptionHistoryParams(
          username: credentials.username,
          password: credentials.password,
          deviceId: device.id,
          periodType: _periodType(period),
          type: '0',
          totalCheckPt: '1',
          term: '1',
          startDate: _formatDate(range.start),
          endDate: _formatDate(range.end),
        ),
      );
      deviceCache[period] = history.isSuccess ? history : null;
    } catch (error) {
      log('renewable_history_error', error: error);
      deviceCache[period] = null;
    } finally {
      _setHistoryLoading(device.id, false);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _loadSummaryForDevice(
    TreeNode device,
    RenewableHistoryPeriod period, {
    bool force = false,
  }) async {
    final deviceCache = _deviceSummaryCache.putIfAbsent(device.id, () => {});
    if (!force && deviceCache.containsKey(period)) {
      return;
    }
    if (device.id.isEmpty) {
      return;
    }
    _setSummaryLoading(device.id, true);
    try {
      final credentials = _loadCredentials();
      if (credentials == null) {
        deviceCache[period] = null;
        return;
      }
      final summary = await _consumptionUseCase(
        FetchEnergyConsumptionParams(
          username: credentials.username,
          password: credentials.password,
          deviceId: device.id,
          periodType: _periodType(period),
          type: '1',
          totalCheckPt: '0',
          term: '1',
        ),
      );
      deviceCache[period] = summary.isSuccess ? summary : null;
    } catch (error) {
      log('renewable_summary_error', error: error);
      deviceCache[period] = null;
    } finally {
      _setSummaryLoading(device.id, false);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _loadSnapshotForDevice(
    TreeNode device, {
    bool force = false,
  }) async {
    if (device.id.isEmpty) {
      return;
    }
    if (!force) {
      final cached = _cachedSnapshotUseCase(device.id);
      if (cached != null) {
        _deviceSnapshotCache[device.id] = cached;
        return;
      }
    }
    if (!force && _deviceSnapshotCache.containsKey(device.id)) {
      return;
    }
    _setSnapshotLoading(device.id, true);
    try {
      final credentials = _loadCredentials();
      if (credentials == null) {
        _deviceSnapshotCache[device.id] = null;
        return;
      }
      final snapshot = await _snapshotUseCase(
        FetchEnergySnapshotParams(
          username: credentials.username,
          password: credentials.password,
          deviceId: device.id,
        ),
      );
      _deviceSnapshotCache[device.id] = snapshot.isSuccess ? snapshot : null;
    } catch (error) {
      log('renewable_snapshot_error', error: error);
      _deviceSnapshotCache[device.id] = null;
    } finally {
      _setSnapshotLoading(device.id, false);
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _setHistoryLoading(String deviceId, bool loading) {
    setState(() {
      if (loading) {
        _loadingHistoryDevices.add(deviceId);
      } else {
        _loadingHistoryDevices.remove(deviceId);
      }
    });
  }

  void _setSummaryLoading(String deviceId, bool loading) {
    setState(() {
      if (loading) {
        _loadingSummaryDevices.add(deviceId);
      } else {
        _loadingSummaryDevices.remove(deviceId);
      }
    });
  }

  void _setSnapshotLoading(String deviceId, bool loading) {
    setState(() {
      if (loading) {
        _loadingSnapshotDevices.add(deviceId);
      } else {
        _loadingSnapshotDevices.remove(deviceId);
      }
    });
  }

  _Credentials? _loadCredentials() {
    final username =
        users.isNotEmpty ? users : userDataConst['username']?.toString() ?? '';
    final password =
        pass.isNotEmpty ? pass : userDataConst['password']?.toString() ?? '';
    if (username.isEmpty || password.isEmpty) {
      return null;
    }
    return _Credentials(username: username, password: password);
  }

  void _onViewModelChanged() {
    final newIndex = _viewModel.activeChartPeriodIndex;
    if (_lastPeriodIndex != newIndex) {
      _lastPeriodIndex = newIndex;
      unawaited(_loadAllDeviceHistories(force: true));
      unawaited(_loadAllDeviceSummaries(force: true));
    }
    if (mounted) {
      setState(() {});
    }
  }

  TreeNode? _parseTree() {
    final homeState = context.read<HomeCubit>().state;
    final source = homeState.treeJson?.trim().isNotEmpty == true
        ? homeState.treeJson!
        : treeJson;
    return TreeNode.parseTree(source);
  }

  _DeviceSelection _selectDevices(List<TreeNode> devices) {
    final sorted = List<TreeNode>.from(devices)
      ..sort((a, b) => a.caption.compareTo(b.caption));

    TreeNode? overallTotal;
    final totals = <TreeNode>[];
    final singles = <TreeNode>[];

    for (final device in sorted) {
      final caption = device.caption.trim();
      if (caption.isEmpty) {
        continue;
      }

      final lower = caption.toLowerCase();
      if (lower == 'ges toplam') {
        overallTotal ??= device;
        continue;
      }

      if (lower.contains('toplam')) {
        totals.add(device);
        continue;
      }

      final hasDigit = RegExp(r'\d').hasMatch(caption);
      final hasHyphen = caption.contains('-');
      if (!hasDigit && !hasHyphen) {
        singles.add(device);
      }
    }

    totals.sort((a, b) => a.caption.compareTo(b.caption));
    singles.sort((a, b) => a.caption.compareTo(b.caption));

    final primaryCandidates = <TreeNode>[...totals, ...singles];
    final seenCaptions = <String>{};
    final primaryDevices = <TreeNode>[];
    for (final device in primaryCandidates) {
      final key = device.caption.toLowerCase();
      if (seenCaptions.add(key)) {
        primaryDevices.add(device);
      }
    }

    if (primaryDevices.isEmpty && sorted.isNotEmpty) {
      primaryDevices.add(sorted.first);
    }

    final displayDevices = <TreeNode>[];
    final seenIds = <String>{};
    if (overallTotal != null) {
      displayDevices.add(overallTotal);
      seenIds.add(overallTotal.id);
    }

    for (final device in sorted) {
      if (device.id == overallTotal?.id) {
        continue;
      }
      if (seenIds.add(device.id)) {
        displayDevices.add(device);
      }
    }

    return _DeviceSelection(
      displayDevices: List<TreeNode>.unmodifiable(displayDevices),
      primaryDevices: List<TreeNode>.unmodifiable(primaryDevices),
      primaryCaptions: Set<String>.unmodifiable(
        primaryDevices.map((device) => device.caption.trim()),
      ),
    );
  }

  List<String> _buildLocations(List<TreeNode> devices) {
    final seen = <String>{};
    final locations = <String>[];
    for (final device in devices) {
      final label = _locationLabel(device.caption);
      if (label.isEmpty) {
        continue;
      }
      if (seen.add(label)) {
        locations.add(label);
      }
    }
    return locations;
  }

  String _locationLabel(String caption) {
    final trimmed = caption.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    final prefixMatch =
        RegExp(r'^(.*?)(?=\bges\b)', caseSensitive: false).firstMatch(trimmed);
    final prefix = prefixMatch?.group(1)?.trim();
    if (prefix != null && prefix.isNotEmpty) {
      return prefix;
    }

    var label = trimmed;
    label =
        label.replaceAll(RegExp(r'\bges\b', caseSensitive: false), '').trim();
    label = label
        .replaceAll(RegExp(r'\btoplam\b', caseSensitive: false), '')
        .trim();
    return label.isNotEmpty ? label : trimmed;
  }

  List<TreeNode> get _filteredDevices {
    final selected = _viewModel.selectedLocation;
    if (selected == null || selected.isEmpty) {
      return _displayDevices;
    }
    return _displayDevices
        .where((device) => _locationLabel(device.caption) == selected)
        .toList();
  }

  double? _latestPowerForDevice(TreeNode device) {
    final snapshotValues =
        _deviceSnapshotCache[device.id]?.values ?? const <String, String>{};
    final snapshotPower = _snapshotValueForKeys(
      snapshotValues,
      const [
        'InsActPowerTotal',
        'ActivePower',
        'ActPower',
        'Pac',
        'Power',
      ],
    );
    if (snapshotPower != null) {
      return snapshotPower;
    }

    final candidates = [
      _deviceHistoryCache[device.id]?[RenewableHistoryPeriod.today],
      _deviceHistoryCache[device.id]?[_currentPeriod],
    ];
    for (final history in candidates) {
      if (history == null || history.records.isEmpty) {
        continue;
      }
      var latest = history.records.first;
      for (final record in history.records) {
        if (record.timestamp.isAfter(latest.timestamp)) {
          latest = record;
        }
      }
      final value = latest.value;
      if (value.isFinite) {
        return value;
      }
    }
    return null;
  }

  _SummaryData _summaryForDevice(TreeNode device) {
    final summary = _deviceSummaryCache[device.id]?[_currentPeriod];
    if (summary != null) {
      return _SummaryData(
        totalKwh: EnergyValueParser.parse(summary.consumptionValue),
        totalTl: EnergyValueParser.parse(summary.consumptionAmount),
      );
    }

    final history = _deviceHistoryCache[device.id]?[_currentPeriod];
    if (history == null || history.records.isEmpty) {
      return const _SummaryData(totalKwh: 0, totalTl: 0);
    }
    var totalKwh = 0.0;
    var totalTl = 0.0;
    for (final record in history.records) {
      totalKwh += record.value;
      totalTl += record.amount;
    }
    return _SummaryData(totalKwh: totalKwh, totalTl: totalTl);
  }

  _RenewableChartPayload _chartPayloadForDevice(
    TreeNode device,
    AppLocalizations l10n,
  ) {
    final history = _deviceHistoryCache[device.id]?[_currentPeriod];
    if (history == null || history.records.isEmpty) {
      return const _RenewableChartPayload(values: [], labels: []);
    }
    return _buildChartPayload(history.records, _currentPeriod, l10n);
  }

  _RenewableChartPayload _buildChartPayload(
    List<EnergyConsumptionRecord> records,
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
      List<EnergyConsumptionRecord> records) {
    final values = List<double>.filled(24, 0);
    for (final record in records) {
      final hour = record.timestamp.hour;
      if (hour >= 0 && hour < values.length) {
        values[hour] += record.value;
      }
    }
    final labels = List<String>.generate(
        24, (index) => '${index.toString().padLeft(2, '0')}:00');
    return _RenewableChartPayload(values: values, labels: labels);
  }

  _RenewableChartPayload _buildDailyPayload(
      List<EnergyConsumptionRecord> records) {
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
    List<EnergyConsumptionRecord> records,
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
      List<EnergyConsumptionRecord> records) {
    final aggregate = <int, double>{};
    for (final record in records) {
      final year = record.timestamp.year;
      aggregate[year] = (aggregate[year] ?? 0) + record.value;
    }
    if (aggregate.isEmpty) {
      return const _RenewableChartPayload(values: [], labels: []);
    }
    final sortedYears = aggregate.keys.toList()..sort();
    final values = sortedYears.map((year) => aggregate[year]!).toList();
    final labels = sortedYears.map((year) => year.toString()).toList();
    return _RenewableChartPayload(values: values, labels: labels);
  }

  List<RenewableGesMetric> _metricsForDevice(TreeNode device) {
    final values =
        _deviceSnapshotCache[device.id]?.values ?? const <String, String>{};
    final weatherMetrics = _buildWeatherMetrics(values);
    final hasWeatherData = weatherMetrics.any((metric) => metric.value != '--');
    if (hasWeatherData) {
      return weatherMetrics;
    }
    return _buildEnergyMetrics(values);
  }

  List<RenewableGesMetric> _buildWeatherMetrics(Map<String, String> values) {
    return [
      RenewableGesMetric(
        icon: Icons.wb_sunny,
        value: _formatMetricValue(
          _snapshotValueForKeys(
            values,
            const [
              'Irradiance',
              'Radiation',
              'SolarRadiation',
              'SolarRad',
              'SunRad',
              'Ghi',
            ],
          ),
          fractionDigits: 0,
        ),
        unit: 'W/m²',
      ),
      RenewableGesMetric(
        icon: Icons.thermostat,
        value: _formatMetricValue(
          _snapshotValueForKeys(
            values,
            const [
              'Temperature',
              'Temp',
              'InsTemp',
              'InsTmp',
              'AmbientTemp',
            ],
          ),
          fractionDigits: 1,
        ),
        unit: '°C',
      ),
      RenewableGesMetric(
        icon: Icons.thermostat_outlined,
        value: _formatMetricValue(
          _snapshotValueForKeys(
            values,
            const [
              'PanelTemp',
              'CellTemp',
              'ModuleTemp',
              'ModuleTemperature',
            ],
          ),
          fractionDigits: 1,
        ),
        unit: '°C',
      ),
      RenewableGesMetric(
        icon: Icons.air,
        value: _formatMetricValue(
          _snapshotValueForKeys(
            values,
            const [
              'WindSpeed',
              'WindSpd',
              'WindVel',
              'AirSpeed',
              'Wind',
            ],
          ),
          fractionDigits: 1,
        ),
        unit: 'm/s',
      ),
      RenewableGesMetric(
        icon: Icons.explore,
        value: _formatMetricValue(
          _snapshotValueForKeys(
            values,
            const [
              'WindDirection',
              'WindDir',
              'WindDeg',
              'Direction',
            ],
          ),
          fractionDigits: 0,
        ),
        unit: '°',
      ),
      RenewableGesMetric(
        icon: Icons.opacity,
        value: _formatMetricValue(
          _snapshotValueForKeys(
            values,
            const [
              'Humidity',
              'Hum',
              'RH',
            ],
          ),
          fractionDigits: 0,
        ),
        unit: '%',
      ),
    ];
  }

  List<RenewableGesMetric> _buildEnergyMetrics(Map<String, String> values) {
    return [
      RenewableGesMetric(
        icon: Icons.flash_on_outlined,
        value: _formatMetricValue(
          _snapshotValueForKeys(values, const ['InsCurTotal']),
        ),
        unit: 'A',
      ),
      RenewableGesMetric(
        icon: Icons.bolt_outlined,
        value: _formatMetricValue(
          _snapshotValueForKeys(values, const ['InsActPowerTotal']),
        ),
        unit: 'kW',
      ),
      RenewableGesMetric(
        icon: Icons.battery_charging_full,
        value: _formatMetricValue(
          _snapshotValueForKeys(values, const ['IndActive1ImpTotal']),
        ),
        unit: 'kWh',
      ),
      RenewableGesMetric(
        icon: Icons.speed_outlined,
        value: _formatMetricValue(
          _snapshotValueForKeys(values, const ['IndReactiveInd1ImpTotal']),
        ),
        unit: 'kVArh',
      ),
      RenewableGesMetric(
        icon: Icons.upload_outlined,
        value: _formatMetricValue(
          _snapshotValueForKeys(values, const ['IndActive1ExpTotal']),
        ),
        unit: 'kWh',
      ),
      RenewableGesMetric(
        icon: Icons.thermostat,
        value: _formatMetricValue(
          _snapshotValueForKeys(
            values,
            const [
              'Temperature',
              'Temp',
              'InsTemp',
              'InsTmp',
            ],
          ),
          fractionDigits: 1,
        ),
        unit: '°C',
      ),
    ];
  }

  double? _snapshotValueForKeys(
    Map<String, String> values,
    List<String> keys,
  ) {
    final lowercase = <String, String>{};
    for (final entry in values.entries) {
      lowercase[entry.key.toLowerCase()] = entry.value;
    }
    for (final key in keys) {
      final rawValue = values[key] ?? lowercase[key.toLowerCase()];
      if (rawValue == null || rawValue.trim().isEmpty) {
        continue;
      }
      return EnergyValueParser.parse(rawValue);
    }
    return null;
  }

  String _formatMetricValue(
    double? value, {
    int fractionDigits = 1,
  }) {
    if (value == null || !value.isFinite) {
      return '--';
    }
    final pattern = fractionDigits <= 0
        ? '#,##0'
        : '#,##0.${List.filled(fractionDigits, '#').join()}';
    return NumberFormat(pattern, 'tr_TR').format(value);
  }

  String _productionLabelForDevice(TreeNode device) {
    final summary = _deviceSummaryCache[device.id]?[_currentPeriod];
    if (summary != null) {
      return _formatEnergyValue(
        EnergyValueParser.parse(summary.consumptionValue),
      );
    }
    return _formatEnergyValue(_summaryForDevice(device).totalKwh);
  }

  String _formatEnergyValue(double? value) {
    if (value == null || !value.isFinite) {
      return '--';
    }
    final numberFormat = NumberFormat('#,##0.##', 'tr_TR');
    if (value >= 1000) {
      return '${numberFormat.format(value / 1000)} MWh';
    }
    return '${numberFormat.format(value)} kWh';
  }

  @override
  Widget build(BuildContext context) {
    final fallbackTabs = ['Denizli', 'Urfa', 'Söke'];
    final isLoading = _isLoadingDevices;
    final devices = _filteredDevices;
    final errorMessage = _deviceError;
    final tabNames =
        _viewModel.locations.isNotEmpty ? _viewModel.locations : fallbackTabs;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6.h),
              RenewableGesLocationTabs(
                tabs: tabNames,
                activeTab: _viewModel.selectedLocation ?? tabNames.first,
                onSelect: _viewModel.selectLocation,
              ),
              SizedBox(height: 20.h),
              if (isLoading)
                const Center(
                    child: CircularProgressIndicator(color: contolblue))
              else if (errorMessage != null)
                _ErrorCard(message: errorMessage)
              else if (devices.isEmpty)
                const _ErrorCard(message: 'GES cihazı bulunamadı')
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: devices.map((device) {
                    final summary = _summaryForDevice(device);
                    final chartPayload = _chartPayloadForDevice(device, l10n);
                    final powerValue = _latestPowerForDevice(device);
                    final productionLabel = _productionLabelForDevice(device);
                    final metrics = _metricsForDevice(device);
                    final isSummaryLoading =
                        _loadingSummaryDevices.contains(device.id);
                    final formattedKwh = isSummaryLoading
                        ? '--'
                        : _summaryNumberFormat.format(summary.totalKwh);
                    final formattedTl = isSummaryLoading
                        ? '--'
                        : _tlNumberFormat.format(summary.totalTl);
                    return Padding(
                      padding: EdgeInsets.only(bottom: 26.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RenewableGesCard(
                            device: device,
                            value: powerValue,
                            periodLabel: _viewModel
                                .periodTabs[_viewModel.activeChartPeriodIndex],
                            productionLabel: productionLabel,
                            metrics: metrics,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => GrafikPage(
                                    barColor: const Color(0xFF35BA64),
                                    title: device.caption,
                                    subtitle: l10n.uretim,
                                    deviceId: device.id,
                                    birimValue: 'kWh',
                                    degerValue: '₺',
                                    periodIndex: _viewModel.currentPeriodType,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 12.h),
                          RenewablePeriodTabs(
                            tabs: _viewModel.periodTabs,
                            activeIndex: _viewModel.activeChartPeriodIndex,
                            onChange: (index) {
                              if (_viewModel.activeChartPeriodIndex == index) {
                                return;
                              }
                              _viewModel.selectPeriod(index);
                            },
                          ),
                          SizedBox(height: 10.h),
                          RenewableSummaryRow(
                            kwhLabel: formattedKwh,
                            tlLabel: formattedTl,
                          ),
                          SizedBox(height: 12.h),
                          RenewableProductionChart(
                            values: chartPayload.values,
                            labels: chartPayload.labels,
                            period: _currentPeriod,
                            isLoading:
                                _loadingHistoryDevices.contains(device.id),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
            ],
          ),
        ),
      ),
    );
  }

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

  RenewableHistoryPeriod _periodFromIndex(int index) {
    switch (index) {
      case 0:
        return RenewableHistoryPeriod.today;
      case 1:
        return RenewableHistoryPeriod.daily;
      case 2:
        return RenewableHistoryPeriod.monthly;
      case 3:
        return RenewableHistoryPeriod.yearly;
      default:
        return RenewableHistoryPeriod.daily;
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
}

class _DeviceSelection {
  const _DeviceSelection({
    required this.displayDevices,
    required this.primaryDevices,
    required this.primaryCaptions,
  });

  final List<TreeNode> displayDevices;
  final List<TreeNode> primaryDevices;
  final Set<String> primaryCaptions;
}

class _SummaryData {
  const _SummaryData({
    required this.totalKwh,
    required this.totalTl,
  });

  final double totalKwh;
  final double totalTl;
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

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        color: Colors.red.shade50,
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Credentials {
  const _Credentials({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;
}
