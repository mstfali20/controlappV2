import 'package:controlapp/src/core/presentation/safe_cubit.dart';

import '../../domain/usecases/fetch_energy_snapshot_usecase.dart';
import '../../domain/usecases/get_cached_snapshot_usecase.dart';
import 'energy_state.dart';

class EnergyCubit extends SafeCubit<EnergyState> {
  EnergyCubit({
    required FetchEnergySnapshotUseCase fetchUseCase,
    required GetCachedSnapshotUseCase getCachedUseCase,
  })  : _fetchUseCase = fetchUseCase,
        _getCachedUseCase = getCachedUseCase,
        super(const EnergyState());

  final FetchEnergySnapshotUseCase _fetchUseCase;
  final GetCachedSnapshotUseCase _getCachedUseCase;

  Future<void> load({
    required String username,
    required String password,
    required String deviceId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _getCachedUseCase(deviceId);
      if (cached != null) {
        emit(
            state.copyWith(snapshot: cached, loading: false, clearError: true));
      }
    }

    emit(state.copyWith(loading: true, clearError: true));
    try {
      final snapshot = await _fetchUseCase(
        FetchEnergySnapshotParams(
          username: username,
          password: password,
          deviceId: deviceId,
        ),
      );
      emit(
          state.copyWith(loading: false, snapshot: snapshot, clearError: true));
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
