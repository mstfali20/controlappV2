import 'package:controlapp/src/core/presentation/safe_cubit.dart';

import '../../domain/usecases/fetch_energy_consumption_usecase.dart';
import 'energy_consumption_cache.dart';
import 'energy_consumption_state.dart';

class EnergyConsumptionCubit extends SafeCubit<EnergyConsumptionState> {
  EnergyConsumptionCubit({
    required FetchEnergyConsumptionUseCase fetchUseCase,
  })  : _fetchUseCase = fetchUseCase,
        super(const EnergyConsumptionState());

  final FetchEnergyConsumptionUseCase _fetchUseCase;

  Future<void> load({
    required String username,
    required String password,
    required String deviceId,
    required String periodType,
    required String type,
    required String totalCheckPt,
    required String term,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = EnergyConsumptionCache.get(
        username: username,
        deviceId: deviceId,
        periodType: periodType,
        type: type,
        totalCheckPt: totalCheckPt,
        term: term,
      );

      if (cached != null) {
        emit(
          state.copyWith(
            loading: false,
            data: cached,
            clearError: true,
          ),
        );
        return;
      }
    }

    emit(state.copyWith(loading: true, clearError: true));
    try {
      final data = await _fetchUseCase(
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

      if (!data.isSuccess) {
        emit(
          state.copyWith(
            loading: false,
            data: data,
            error: data.errorDescription ?? 'energy_consumption_error',
          ),
        );
        return;
      }

      EnergyConsumptionCache.put(
        username: username,
        deviceId: deviceId,
        periodType: periodType,
        type: type,
        totalCheckPt: totalCheckPt,
        term: term,
        value: data,
      );

      emit(
        state.copyWith(
          loading: false,
          data: data,
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
}
