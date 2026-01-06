import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:controlapp/src/core/presentation/safe_cubit.dart';

import 'package:controlapp/data/tree_node.dart';

import '../../domain/usecases/fetch_energy_consumption_usecase.dart';
import '../../domain/utils/energy_value_parser.dart';
import 'ges_consumption_state.dart';

class GesConsumptionCubit extends SafeCubit<GesConsumptionState> {
  GesConsumptionCubit({
    required FetchEnergyConsumptionUseCase fetchUseCase,
  })  : _fetchUseCase = fetchUseCase,
        super(const GesConsumptionState());

  static final Map<_GesConsumptionCacheKey, Map<String, double>> _cache = {};

  final FetchEnergyConsumptionUseCase _fetchUseCase;

  Future<void> load({
    required String username,
    required String password,
    List<TreeNode> devices = const [],
    required String periodType,
    required String type,
    required String totalCheckPt,
    required String term,
    String? summaryDeviceId,
    Set<String>? includeCaptions,
    bool forceRefresh = false,
  }) async {
    final normalizedSummaryId = summaryDeviceId?.trim();
    final summaryId =
        normalizedSummaryId != null && normalizedSummaryId.isNotEmpty
            ? normalizedSummaryId
            : null;

    Set<String>? allowedNormalized;
    Set<String>? allowedLower;
    String? labelsSignature;
    if (includeCaptions != null && includeCaptions.isNotEmpty) {
      allowedLower = includeCaptions
          .map((label) => label.toLowerCase().trim())
          .where((label) => label.isNotEmpty)
          .toSet();

      allowedNormalized = includeCaptions
          .map(_normalizeLabel)
          .where((label) => label.isNotEmpty)
          .toSet();

      final signatureSource = (allowedNormalized != null &&
              allowedNormalized.isNotEmpty)
          ? allowedNormalized
          : allowedLower;
      if (signatureSource != null && signatureSource.isNotEmpty) {
        final signatureParts = signatureSource.toList()..sort();
        labelsSignature = signatureParts.join('|');
      }
    }

    final deviceIds = devices
        .map((device) => device.id)
        .where((id) => id.isNotEmpty)
        .toList()
      ..sort();

    final deviceCacheKey = _GesConsumptionCacheKey(
      username: username,
      deviceIds: List.unmodifiable(deviceIds),
      periodType: periodType,
      type: type,
      totalCheckPt: totalCheckPt,
      term: term,
      labelsSignature: labelsSignature,
    );

    final summaryCacheKey = summaryId == null
        ? null
        : _GesConsumptionCacheKey(
            username: username,
            deviceIds: const [],
            periodType: periodType,
            type: type,
            totalCheckPt: totalCheckPt,
            term: term,
            summaryDeviceId: summaryId,
            useSummaryDevice: true,
            labelsSignature: labelsSignature,
          );

    if (!forceRefresh && summaryCacheKey != null) {
      final cached = _cache[summaryCacheKey];
      if (cached != null) {
        emit(
          state.copyWith(
            loading: false,
            data: Map<String, double>.from(cached),
            clearError: true,
          ),
        );
        return;
      }
    }

    if (!forceRefresh && summaryCacheKey == null) {
      final cached = _cache[deviceCacheKey];
      if (cached != null) {
        emit(
          state.copyWith(
            loading: false,
            data: Map<String, double>.from(cached),
            clearError: true,
          ),
        );
        return;
      }
    }

    emit(state.copyWith(loading: true, clearError: true));

    if (summaryCacheKey != null) {
      final summaryTotals = await _fetchSummaryTotals(
        username: username,
        password: password,
        deviceId: summaryId!,
        periodType: periodType,
        type: type,
        totalCheckPt: totalCheckPt,
        term: term,
        allowedLower: allowedLower,
        allowedNormalized: allowedNormalized,
      );

      if (summaryTotals != null) {
        final normalizedTotals =
            Map<String, double>.unmodifiable(summaryTotals);
        final debugTotals = normalizedTotals.map(
          (key, value) => MapEntry(key, value.toStringAsFixed(2)),
        );
        log(
          'GES pie chart totals prepared from summary device $summaryId: $debugTotals',
          name: 'GesConsumptionCubit',
        );
        _cache[summaryCacheKey] = normalizedTotals;

        emit(
          state.copyWith(
            loading: false,
            data: Map<String, double>.from(normalizedTotals),
            clearError: true,
          ),
        );
        return;
      }

      log(
        'Summary data unavailable for device $summaryId, falling back to device-level aggregation.',
        name: 'GesConsumptionCubit',
      );
    }

    if (deviceIds.isEmpty) {
      emit(
        state.copyWith(
          loading: false,
          data: const <String, double>{},
          clearError: true,
        ),
      );
      return;
    }

    if (!forceRefresh) {
      final cached = _cache[deviceCacheKey];
      if (cached != null) {
        emit(
          state.copyWith(
            loading: false,
            data: Map<String, double>.from(cached),
            clearError: true,
          ),
        );
        return;
      }
    }

    final groups = <String, _GesGroupAggregator>{};

    try {
      for (final device in devices) {
        final result = await _fetchUseCase(
          FetchEnergyConsumptionParams(
            username: username,
            password: password,
            deviceId: device.id,
            periodType: periodType,
            type: type,
            totalCheckPt: totalCheckPt,
            term: term,
          ),
        );

        if (!result.isSuccess) {
          emit(
            state.copyWith(
              loading: false,
              error: result.errorDescription ?? 'ges_consumption_error',
            ),
          );
          return;
        }

        final description = result.deviceDescription.trim();
        final amount = EnergyValueParser.parse(result.consumptionAmount);
        final normalizedDescription = _normalizeLabel(description);
        log(
          'GES consumption received for ${device.id}: '
          'description="$description", amountRaw="${result.consumptionAmount}", '
          'amountParsed=$amount',
          name: 'GesConsumptionCubit',
        );
        if (description.isEmpty || amount <= 0) {
          log(
            'Skipping device ${device.id} because description or amount is invalid '
            '(description="$description", amountParsed=$amount).',
            name: 'GesConsumptionCubit',
          );
          continue;
        }

        final lowerDescription = description.toLowerCase();

        final passesExact = allowedLower == null ||
            allowedLower.isEmpty ||
            allowedLower.contains(lowerDescription);

        final passesNormalized = allowedNormalized == null ||
            allowedNormalized.isEmpty ||
            (allowedNormalized.contains(normalizedDescription) &&
                _isTotalLabel(description));

        if (!passesExact && !passesNormalized) {
          log(
            'Skipping device ${device.id} because "$description" is not in the allowed caption list.',
            name: 'GesConsumptionCubit',
          );
          continue;
        }

        final baseLabel = _extractBaseLabel(description);
        if (baseLabel.isEmpty) {
          log(
            'Skipping device ${device.id} because base label could not be extracted '
            'from description "$description".',
            name: 'GesConsumptionCubit',
          );
          continue;
        }

        final groupKey = baseLabel.toLowerCase();
        final group =
            groups.putIfAbsent(groupKey, () => _GesGroupAggregator(baseLabel));
        if (_isTotalLabel(description)) {
          group.registerTotal(description, amount);
        } else {
          group.addPartial(amount);
        }
      }

      final totals = <String, double>{};
      for (final group in groups.values) {
        final entry = group.toMapEntry();
        if (entry != null) {
          totals[entry.key] = entry.value;
        }
      }

      final normalizedTotals = Map<String, double>.unmodifiable(totals);
      final debugTotals = normalizedTotals.map(
        (key, value) => MapEntry(key, value.toStringAsFixed(2)),
      );
      log(
        'GES pie chart totals prepared from ${devices.length} device requests: $debugTotals',
        name: 'GesConsumptionCubit',
      );
      _cache[deviceCacheKey] = normalizedTotals;

      emit(
        state.copyWith(
          loading: false,
          data: Map<String, double>.from(normalizedTotals),
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          error: error.toString(),
        ),
      );
    }
  }

