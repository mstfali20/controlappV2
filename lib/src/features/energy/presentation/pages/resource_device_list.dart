import 'dart:math' as math;

import 'package:controlapp/src/features/energy/presentation/pages/energy_chart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;

import 'package:controlapp/const/data.dart';
import 'package:controlapp/src/features/energy/presentation/widgets/custom_main_widget.dart';
import 'package:controlapp/src/features/energy/domain/utils/energy_value_parser.dart';

class ResourceDeviceList extends StatefulWidget {
  const ResourceDeviceList({
    super.key,
    required this.nodeId,
    required this.periodType,
    required this.term,
    required this.cardColor,
    required this.leadingBuilder,
    required this.subtitle,
    required this.chartColor,
    required this.chartSubtitle,
    required this.valueUnit,
    required this.amountUnit,
    this.emptyMessage,
    this.errorMessage,
  });

  final String? nodeId;
  final String periodType;
  final String term;
  final Color cardColor;
  final WidgetBuilder leadingBuilder;
  final String subtitle;
  final Color chartColor;
  final String chartSubtitle;
  final String valueUnit;
  final String amountUnit;
  final String? emptyMessage;
  final String? errorMessage;

  @override
  State<ResourceDeviceList> createState() => _ResourceDeviceListState();
}

class _ResourceDeviceListState extends State<ResourceDeviceList> {
  late final List<_ResourceDevice> _devices;
  String? _error;

  @override
  void initState() {
    super.initState();
    final result = _loadDevices(widget.nodeId);
    _devices = result.devices;
    _error = result.error;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _FeedbackCard(
        message: widget.errorMessage ?? _error!,
        color: Colors.red.shade50,
        textColor: Colors.red.shade400,
        icon: Icons.error_outline,
      );
    }

    if (_devices.isEmpty) {
      return _FeedbackCard(
        message: widget.emptyMessage ?? 'Veri bulunamadı',
        color: Colors.grey.shade200,
        textColor: Colors.black87,
        icon: Icons.warning_amber_rounded,
      );
    }

    return Column(
      children: _devices.map((device) {
        return CustomMainWidget(
          title: device.caption,
          subtitle: widget.subtitle,
          backgroundColor: widget.cardColor,
          leading: widget.leadingBuilder(context),
          periodType: widget.periodType,
          term: widget.term,
          deviceId: device.id,
          consumptionValueFormatter: _needsBuharValueFormatter
              ? _formatBuharConsumption
              : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GrafikPage(
                  barColor: widget.chartColor,
                  title: device.caption,
                  subtitle: widget.chartSubtitle,
                  deviceId: device.id,
                  birimValue: widget.valueUnit,
                  degerValue: widget.amountUnit,
                  periodIndex: widget.periodType,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  _DeviceLoadResult _loadDevices(String? nodeId) {
    if (nodeId == null || nodeId.isEmpty) {
      return const _DeviceLoadResult(
        devices: [],
        error: 'Cihaz bilgisi bulunamadı.',
      );
    }

    try {
      final document = xml.XmlDocument.parse(xmlString);
      final target = document.findAllElements('node').firstWhere(
            (element) => element.getAttribute('id') == nodeId,
            orElse: () => xml.XmlElement(xml.XmlName('node')),
          );

      if (target.getAttribute('id') != nodeId) {
        return const _DeviceLoadResult(
          devices: [],
          error: 'Seçili kaynağa ait cihaz bulunamadı.',
        );
      }

      final devices = target.children
          .whereType<xml.XmlElement>()
          .map(
            (element) => _ResourceDevice(
              id: element.getAttribute('id') ?? '',
              caption: element.getAttribute('caption') ?? '',
              category: element.getAttribute('category') ?? '',
            ),
          )
          .where((device) => device.id.isNotEmpty && device.caption.isNotEmpty)
          .toList();

      devices.sort((a, b) {
        if (a.category == '0' && b.category != '0') {
          return -1;
        }
        if (a.category != '0' && b.category == '0') {
          return 1;
        }
        return a.caption.compareTo(b.caption);
      });

      return _DeviceLoadResult(devices: devices);
    } catch (error) {
      return _DeviceLoadResult(
        devices: const [],
        error: error.toString(),
      );
    }
  }

  bool get _needsBuharValueFormatter {
    final unit = widget.valueUnit.trim().toLowerCase();
    return unit.contains('m3') || unit.contains('m³');
  }

  String _formatBuharConsumption(String raw) {
    if (raw.trim().isEmpty || raw == '#') {
      return raw;
    }
    final numeric = EnergyValueParser.parse(raw);
    final absValue = numeric.abs();
    var scaleFactor = 1.0;
    var unitLabel = widget.valueUnit.trim();

    if (widget.periodType == '0' || widget.periodType == '1') {
      if (absValue >= 1000) {
        final rawTier =
            (math.log(absValue) / math.ln10).floor() ~/ 3;
        final tier = rawTier.clamp(0, 3) as int;
        scaleFactor = 1 / math.pow(10, tier * 3);
      }
    } else if (widget.periodType == '3' || widget.periodType == '4') {
      if (absValue >= 1e12) {
        scaleFactor = 1 / 1e9;
      } else if (absValue >= 1e9) {
        scaleFactor = 1 / 1e6;
      } else if (absValue >= 1e6) {
        scaleFactor = 1 / 1e3;
      }
      if (scaleFactor < 1) {
        unitLabel = unitLabel.replaceAll('m3', 'ton').replaceAll('m³', 'ton');
      }
    }
    final displayValue = numeric * scaleFactor;
    final scaledAbs = displayValue.abs();
    final pattern = scaledAbs < 1
        ? '#,##0.###'
        : scaledAbs < 100
            ? '#,##0.#'
            : '#,##0';
    final formatter = NumberFormat(pattern, 'tr_TR');
    final formatted = formatter.format(
      scaleFactor < 1 && scaledAbs >= 10 ? displayValue.floor() : displayValue,
    );
    return unitLabel.isEmpty ? formatted : '$formatted $unitLabel';
  }
}

class _ResourceDevice {
  const _ResourceDevice({
    required this.id,
    required this.caption,
    required this.category,
  });

  final String id;
  final String caption;
  final String category;
}

class _DeviceLoadResult {
  const _DeviceLoadResult({
    required this.devices,
    this.error,
  });

  final List<_ResourceDevice> devices;
  final String? error;
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.message,
    required this.color,
    required this.textColor,
    required this.icon,
  });

  final String message;
  final Color color;
  final Color textColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        color: color,
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
