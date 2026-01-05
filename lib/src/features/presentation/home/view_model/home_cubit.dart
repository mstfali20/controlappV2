import 'package:controlapp/src/core/presentation/safe_cubit.dart';
import 'package:xml/xml.dart' as xml;

import 'package:controlapp/const/data.dart' as legacy_data;
import 'package:controlapp/src/features/climate/domain/entities/climate_snapshot.dart';
import 'package:controlapp/src/features/climate/domain/usecases/fetch_climate_snapshot_usecase.dart';
import 'package:controlapp/src/features/energy/domain/entities/energy_snapshot.dart';
import 'package:controlapp/src/features/energy/domain/usecases/fetch_energy_snapshot_usecase.dart';
import 'package:controlapp/src/features/auth/domain/entities/session.dart';
import 'package:controlapp/src/features/auth/domain/usecases/get_session_usecase.dart';
import 'package:controlapp/src/features/auth/domain/usecases/update_session_selection_usecase.dart';
import 'package:controlapp/data/xmlModel.dart';
import 'home_state.dart';

class HomeCubit extends SafeCubit<HomeState> {
  HomeCubit({
    required FetchClimateSnapshotUseCase fetchClimateSnapshotUseCase,
    required FetchEnergySnapshotUseCase fetchEnergySnapshotUseCase,
    required GetSessionUseCase getSessionUseCase,
    required UpdateSessionSelectionUseCase updateSessionSelectionUseCase,
  })  : _fetchClimateSnapshotUseCase = fetchClimateSnapshotUseCase,
        _fetchEnergySnapshotUseCase = fetchEnergySnapshotUseCase,
        _getSessionUseCase = getSessionUseCase,
        _updateSessionSelectionUseCase = updateSessionSelectionUseCase,
        super(const HomeState());

  final FetchClimateSnapshotUseCase _fetchClimateSnapshotUseCase;
  final FetchEnergySnapshotUseCase _fetchEnergySnapshotUseCase;
  final GetSessionUseCase _getSessionUseCase;
  final UpdateSessionSelectionUseCase _updateSessionSelectionUseCase;

  static const energyModuleCaption = 'Enerji İzleme Sistemi';
  static const climateModuleCaption = 'Klima Santrali İzleme Sistemi';
  static const _energyModule = energyModuleCaption;
  static const _climateModule = climateModuleCaption;

  Future<void> initialize() async {
    emit(state.copyWith(status: HomeStatus.loading, clearError: true));

    try {
      final session = await _getSessionUseCase();
      if (session == null) {
        emit(
          state.copyWith(
            status: HomeStatus.failure,
            errorMessage: 'Oturum bulunamadı. Lütfen yeniden giriş yapın.',
          ),
        );
        return;
      }

      _syncLegacySelection(session);

      final selectedModule =
          session.extras['selected_module']?.toString() ?? _energyModule;
      final serial = session.serial;
      final serialTitle = session.serialTitle;
      final plcTitle = session.plcTitle;
      final treeXml = session.treeXml;

      final userSummary = HomeUserSummary(
        fullName: '${session.user.name} ${session.user.lastname}'.trim(),
        firstName: session.user.name,
        lastName: session.user.lastname,
        imageUrl: session.user.imageUrl,
        firmName: session.user.firmName,
      );

      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          session: session,
          userSummary: userSummary,
          username: session.username,
          password: session.password,
          selectedModule: selectedModule,
          selectedDeviceId: serial,
          selectedDeviceTitle: serialTitle,
          plcTitle: plcTitle,
          treeXml: treeXml,
          clearError: true,
        ),
      );

