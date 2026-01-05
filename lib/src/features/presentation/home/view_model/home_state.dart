import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/session.dart';

enum HomeStatus { initial, loading, loaded, failure }

class HomeUserSummary extends Equatable {
  const HomeUserSummary({
    this.fullName = '',
    this.firstName = '',
    this.lastName = '',
    this.imageUrl,
    this.firmName = '',
  });

  final String fullName;
  final String firstName;
  final String lastName;
  final String? imageUrl;
  final String firmName;

  HomeUserSummary copyWith({
    String? fullName,
    String? firstName,
    String? lastName,
    String? imageUrl,
    String? firmName,
  }) {
    return HomeUserSummary(
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      imageUrl: imageUrl ?? this.imageUrl,
      firmName: firmName ?? this.firmName,
    );
  }

  @override
  List<Object?> get props =>
      [fullName, firstName, lastName, imageUrl, firmName];
}

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.session,
    this.userSummary = const HomeUserSummary(),
    this.username,
    this.password,
    this.selectedModule,
    this.selectedDeviceId,
    this.selectedDeviceTitle,
    this.plcTitle,
    this.snapshot = const {},
    this.errorMessage,
    this.treeXml,
    this.isFallbackToEnergy = false,
  });

  final HomeStatus status;
  final Session? session;
  final HomeUserSummary userSummary;
  final String? username;
  final String? password;
  final String? selectedModule;
  final String? selectedDeviceId;
  final String? selectedDeviceTitle;
  final String? plcTitle;
  final Map<String, String> snapshot;
  final String? errorMessage;
  final String? treeXml;
  final bool isFallbackToEnergy;

  bool get isLoading => status == HomeStatus.loading;

  HomeState copyWith({
    HomeStatus? status,
    Session? session,
    HomeUserSummary? userSummary,
    String? username,
    String? password,
    String? selectedModule,
    String? selectedDeviceId,
    String? selectedDeviceTitle,
    String? plcTitle,
    Map<String, String>? snapshot,
    String? errorMessage,
    String? treeXml,
    bool? isFallbackToEnergy,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      session: session ?? this.session,
      userSummary: userSummary ?? this.userSummary,
      username: username ?? this.username,
      password: password ?? this.password,
      selectedModule: selectedModule ?? this.selectedModule,
      selectedDeviceId: selectedDeviceId ?? this.selectedDeviceId,
      selectedDeviceTitle: selectedDeviceTitle ?? this.selectedDeviceTitle,
      plcTitle: plcTitle ?? this.plcTitle,
      snapshot: snapshot ?? this.snapshot,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      treeXml: treeXml ?? this.treeXml,
      isFallbackToEnergy: isFallbackToEnergy ?? this.isFallbackToEnergy,
    );
  }

  @override
  List<Object?> get props => [
        status,
        session,
        userSummary,
        username,
        password,
        selectedModule,
        selectedDeviceId,
        selectedDeviceTitle,
        plcTitle,
        snapshot,
        errorMessage,
        treeXml,
        isFallbackToEnergy,
      ];
}
