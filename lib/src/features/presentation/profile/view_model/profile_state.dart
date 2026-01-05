import 'package:equatable/equatable.dart';

import '../../home/view_model/home_state.dart';

enum ProfileStatus { initial, loading, loaded, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.userSummary = const HomeUserSummary(),
    this.selectedModule,
    this.selectedDeviceTitle,
    this.selectedDeviceId,
    this.plcTitle,
    this.treeJson,
    this.errorMessage,
    this.snackbarMessage,
  });

  final ProfileStatus status;
  final HomeUserSummary userSummary;
  final String? selectedModule;
  final String? selectedDeviceTitle;
  final String? selectedDeviceId;
  final String? plcTitle;
  final String? treeJson;
  final String? errorMessage;
  final String? snackbarMessage;

  bool get isLoading => status == ProfileStatus.loading;

  ProfileState copyWith({
    ProfileStatus? status,
    HomeUserSummary? userSummary,
    String? selectedModule,
    String? selectedDeviceTitle,
    String? selectedDeviceId,
    String? plcTitle,
    String? treeJson,
    String? errorMessage,
    String? snackbarMessage,
    bool clearError = false,
    bool clearSnackbar = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      userSummary: userSummary ?? this.userSummary,
      selectedModule: selectedModule ?? this.selectedModule,
      selectedDeviceTitle: selectedDeviceTitle ?? this.selectedDeviceTitle,
      selectedDeviceId: selectedDeviceId ?? this.selectedDeviceId,
      plcTitle: plcTitle ?? this.plcTitle,
      treeJson: treeJson ?? this.treeJson,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      snackbarMessage:
          clearSnackbar ? null : (snackbarMessage ?? this.snackbarMessage),
    );
  }

  factory ProfileState.fromHome(
    HomeState state, {
    ProfileState? previous,
  }) {
    return ProfileState(
      status: _mapStatus(state.status),
      userSummary: state.userSummary,
      selectedModule: state.selectedModule,
      selectedDeviceTitle: state.selectedDeviceTitle,
      selectedDeviceId: state.selectedDeviceId,
      plcTitle: state.plcTitle,
      treeJson: state.treeJson,
      errorMessage: state.errorMessage,
      snackbarMessage: previous?.snackbarMessage,
    );
  }

  static ProfileStatus _mapStatus(HomeStatus status) {
    switch (status) {
      case HomeStatus.initial:
        return ProfileStatus.initial;
      case HomeStatus.loading:
        return ProfileStatus.loading;
      case HomeStatus.loaded:
        return ProfileStatus.loaded;
      case HomeStatus.failure:
        return ProfileStatus.failure;
    }
  }

  @override
  List<Object?> get props => [
        status,
        userSummary,
        selectedModule,
        selectedDeviceTitle,
        selectedDeviceId,
        plcTitle,
        treeJson,
        errorMessage,
        snackbarMessage,
      ];
}
