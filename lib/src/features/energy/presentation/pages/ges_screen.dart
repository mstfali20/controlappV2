import 'dart:math' as math;

import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/data/tree_node.dart';
import 'package:controlapp/src/core/di/injector.dart';
import 'package:controlapp/src/features/energy/domain/utils/currency_formatter.dart';
import 'package:controlapp/src/features/energy/presentation/view_model/ges_consumption_cubit.dart';
import 'package:controlapp/src/features/energy/presentation/view_model/ges_consumption_state.dart';
import 'package:controlapp/src/features/energy/presentation/widgets/custom_main_widget.dart';
import 'package:controlapp/src/features/energy/presentation/pages/energy_chart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:controlapp/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';

const List<String> _kGesAllowedCaptionOrder = [
  'çatı ges toplam',
  'çivril ges',
  'isparta ges',
  'söke ges toplam',
  'tavas ges',
  'urfa ges toplam',
];

const Set<String> _kGesAllowedCaptionSet = {
  'çatı ges toplam',
  'çivril ges',
  'isparta ges',
  'söke ges toplam',
  'tavas ges',
  'urfa ges toplam',
};

String _captionKey(String caption) {
  return caption.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}

class GesScren extends StatefulWidget {
  const GesScren({
    super.key,
    required this.totalTuketimId,
    required this.uretimTuketimId,
    required this.gesfark,
    required this.gesid,
    required this.periodIndex,
    required this.termIndex,
  });

  final String? totalTuketimId;
  final String? gesfark;
  final String? gesid;
  final String? uretimTuketimId;
  final String? periodIndex;
  final String? termIndex;

  @override
  State<GesScren> createState() => _GesScrenState();
}

class _GesScrenState extends State<GesScren> {
  late final GesConsumptionCubit _consumptionCubit;

  bool _isLoadingDevices = true;
  List<TreeNode> _displayDevices = const [];
  List<TreeNode> _primaryDevices = const [];
  Set<String> _primaryCaptions = const {};
  String? _deviceError;

  @override
  void initState() {
    super.initState();
    _consumptionCubit = GesConsumptionCubit(fetchUseCase: getIt());
    _initialize();
  }

  @override
  void dispose() {
    _consumptionCubit.close();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _loadGesDevices();
    if (mounted) {
      await _loadConsumptionData();
    }
  }

