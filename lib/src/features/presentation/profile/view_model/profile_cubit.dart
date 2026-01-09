import 'dart:async';

import 'package:controlapp/const/data.dart' as legacy_data;
import 'package:controlapp/data/tree_node.dart';
import 'package:controlapp/src/core/presentation/safe_cubit.dart';
import 'package:controlapp/src/features/auth/data/services/organization_service.dart';
import 'package:controlapp/src/core/config/tree_sections.dart';
import 'package:controlapp/src/core/utils/tree_selection.dart';

import '../../home/view_model/home_cubit.dart';
import '../../home/view_model/home_state.dart';
import 'profile_state.dart';

class ProfileCubit extends SafeCubit<ProfileState> {
  ProfileCubit({required HomeCubit homeCubit})
      : _homeCubit = homeCubit,
        super(ProfileState.fromHome(homeCubit.state)) {
    _subscription = _homeCubit.stream.listen(_onHomeStateChanged);
    _ensureOrganizationsLoaded();
  }

  final HomeCubit _homeCubit;
  late final StreamSubscription<HomeState> _subscription;

  Future<void> refreshDevice() async {
    await _homeCubit.refreshCurrentDevice(forceRefresh: true);
  }

  Future<void> selectOrganization(
    OrganizationData organization, {
    SectionData? section,
  }) async {
    emit(state.copyWith(status: ProfileStatus.loading, clearSnackbar: true));

    try {
      final nodes = await _homeCubit.loadTreeNodes();
      if (nodes.isEmpty) {
        emit(_failureState('Veri bulunamadı.'));
        return;
      }

      final normalizedCaption = organization.caption.trim();
      final organizationNode = nodes.firstWhere(
        (node) =>
            node.classType.trim() == 'obm_organization' &&
            node.id == organization.id,
        orElse: () => nodes.firstWhere(
          (node) =>
              node.classType.trim() == 'obm_organization' &&
              node.caption.trim() == normalizedCaption,
          orElse: TreeNode.empty,
        ),
      );

      if (_isNodeEmpty(organizationNode)) {
        emit(_failureState('Organizasyon bulunamadı.'));
        return;
      }

      final resolvedSection =
          section ?? _resolveSectionForCaption(normalizedCaption);
      final sectionId = resolvedSection?.id;
      final preferredCaptions =
          preferredDeviceCaptionsForSection(sectionId);
      final selectedDevice = findFirstDevice(
            organizationNode,
            preferredCaptions: preferredCaptions,
          ) ??
          TreeNode.empty();

      if (_isNodeEmpty(selectedDevice)) {
        emit(_failureState('Seçilebilecek cihaz bulunamadı.'));
        return;
      }

      final deviceId = selectedDevice.id;
      final deviceTitle = selectedDevice.caption.isNotEmpty
          ? selectedDevice.caption
          : (selectedDevice.title.isNotEmpty
              ? selectedDevice.title
              : selectedDevice.id);

      final moduleCaption = resolvedSection?.caption ?? organization.caption;
      await _homeCubit.changeModule(moduleCaption);
      await _homeCubit.changeDevice(
        deviceId: deviceId,
        deviceTitle: deviceTitle,
        plcTitle: deviceTitle,
        module: moduleCaption,
        organizationId: organizationNode.id,
      );

      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          snackbarMessage: 'İşletme seçildi',
        ),
      );
    } catch (error) {
      emit(_failureState(error.toString()));
    }
  }

  Future<void> clearSnackbar() async {
    emit(state.copyWith(clearSnackbar: true));
  }

  Future<List<TreeNode>> loadTreeNodes() {
    return _homeCubit.loadTreeNodes();
  }

  void _onHomeStateChanged(HomeState homeState) {
    emit(ProfileState.fromHome(homeState, previous: state));
  }

  void _ensureOrganizationsLoaded() {
    if (legacy_data.organizationList.isNotEmpty ||
        legacy_data.sectionList.isNotEmpty) {
      return;
    }

    if (legacy_data.treeJson.isNotEmpty) {
      populateOrganizationsFromTree(treeContent: legacy_data.treeJson);
      emit(state.copyWith(status: state.status));
      return;
    }

    Future.microtask(() async {
      final username = _homeCubit.state.username ??
          legacy_data.userDataConst['username']?.toString() ??
          '';
      final password = _homeCubit.state.password ??
          legacy_data.userDataConst['password']?.toString() ??
          '';
      if (username.isEmpty || password.isEmpty) {
        return;
      }

      emit(state.copyWith(status: ProfileStatus.loading));
      await OrganizationService().fetchOrganizations(username, password);
      emit(state.copyWith(status: ProfileStatus.loaded));
    });
  }

  SectionData? _resolveSectionForCaption(String caption) {
    final normalized = caption.trim();
    for (final section in legacy_data.sectionList) {
      for (final organization in section.organizations) {
        if (organization.caption.trim() == normalized) {
          return section;
        }
      }
    }
    return null;
  }

  bool _isNodeEmpty(TreeNode node) =>
      node.id.isEmpty && node.caption.isEmpty && node.children.isEmpty;

  ProfileState _failureState(String message) {
    return state.copyWith(
      status: ProfileStatus.failure,
      snackbarMessage: message,
    );
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