  Future<Map<String, double>?> _fetchSummaryTotals({
    required String username,
    required String password,
    required String deviceId,
    required String periodType,
    required String type,
    required String totalCheckPt,
    required String term,
    Set<String>? allowedLower,
    Set<String>? allowedNormalized,
  }) async {
    try {
      final result = await _fetchUseCase(
        FetchEnergyConsumptionParams(
          username: username,
          password: password,
          deviceId: deviceId,
          periodType: periodType,
          type: type,
          totalCheckPt: totalCheckPt,
          term: term,
        ),
      );

      if (!result.isSuccess) {
        log(
          'Summary request for $deviceId failed: ${result.errorDescription ?? 'unknown error'}',
          name: 'GesConsumptionCubit',
        );
        return null;
      }

      if (result.entries.isEmpty) {
        log(
          'Summary request for $deviceId returned no entries.',
          name: 'GesConsumptionCubit',
        );
        return null;
      }

      final totals = <String, double>{};
      for (final entry in result.entries) {
        final description = entry.deviceDescription.trim();
        final amount = EnergyValueParser.parse(entry.consumptionAmount);
        final normalizedDescription = _normalizeLabel(description);
        final lowerDescription = description.toLowerCase();
        log(
          'GES summary entry for $deviceId: '
          'description="$description", amountRaw="${entry.consumptionAmount}", '
          'amountParsed=$amount',
          name: 'GesConsumptionCubit',
        );
        if (description.isEmpty || amount <= 0) {
          continue;
        }

        final passesExact = allowedLower == null ||
            allowedLower.isEmpty ||
            allowedLower.contains(lowerDescription);

        final passesNormalized = allowedNormalized == null ||
            allowedNormalized.isEmpty ||
            (allowedNormalized.contains(normalizedDescription) &&
                _isTotalLabel(description));

        if (!passesExact && !passesNormalized) {
          log(
            'Skipping summary entry "$description" because it is not in the allowed caption list.',
            name: 'GesConsumptionCubit',
          );
          continue;
        }

        totals.update(description, (value) => value + amount,
            ifAbsent: () => amount);
      }

      return totals.isEmpty ? null : totals;
    } catch (error, stackTrace) {
      log(
        'Summary request for $deviceId threw an error: $error',
        name: 'GesConsumptionCubit',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  String _extractBaseLabel(String description) {
    final trimmed = description.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final lower = trimmed.toLowerCase();
    final gesIndex = lower.indexOf('ges');
    if (gesIndex == -1) {
      return trimmed;
    }

    final prefix = trimmed.substring(0, gesIndex).trim();
    var sanitizedPrefix = prefix.replaceAll(RegExp(r'[-_/]*\d+$'), '');
    sanitizedPrefix =
        sanitizedPrefix.replaceAll(RegExp(r'[-_/]+\s*$'), '').trim();

    final cleanedPrefix = sanitizedPrefix.isEmpty ? prefix : sanitizedPrefix;
    final base = '$cleanedPrefix GES'.replaceAll(RegExp(r'\s+'), ' ').trim();
    return base.isEmpty ? trimmed : base;
  }

  bool _isTotalLabel(String description) {
    final lower = description.toLowerCase();
    return lower.contains('toplam') || lower.contains('total');
  }

  String _normalizeLabel(String label) {
    var normalized = label.toLowerCase().trim();
    if (normalized.isEmpty) {
      return normalized;
    }

    normalized = normalized.replaceAll('toplam', '');
    normalized = normalized.replaceAll('total', '');
    normalized = normalized.replaceAll(RegExp(r'[-_/]'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\d+'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\btr\b'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }
}

class _GesGroupAggregator {
  _GesGroupAggregator(this.baseLabel);

  final String baseLabel;
  String? _totalLabel;
  double _totalValue = 0;
  double _partialSum = 0;

  void registerTotal(String label, double value) {
    _totalLabel ??= label;
    _totalValue += value;
  }

  void addPartial(double value) {
    _partialSum += value;
  }

  MapEntry<String, double>? toMapEntry() {
    if (_totalLabel != null && _totalValue > 0) {
      return MapEntry<String, double>(_totalLabel!, _totalValue);
    }
    if (_partialSum > 0) {
      return MapEntry<String, double>(baseLabel, _partialSum);
    }
    return null;
  }
}

class _GesConsumptionCacheKey {
  const _GesConsumptionCacheKey({
    required this.username,
    required this.deviceIds,
    required this.periodType,
    required this.type,
    required this.totalCheckPt,
    required this.term,
    this.summaryDeviceId,
    this.useSummaryDevice = false,
    this.labelsSignature,
  });

  final String username;
  final List<String> deviceIds;
  final String periodType;
  final String type;
  final String totalCheckPt;
  final String term;
  final String? summaryDeviceId;
  final bool useSummaryDevice;
  final String? labelsSignature;

  static const ListEquality<String> _listEquality = ListEquality<String>();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! _GesConsumptionCacheKey) {
      return false;
    }

    return username == other.username &&
        periodType == other.periodType &&
        type == other.type &&
        totalCheckPt == other.totalCheckPt &&
        term == other.term &&
        useSummaryDevice == other.useSummaryDevice &&
        summaryDeviceId == other.summaryDeviceId &&
        labelsSignature == other.labelsSignature &&
        _listEquality.equals(deviceIds, other.deviceIds);
  }

  @override
  int get hashCode => Object.hash(
        username,
        periodType,
        type,
        totalCheckPt,
        term,
        summaryDeviceId,
        useSummaryDevice,
        labelsSignature,
        _listEquality.hash(deviceIds),
      );
}
