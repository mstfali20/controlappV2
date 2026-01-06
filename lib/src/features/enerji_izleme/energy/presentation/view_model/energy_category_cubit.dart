import 'package:controlapp/src/core/presentation/safe_cubit.dart';

import '../../domain/usecases/fetch_energy_category_breakdown_usecase.dart';
import 'energy_category_state.dart';

class EnergyCategoryCubit extends SafeCubit<EnergyCategoryState> {
  EnergyCategoryCubit({
    required FetchEnergyCategoryBreakdownUseCase fetchUseCase,
  })  : _fetchUseCase = fetchUseCase,
        super(const EnergyCategoryState());

  final FetchEnergyCategoryBreakdownUseCase _fetchUseCase;

  Future<void> load({
    required String username,
    required String password,
    required String organizationId,
    required String periodType,
    required String term,
  }) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final breakdown = await _fetchUseCase(
        FetchEnergyCategoryBreakdownParams(
          username: username,
          password: password,
          organizationId: organizationId,
          periodType: periodType,
          term: term,
        ),
      );

      if (!breakdown.isSuccess) {
        emit(
          state.copyWith(
            loading: false,
            breakdown: breakdown,
            error: breakdown.errorDescription ?? 'energy_category_error',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          loading: false,
          breakdown: breakdown,
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