  Future<void> _loadGesDevices() async {
    try {
      final node = await _getGesNodeById(widget.gesid);
      if (node != null) {
        final devices = List<TreeNode>.from(node.children);
        final selection = _selectDevices(devices);
        final filteredDevices = _orderAllowedDevices(selection.primaryDevices);
        final primaryDevices = filteredDevices.isNotEmpty
            ? filteredDevices
            : selection.primaryDevices;
        setState(() {
          _displayDevices =
              List<TreeNode>.unmodifiable(selection.displayDevices);
          _primaryDevices = List<TreeNode>.unmodifiable(primaryDevices);
          _primaryCaptions =
              primaryDevices.map((device) => device.caption.trim()).toSet();
        });
      } else {
        setState(() => _deviceError = 'ges_device_not_found');
      }
    } catch (error) {
      setState(() => _deviceError = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoadingDevices = false);
      }
    }
  }

  Future<void> _loadConsumptionData() async {
    final username =
        users.isNotEmpty ? users : userDataConst['username']?.toString() ?? '';
    final password =
        pass.isNotEmpty ? pass : userDataConst['password']?.toString() ?? '';
    if (username.isEmpty || password.isEmpty) {
      setState(() => _deviceError = 'missing_credentials');
      return;
    }

    if (_primaryDevices.isEmpty &&
        (widget.uretimTuketimId == null || widget.uretimTuketimId!.isEmpty)) {
      setState(() => _deviceError = 'ges_device_not_found');
      return;
    }

    await _consumptionCubit.load(
      username: username,
      password: password,
      devices: _primaryDevices,
      periodType: widget.periodIndex ?? '3',
      type: '1',
      totalCheckPt: '0',
      term: widget.termIndex ?? '1',
      includeCaptions: _primaryCaptions,
    );
  }

  Future<TreeNode?> _getGesNodeById(String? gesId) async {
    if (gesId == null || gesId.isEmpty) {
      return null;
    }
    final root = TreeNode.parseTree(treeJson);
    if (root == null) {
      return null;
    }
    final nodes = root.walk().toList();

    try {
      final firmName = (userDataConst['firm_name']?.toString() ?? '').trim();
      final firmNode = nodes.firstWhere(
        (node) => node.caption.trim() == firmName,
        orElse: () => TreeNode.empty(),
      );
      final enerjiNode = firmNode.children.firstWhere(
        (node) => node.caption.trim() == enerjiIzlem,
        orElse: () => TreeNode.empty(),
      );
      final gesNode = enerjiNode.children.firstWhere(
        (node) => node.id == gesId,
        orElse: () => TreeNode.empty(),
      );
      return gesNode.id.isEmpty ? null : gesNode;
    } catch (_) {
      return null;
    }
  }

  List<TreeNode> _orderAllowedDevices(Iterable<TreeNode> devices) {
    final mapped = <String, TreeNode>{};
    for (final device in devices) {
      final key = _captionKey(device.caption);
      if (_kGesAllowedCaptionSet.contains(key) && !mapped.containsKey(key)) {
        mapped[key] = device;
      }
    }

    final ordered = <TreeNode>[];
    for (final allowed in _kGesAllowedCaptionOrder) {
      final match = mapped[allowed];
      if (match != null) {
        ordered.add(match);
      }
    }
    return ordered;
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

    if (totals.isEmpty && singles.isEmpty) {
      return _DeviceSelection(
        displayDevices: List<TreeNode>.unmodifiable(sorted),
        primaryDevices: List<TreeNode>.unmodifiable(sorted),
        primaryCaptions: Set<String>.unmodifiable(
          sorted.map((device) => device.caption.trim()),
        ),
      );
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

  Map<String, double> _filterPieData(Map<String, double> rawData) {
    final mapped = <String, MapEntry<String, double>>{};
    for (final entry in rawData.entries) {
      final value = entry.value;
      if (!value.isFinite || value <= 0) {
        continue;
      }
      final key = _captionKey(entry.key);
      if (_kGesAllowedCaptionSet.contains(key) && !mapped.containsKey(key)) {
        mapped[key] = MapEntry(entry.key, value);
      }
    }

    final filtered = <String, double>{};
    for (final allowed in _kGesAllowedCaptionOrder) {
      final match = mapped[allowed];
      if (match != null) {
        filtered[match.key] = match.value;
      }
    }

    if (filtered.isNotEmpty) {
      return filtered;
    }

    return Map<String, double>.fromEntries(
      rawData.entries.where((entry) => entry.value.isFinite && entry.value > 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _consumptionCubit,
      child: BlocBuilder<GesConsumptionCubit, GesConsumptionState>(
        builder: (context, state) {
          final isPieLoading = _isLoadingDevices || state.loading;
          final dataMap = state.data;
          final errorMessage = _deviceError ?? state.error;
          final filteredData = _filterPieData(dataMap);

          return Column(
            children: [
              if (isPieLoading)
                const CircularProgressIndicator(color: contolblue)
              else if (errorMessage != null)
                _ErrorCard(message: errorMessage)
              else if (filteredData.isEmpty)
                _EmptyCard(message: l10n.kategorigrafigi)
              else
                _PieChartCard(
                  dataMap: filteredData,
                  defaultLabel:
                      l10n.localeName == 'tr' ? 'GES Toplam' : 'GES Total',
                ),
              const SizedBox(height: 16),
              if (_isLoadingDevices)
                const CircularProgressIndicator(color: contolblue)
              else if (_displayDevices.isEmpty)
                const _ErrorCard(message: 'GES cihazı bulunamadı')
              else
                Column(
                  children: _displayDevices.map((device) {
                    return CustomMainWidget(
                      title: device.caption,
                      subtitle: l10n.uretim,
                      backgroundColor: Colors.green,
                      leading: Image.asset('assets/icons/kwh.png'),
                      periodType: widget.periodIndex ?? '3',
                      term: widget.termIndex ?? '1',
                      deviceId: device.id,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GrafikPage(
                              barColor: Colors.green,
                              title: device.caption,
                              subtitle: l10n.uretim,
                              deviceId: device.id,
                              birimValue: 'kWh',
                              degerValue: '₺',
                              periodIndex: widget.periodIndex ?? '3',
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
            ],
          );
        },
      ),
    );
  }
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

class _PieChartCard extends StatefulWidget {
  const _PieChartCard({
    required this.dataMap,
    required this.defaultLabel,
  });

  final Map<String, double> dataMap;
  final String defaultLabel;

  @override
  State<_PieChartCard> createState() => _PieChartCardState();
}

class _PieChartCardState extends State<_PieChartCard> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final entries = widget.dataMap.entries.toList();
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.value);
    final colors = List<Color>.generate(
      entries.length,
      (index) => pieColorList[index % pieColorList.length],
    );

    final width = MediaQuery.of(context).size.width;
    final chartSize = math.min(width * 0.46, 200.w);
    final highlightedEntry = _touchedIndex != null &&
            _touchedIndex! >= 0 &&
            _touchedIndex! < entries.length
        ? entries[_touchedIndex!]
        : null;
    final highlightedPercent = highlightedEntry != null && total > 0
        ? (highlightedEntry.value / total) * 100
        : null;

    return Container(
      width: width * 0.92,
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: chartSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: chartSize * 0.3,
                    startDegreeOffset: -85,
                    borderData: FlBorderData(show: false),
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (event is! FlTapUpEvent) {
                          if (event is FlTapCancelEvent ||
                              event is FlLongPressEnd ||
                              event is FlPointerExitEvent ||
                              event is FlPanEndEvent) {
                            setState(() => _touchedIndex = null);
                          }
                          return;
                        }

                        final touchedSection = response?.touchedSection;
                        setState(() {
                          if (touchedSection == null) {
                            _touchedIndex = null;
                          } else {
                            final index = touchedSection.touchedSectionIndex;
                            _touchedIndex =
                                index == _touchedIndex ? null : index;
                          }
                        });
                      },
                    ),
                    sections: entries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      final percent =
                          total == 0 ? 0 : (data.value / total) * 100;
                      final isTouched = index == _touchedIndex;
                      return PieChartSectionData(
                        value: data.value,
                        color: colors[index],
                        radius: isTouched ? chartSize * 0.43 : chartSize * 0.36,
                        title: percent >= 2
                            ? '%${percent.toStringAsFixed(percent >= 10 ? 0 : 1)}'
                            : '',
                        titleStyle: TextStyle(
                          color: Colors.white,
                          fontSize: isTouched ? 15.sp : 12.sp,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        borderSide: BorderSide(
                          color:
                              Colors.white.withOpacity(isTouched ? 0.6 : 0.25),
                          width: isTouched ? 4 : 2,
                        ),
                        badgeWidget: isTouched
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  CurrencyFormatter.format(data.value),
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : null,
                        badgePositionPercentageOffset: 0.88,
                      );
                    }).toList(),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => setState(() => _touchedIndex = null),
                  child: SizedBox(
                    width: chartSize * 0.6,
                    height: chartSize * 0.6,
                    child: Center(
                      child: _ChartCenter(
                        title: highlightedEntry?.key ?? widget.defaultLabel,
                        value: CurrencyFormatter.format(
                          highlightedEntry?.value ?? total,
                        ),
                        percent: highlightedPercent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 35.h),
          _LegendList(
            entries: entries,
            colors: colors,
            total: total,
            selectedIndex: _touchedIndex,
            formatValue: (value) => CurrencyFormatter.format(value),
            onTap: (index) {
              setState(() {
                _touchedIndex = index == _touchedIndex ? null : index;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _LegendList extends StatelessWidget {
  const _LegendList({
    required this.entries,
    required this.colors,
    required this.total,
    required this.selectedIndex,
    required this.formatValue,
    required this.onTap,
  });

  final List<MapEntry<String, double>> entries;
  final List<Color> colors;
  final double total;
  final int? selectedIndex;
  final String Function(double value) formatValue;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: entries.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        final percent = total == 0 ? 0 : (data.value / total) * 100;
        final isSelected = index == selectedIndex;
        final baseColor = colors[index % colors.length];

        return GestureDetector(
          onTap: () => onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: EdgeInsets.symmetric(vertical: 6.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? baseColor.withOpacity(0.12)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isSelected
                    ? baseColor.withOpacity(0.4)
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    data.key,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatValue(data.value),
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '%${percent.toStringAsFixed(percent >= 10 ? 0 : 1)}',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ChartCenter extends StatelessWidget {
  const _ChartCenter({
    required this.title,
    required this.value,
    this.percent,
  });

  final String title;
  final String value;
  final double? percent;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Column(
        key: ValueKey<String>(
            '${title}_${value}_${percent?.toStringAsFixed(1) ?? 'total'}'),
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title.trim().isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
          ],
          Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (percent != null) ...[
            SizedBox(height: 4.h),
            Text(
              '%${percent!.toStringAsFixed(percent! >= 10 ? 0 : 1)}',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        color: Colors.grey.shade200,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 64.r,
            color: Colors.orange,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Veri alınamadı veya cihaz çalışmıyor olabilir.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
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