      if (serial != null && serial.isNotEmpty) {
        await refreshDevice(
          serial,
          forceRefresh: false,
          persistSelection: false,
        );
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> refreshCurrentDevice({bool forceRefresh = false}) async {
    final deviceId = state.selectedDeviceId;
    if (deviceId == null || deviceId.isEmpty) {
      return;
    }
    await refreshDevice(deviceId, forceRefresh: forceRefresh);
  }

  Future<void> refreshDevice(
    String deviceId, {
    bool forceRefresh = false,
    bool persistSelection = true,
  }) async {
    final username = state.username;
    final password = state.password;

    if (username == null ||
        password == null ||
        username.isEmpty ||
        password.isEmpty) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage:
              'Kullanıcı bilgileri eksik. Lütfen yeniden giriş yapın.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: HomeStatus.loading, clearError: true));

    final module = state.selectedModule ?? _energyModule;

    try {
      if (module == _climateModule) {
        final snapshot = await _fetchClimateSnapshot(
          username: username,
          password: password,
          deviceId: deviceId,
        );

        if (!snapshot.isSuccess) {
          await _handleClimateFallback(
            username: username,
            password: password,
            deviceId: deviceId,
          );
          return;
        }

        _syncLegacySnapshot(snapshot.values);
        if (persistSelection) {
          await _persistSelection(
            serial: deviceId,
            serialTitle: state.selectedDeviceTitle,
            plcTitle: state.plcTitle,
            module: _climateModule,
          );
        }

        emit(
          state.copyWith(
            status: HomeStatus.loaded,
            snapshot: snapshot.values,
            selectedDeviceId: deviceId,
            selectedModule: _climateModule,
            isFallbackToEnergy: false,
          ),
        );
        return;
      }

      final energySnapshot = await _fetchEnergySnapshot(
        username: username,
        password: password,
        deviceId: deviceId,
      );

      _syncLegacySnapshot(energySnapshot.values);
      if (persistSelection) {
        await _persistSelection(
          serial: deviceId,
          serialTitle: state.selectedDeviceTitle,
          plcTitle: state.plcTitle,
          module: _energyModule,
        );
      }

      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          snapshot: energySnapshot.values,
          selectedDeviceId: deviceId,
          selectedModule: _energyModule,
          isFallbackToEnergy: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> changeDevice({
    required String deviceId,
    required String deviceTitle,
    String? plcTitle,
    String? module,
    String? organizationId,
  }) async {
    final targetModule = module ?? state.selectedModule ?? _energyModule;

    emit(
      state.copyWith(
        selectedDeviceId: deviceId,
        selectedDeviceTitle: deviceTitle,
        plcTitle: plcTitle ?? state.plcTitle,
        selectedModule: targetModule,
      ),
    );

    await _persistSelection(
      serial: deviceId,
      serialTitle: deviceTitle,
      plcTitle: plcTitle,
      module: targetModule,
      organizationId: organizationId ?? state.session?.selectedOrganizationId,
    );

    await refreshDevice(deviceId, forceRefresh: true, persistSelection: false);
  }

  Future<void> changeModule(String moduleCaption) async {
    if (state.selectedModule == moduleCaption) {
      return;
    }

    final updatedModule = moduleCaption;
    emit(state.copyWith(selectedModule: updatedModule));

    await _persistSelection(module: updatedModule);
    await refreshCurrentDevice(forceRefresh: true);
  }

  Future<List<XmlModel>> loadTreeNodes() async {
    final source = state.treeXml ?? state.session?.treeXml ?? '';
    if (source.isEmpty) {
      return const [];
    }

    try {
      final document = xml.XmlDocument.parse(source);
      final nodes = document.findAllElements('node').toList();
      return nodes.map(XmlModel.fromXml).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<ClimateSnapshot> _fetchClimateSnapshot({
    required String username,
    required String password,
    required String deviceId,
  }) {
    return _fetchClimateSnapshotUseCase(
      FetchClimateSnapshotParams(
        username: username,
        password: password,
        deviceId: deviceId,
      ),
    );
  }

  Future<EnergySnapshot> _fetchEnergySnapshot({
    required String username,
    required String password,
    required String deviceId,
  }) {
    return _fetchEnergySnapshotUseCase(
      FetchEnergySnapshotParams(
        username: username,
        password: password,
        deviceId: deviceId,
      ),
    );
  }

  Future<void> _handleClimateFallback({
    required String username,
    required String password,
    required String deviceId,
  }) async {
    try {
      final snapshot = await _fetchEnergySnapshot(
        username: username,
        password: password,
        deviceId: deviceId,
      );
      _syncLegacySnapshot(snapshot.values);
      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          snapshot: snapshot.values,
          selectedModule: _energyModule,
          isFallbackToEnergy: true,
          clearError: true,
        ),
      );

      await _persistSelection(
        module: _energyModule,
        serial: deviceId,
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _persistSelection({
    String? serial,
    String? serialTitle,
    String? plcTitle,
    String? module,
    String? organizationId,
    String? treeXml,
    Map<String, dynamic>? extras,
  }) async {
    try {
      final updatedSession = await _updateSessionSelectionUseCase(
        UpdateSessionSelectionParams(
          serial: serial,
          serialTitle: serialTitle,
          plcTitle: plcTitle,
          selectedModule: module,
          selectedOrganizationId: organizationId,
          treeXml: treeXml,
          extras: extras,
        ),
      );

      emit(state.copyWith(session: updatedSession));
      _syncLegacySelection(updatedSession);
    } catch (_) {
      // Oturum güncellemesi başarısız olsa bile kullanıcı akışını durdurma.
    }
  }

  void _syncLegacySelection(Session session) {
    if (session.serial != null && session.serial!.isNotEmpty) {
      legacy_data.serial = session.serial!;
    }
    if (session.serialTitle != null && session.serialTitle!.isNotEmpty) {
      legacy_data.serialTitle = session.serialTitle!;
    }
    if (session.plcTitle != null && session.plcTitle!.isNotEmpty) {
      legacy_data.plcTitle = session.plcTitle!;
    }
    if (session.selectedOrganizationId != null &&
        session.selectedOrganizationId!.isNotEmpty) {
      legacy_data.organizationid = session.selectedOrganizationId!;
    }
    if (session.treeXml != null && session.treeXml!.isNotEmpty) {
      legacy_data.xmlString = session.treeXml!;
    }

    final module = session.extras['selected_module']?.toString();
    if (module != null && module.isNotEmpty) {
      legacy_data.selectedModule = module;
      legacy_data.userDataConst['selected_module'] = module;
    }
  }

  void _syncLegacySnapshot(Map<String, String> snapshot) {
    legacy_data.anaAnlikVeriMap
      ..clear()
      ..addAll(snapshot);
  }
}
