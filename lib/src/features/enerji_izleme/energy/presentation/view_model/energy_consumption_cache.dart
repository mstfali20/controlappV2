import '../../domain/entities/energy_consumption.dart';

class EnergyConsumptionCache {
  const EnergyConsumptionCache._();

  static final Map<_CacheKey, EnergyConsumption> _cache = {};

  static EnergyConsumption? get({
    required String username,
    required String deviceId,
    required String periodType,
    required String type,
    required String totalCheckPt,
    required String term,
  }) {
    final key = _CacheKey(
      username: username,
      deviceId: deviceId,
      periodType: periodType,
      type: type,
      totalCheckPt: totalCheckPt,
      term: term,
    );
    return _cache[key];
  }

  static void put({
    required String username,
    required String deviceId,
    required String periodType,
    required String type,
    required String totalCheckPt,
    required String term,
    required EnergyConsumption value,
  }) {
    final key = _CacheKey(
      username: username,
      deviceId: deviceId,
      periodType: periodType,
      type: type,
      totalCheckPt: totalCheckPt,
      term: term,
    );
    _cache[key] = value;
  }

  static void clear() => _cache.clear();
}

class _CacheKey {
  const _CacheKey({
    required this.username,
    required this.deviceId,
    required this.periodType,
    required this.type,
    required this.totalCheckPt,
    required this.term,
  });

  final String username;
  final String deviceId;
  final String periodType;
  final String type;
  final String totalCheckPt;
  final String term;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! _CacheKey) {
      return false;
    }

    return username == other.username &&
        deviceId == other.deviceId &&
        periodType == other.periodType &&
        type == other.type &&
        totalCheckPt == other.totalCheckPt &&
        term == other.term;
  }

  @override
  int get hashCode => Object.hash(
        username,
        deviceId,
        periodType,
        type,
        totalCheckPt,
        term,
      );
}
