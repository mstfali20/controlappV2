import 'dart:developer';

import 'package:controlapp/src/core/presentation/safe_cubit.dart';
import 'package:controlapp/src/features/yenilenebilir_enerji/ges/domain/entities/renewable_energy_consumption_history.dart';

import '../../domain/usecases/fetch_renewable_consumption_history_usecase.dart';
import 'renewable_history_state.dart';

class RenewableHistoryCubit extends SafeCubit<RenewableHistoryState> {
  RenewableHistoryCubit({
    required FetchRenewableEnergyConsumptionHistoryUseCase fetchUseCase,
  })  : _fetchUseCase = fetchUseCase,
        super(const RenewableHistoryState());

  final FetchRenewableEnergyConsumptionHistoryUseCase _fetchUseCase;

  Future<RenewableEnergyConsumptionHistory?> load({
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
        FetchRenewableEnergyConsumptionHistoryParams(
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
            error: history.errorDescription ?? 'renewable_history_error',
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
      log('renewable_history_error', error: error);
      emit(state.copyWith(loading: false, error: error.toString()));
      return null;
    }
  }
}
