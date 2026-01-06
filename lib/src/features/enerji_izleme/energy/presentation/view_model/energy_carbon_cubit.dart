import 'package:controlapp/src/core/presentation/safe_cubit.dart';

import '../../domain/entities/energy_consumption.dart';
import '../../domain/usecases/fetch_energy_consumption_usecase.dart';
import '../../domain/utils/energy_value_parser.dart';
import 'energy_carbon_state.dart';
import 'energy_consumption_cache.dart';

class EnergyCarbonCubit extends SafeCubit<EnergyCarbonState> {
  EnergyCarbonCubit({
    required FetchEnergyConsumptionUseCase fetchUseCase,
    double carbonFactor = 0.456,
    double treeFactor = 2.673,
    double naturalGasFactor = 1.93,
  })  : _fetchUseCase = fetchUseCase,
        _carbonFactor = carbonFactor,
        _treeFactor = treeFactor,
        _naturalGasFactor = naturalGasFactor,
        super(const EnergyCarbonState());

  final FetchEnergyConsumptionUseCase _fetchUseCase;
  final double _carbonFactor;
  final double _treeFactor;
  final double _naturalGasFactor;

  Future<void> load({
    required String username,
    required String password,
    required String consumptionDeviceId,
    String? productionDeviceId,
    String? gasDeviceId,
    required String periodType,
    required String type,
    required String totalCheckPt,
    required String term,
    bool forceRefresh = false,
  }) async {
    final consumptionId = consumptionDeviceId.trim();
    final productionId = _normalizeId(productionDeviceId);
    final gasId = _normalizeId(gasDeviceId);

    final cachedConsumption = forceRefresh
        ? null
        : EnergyConsumptionCache.get(
            username: username,
            deviceId: consumptionId,
            periodType: periodType,
            type: type,
            totalCheckPt: totalCheckPt,
            term: term,
          );
    final cachedProduction = !forceRefresh && productionId != null
        ? EnergyConsumptionCache.get(
            username: username,
            deviceId: productionId,
            periodType: periodType,
            type: type,
            totalCheckPt: totalCheckPt,
            term: term,
          )
        : null;
    final cachedGas = !forceRefresh && gasId != null
        ? EnergyConsumptionCache.get(
            username: username,
            deviceId: gasId,
            periodType: periodType,
            type: type,
            totalCheckPt: totalCheckPt,
            term: term,
          )
        : null;

    final hasCachedConsumption = cachedConsumption != null;
    final hasCachedProduction =
        productionId == null || cachedProduction != null;
    final hasCachedGas = gasId == null || cachedGas != null;

    if (hasCachedConsumption && hasCachedProduction && hasCachedGas) {
      _emitWithResults(
        consumption: cachedConsumption!,
        production: cachedProduction,
        gasConsumption: cachedGas,
      );
      return;
    }

    emit(
      state.copyWith(
        loading: true,
        clearError: true,
        clearProduction: true,
        clearGas: gasId != null,
      ),
    );
    try {
      final futures = <Future<EnergyConsumption>>[];
      if (!hasCachedConsumption) {
        futures.add(
          _fetchUseCase(
            FetchEnergyConsumptionParams(
              username: username,
              password: password,
              deviceId: consumptionId,
              periodType: periodType,
              type: type,
              totalCheckPt: totalCheckPt,
              term: term,
            ),
          ),
        );
      }

      if (productionId != null && !hasCachedProduction) {
        futures.add(
          _fetchUseCase(
            FetchEnergyConsumptionParams(
              username: username,
              password: password,
              deviceId: productionId,
              periodType: periodType,
              type: type,
              totalCheckPt: totalCheckPt,
              term: term,
            ),
          ),
        );
      }

      if (gasId != null && !hasCachedGas) {
        futures.add(
          _fetchUseCase(
            FetchEnergyConsumptionParams(
              username: username,
              password: password,
              deviceId: gasId,
              periodType: periodType,
              type: type,
              totalCheckPt: totalCheckPt,
              term: term,
            ),
          ),
        );
      }

      final results =
          futures.isEmpty ? <EnergyConsumption>[] : await Future.wait(futures);
      var index = 0;

      final consumption =
          hasCachedConsumption ? cachedConsumption! : results[index++];
      EnergyConsumption? production;
      if (productionId != null) {
        production = hasCachedProduction ? cachedProduction : results[index++];
      }
      EnergyConsumption? gasConsumption;
      if (gasId != null) {
        gasConsumption = hasCachedGas ? cachedGas : results[index++];
      }

      if (!consumption.isSuccess) {
        emit(
          state.copyWith(
            loading: false,
            consumption: consumption,
            error: consumption.errorDescription ?? 'energy_consumption_error',
          ),
        );
        return;
      }

      if (production != null && !production.isSuccess) {
        emit(
          state.copyWith(
            loading: false,
            consumption: consumption,
            production: production,
            error: production.errorDescription ?? 'energy_consumption_error',
          ),
        );
        return;
      }

      if (gasConsumption != null && !gasConsumption.isSuccess) {
        emit(
          state.copyWith(
            loading: false,
            consumption: consumption,
            production: production,
            gasConsumption: gasConsumption,
            error:
                gasConsumption.errorDescription ?? 'energy_consumption_error',
          ),
        );
        return;
      }

      EnergyConsumptionCache.put(
        username: username,
        deviceId: consumption.deviceId,
        periodType: periodType,
        type: type,
        totalCheckPt: totalCheckPt,
        term: term,
        value: consumption,
      );
      if (production != null) {
        EnergyConsumptionCache.put(
          username: username,
          deviceId: production.deviceId,
          periodType: periodType,
          type: type,
          totalCheckPt: totalCheckPt,
          term: term,
          value: production,
        );
      }

      if (gasConsumption != null) {
        EnergyConsumptionCache.put(
          username: username,
          deviceId: gasConsumption.deviceId,
          periodType: periodType,
          type: type,
          totalCheckPt: totalCheckPt,
          term: term,
          value: gasConsumption,
        );
      }

      _emitWithResults(
        consumption: consumption,
        production: production,
        gasConsumption: gasConsumption,
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

  void _emitWithResults({
    required EnergyConsumption consumption,
    EnergyConsumption? production,
    EnergyConsumption? gasConsumption,
  }) {
    final consumptionValue =
        EnergyValueParser.parse(consumption.consumptionValue);
    final productionValue =
        EnergyValueParser.parse(production?.consumptionValue);
    final gasValue = EnergyValueParser.parse(gasConsumption?.consumptionValue);
    final electricityGrossKg = consumptionValue * _carbonFactor;
    final electricityAvoidedKg = productionValue * _carbonFactor;
    final gasKg = gasValue * _naturalGasFactor;
    final electricityNetKg = electricityGrossKg - electricityAvoidedKg;
    final electricityEmissionTon = electricityNetKg / 1000;
    final gasEmissionTon = gasKg / 1000;
    final carbonEmissionTon = electricityEmissionTon + gasEmissionTon;
    final treeCount = carbonEmissionTon * _treeFactor;
    final netDifference = electricityNetKg + gasKg;

    emit(
      state.copyWith(
        loading: false,
        consumption: consumption,
        production: production,
        gasConsumption: gasConsumption,
        consumptionValue: consumptionValue,
        productionValue: productionValue,
        gasValue: gasValue,
        difference: netDifference,
        carbonEmissionTon: carbonEmissionTon,
        treeCount: treeCount,
        gasEmissionTon: gasEmissionTon,
        clearError: true,
      ),
    );
  }

  String? _normalizeId(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
