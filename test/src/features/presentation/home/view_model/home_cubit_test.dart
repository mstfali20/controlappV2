import 'package:controlapp/const/data.dart' as legacy_data;
import 'package:controlapp/src/features/auth/domain/entities/app_user.dart';
import 'package:controlapp/src/features/auth/domain/entities/session.dart';
import 'package:controlapp/src/features/auth/domain/usecases/get_session_usecase.dart';
import 'package:controlapp/src/features/auth/domain/usecases/update_session_selection_usecase.dart';
import 'package:controlapp/src/features/climate/domain/entities/climate_snapshot.dart';
import 'package:controlapp/src/features/climate/domain/usecases/fetch_climate_snapshot_usecase.dart';
import 'package:controlapp/src/features/energy/domain/entities/energy_snapshot.dart';
import 'package:controlapp/src/features/energy/domain/usecases/fetch_energy_snapshot_usecase.dart';
import 'package:controlapp/src/features/presentation/home/view_model/home_cubit.dart';
import 'package:controlapp/src/features/presentation/home/view_model/home_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFetchClimateSnapshotUseCase extends Mock
    implements FetchClimateSnapshotUseCase {}

class _MockFetchEnergySnapshotUseCase extends Mock
    implements FetchEnergySnapshotUseCase {}

class _MockGetSessionUseCase extends Mock implements GetSessionUseCase {}

class _MockUpdateSessionSelectionUseCase extends Mock
    implements UpdateSessionSelectionUseCase {}

void main() {
  late _MockFetchClimateSnapshotUseCase fetchClimateUseCase;
  late _MockFetchEnergySnapshotUseCase fetchEnergyUseCase;
  late _MockGetSessionUseCase getSessionUseCase;
  late _MockUpdateSessionSelectionUseCase updateSessionSelectionUseCase;
  late HomeCubit cubit;

  const energyModule = HomeCubit.energyModuleCaption;
  const climateModule = HomeCubit.climateModuleCaption;

  setUpAll(() {
    registerFallbackValue(
      const FetchClimateSnapshotParams(
        username: '',
        password: '',
        deviceId: '',
      ),
    );
    registerFallbackValue(
      const FetchEnergySnapshotParams(
        username: '',
        password: '',
        deviceId: '',
      ),
    );
    registerFallbackValue(const UpdateSessionSelectionParams());
  });

  setUp(() {
    fetchClimateUseCase = _MockFetchClimateSnapshotUseCase();
    fetchEnergyUseCase = _MockFetchEnergySnapshotUseCase();
    getSessionUseCase = _MockGetSessionUseCase();
    updateSessionSelectionUseCase = _MockUpdateSessionSelectionUseCase();

    cubit = HomeCubit(
      fetchClimateSnapshotUseCase: fetchClimateUseCase,
      fetchEnergySnapshotUseCase: fetchEnergyUseCase,
      getSessionUseCase: getSessionUseCase,
      updateSessionSelectionUseCase: updateSessionSelectionUseCase,
    );

    legacy_data.userDataConst.clear();
    legacy_data.serial = '';
    legacy_data.serialTitle = '';
    legacy_data.plcTitle = '';
    legacy_data.selectedModule = energyModule;
    legacy_data.treeJson = '';
    legacy_data.anaAnlikVeriMap.clear();
  });

  Session buildSession({
    String? selectedModule,
  }) {
    return Session(
      username: 'demo',
      password: 'pass',
      user: const AppUser(
        username: 'demo',
        name: 'Demo',
        lastname: 'User',
        email: 'demo@test.dev',
        userId: 1,
        firmName: 'Demo Firm',
        pages: [],
        unitPrices: {},
      ),
      serial: 'device-1',
      serialTitle: 'Demo Device',
      plcTitle: 'Demo PLC',
      extras: {
        if (selectedModule != null) 'selected_module': selectedModule,
      },
    );
  }

  group('initialize', () {
    test('loads session and fetches energy snapshot successfully', () async {
      final session = buildSession(selectedModule: energyModule);
      when(() => getSessionUseCase()).thenAnswer((_) async => session);
      when(() => fetchEnergyUseCase(any())).thenAnswer(
        (_) async => const EnergySnapshot(
          deviceId: 'device-1',
          values: {'key': 'value'},
        ),
      );
      when(() => updateSessionSelectionUseCase(any()))
          .thenAnswer((_) async => session);

      await cubit.initialize();

      expect(cubit.state.status, HomeStatus.loaded);
      expect(cubit.state.selectedDeviceId, 'device-1');
      expect(cubit.state.snapshot['key'], 'value');
    });

    test('falls back to energy when climate snapshot fails', () async {
      final session = buildSession(selectedModule: climateModule);
      when(() => getSessionUseCase()).thenAnswer((_) async => session);
      when(() => fetchClimateUseCase(any())).thenAnswer(
        (_) async => const ClimateSnapshot(
          deviceId: 'device-1',
          values: {},
          errorCode: 1,
          errorDescription: 'fail',
        ),
      );
      when(() => fetchEnergyUseCase(any())).thenAnswer(
        (_) async => const EnergySnapshot(
          deviceId: 'device-1',
          values: {'energy': 'ok'},
        ),
      );
      when(() => updateSessionSelectionUseCase(any()))
          .thenAnswer((_) async => session);

      await cubit.initialize();

      expect(cubit.state.selectedModule, energyModule);
      expect(cubit.state.isFallbackToEnergy, isTrue);
      expect(cubit.state.snapshot['energy'], 'ok');
    });
  });

  group('changeDevice', () {
    test('delegates to energy fetch and updates state', () async {
      final session = buildSession(selectedModule: energyModule);
      when(() => getSessionUseCase()).thenAnswer((_) async => session);
      when(() => fetchEnergyUseCase(any())).thenAnswer(
        (_) async => const EnergySnapshot(
          deviceId: 'device-2',
          values: {'energy': 'updated'},
        ),
      );
      when(() => updateSessionSelectionUseCase(any()))
          .thenAnswer((_) async => session.copyWith(serial: 'device-2'));

      await cubit.initialize();

      await cubit.changeDevice(
        deviceId: 'device-2',
        deviceTitle: 'Another Device',
      );

      expect(cubit.state.selectedDeviceId, 'device-2');
      expect(cubit.state.snapshot['energy'], 'updated');
    });
  });
}
