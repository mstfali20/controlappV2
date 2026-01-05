import 'package:controlapp/src/core/presentation/safe_cubit.dart';

import '../../domain/entities/energy_consumption_history.dart';
import '../../domain/usecases/fetch_energy_consumption_history_usecase.dart';
import 'energy_history_state.dart';

class EnergyHistoryCubit extends SafeCubit<EnergyHistoryState> {
  EnergyHistoryCubit({
    required FetchEnergyConsumptionHistoryUseCase fetchUseCase,
  })  : _fetchUseCase = fetchUseCase,
        super(const EnergyHistoryState());

  final FetchEnergyConsumptionHistoryUseCase _fetchUseCase;

  Future<EnergyConsumptionHistory?> load({
    required String username,
    required String password,
    required String deviceId,
    required String periodType,
    required String type,
    required String totalCheckPt,
    required String term,
    required String startDate,
    required String endDate,
  }) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final history = await _fetchUseCase(
        FetchEnergyConsumptionHistoryParams(
          username: username,
          password: password,
          deviceId: deviceId,
          periodType: periodType,
          type: type,
          totalCheckPt: totalCheckPt,
          term: term,
          startDate: startDate,
          endDate: endDate,
        ),
      );

      if (!history.isSuccess) {
        emit(
          state.copyWith(
            loading: false,
            history: history,
            error: history.errorDescription ?? 'energy_history_error',
          ),
        );
        return history;
      }

      emit(
        state.copyWith(
          loading: false,
          history: history,
          clearError: true,
        ),
      );
      return history;
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          error: error.toString(),
        ),
      );
      return null;
    }
  }
}
