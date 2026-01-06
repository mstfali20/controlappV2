import 'package:dio/dio.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get_it/get_it.dart';

import '../logging/logger.dart';
import '../network/dio_client.dart';
import '../storage/prefs.dart';
import '../../features/auth/data/datasources/auth_api.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/clear_session_usecase.dart';
import '../../features/auth/domain/usecases/get_session_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/save_session_usecase.dart';
import '../../features/enerji_izleme/energy/data/datasources/energy_remote_data_source.dart';
import '../../features/enerji_izleme/energy/data/repositories/energy_repository_impl.dart';
import '../../features/enerji_izleme/energy/domain/repositories/energy_repository.dart';
import '../../features/enerji_izleme/energy/domain/usecases/fetch_energy_snapshot_usecase.dart';
import '../../features/enerji_izleme/energy/domain/usecases/get_cached_snapshot_usecase.dart';
import '../../features/enerji_izleme/energy/domain/usecases/fetch_energy_consumption_usecase.dart';
import '../../features/enerji_izleme/energy/domain/usecases/fetch_energy_consumption_history_usecase.dart';
import '../../features/enerji_izleme/energy/domain/usecases/fetch_energy_category_breakdown_usecase.dart';
import '../../features/auth/domain/usecases/update_session_selection_usecase.dart';
import '../../features/yardimci_tesisler/climate/data/datasources/climate_remote_data_source.dart';
import '../../features/yardimci_tesisler/climate/data/repositories/climate_repository_impl.dart';
import '../../features/yardimci_tesisler/climate/domain/repositories/climate_repository.dart';
import '../../features/yardimci_tesisler/climate/domain/usecases/fetch_climate_snapshot_usecase.dart';
import '../../features/yardimci_tesisler/climate/domain/usecases/fetch_climate_history_usecase.dart';
import '../../features/presentation/notifications/data/datasources/notifications_remote_data_source.dart';
import '../../features/presentation/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/presentation/notifications/domain/repositories/notifications_repository.dart';
import '../../features/presentation/notifications/domain/usecases/fetch_notifications_usecase.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<AppLogger>()) {
    return;
  }

  getIt
    ..registerLazySingleton<AppLogger>(() => const AppLogger())
    ..registerLazySingleton<DioClient>(() => DioClient())
    ..registerLazySingleton<Dio>(
      () => getIt<DioClient>().dio,
    )
    ..registerSingletonAsync<Prefs>(Prefs.create)
    ..registerLazySingleton<FirebaseRemoteConfig>(
      () => FirebaseRemoteConfig.instance,
    )
    ..registerLazySingleton<AuthApi>(
      () => AuthApi(getIt<Dio>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        authApi: getIt(),
        prefs: getIt(),
        logger: getIt(),
      ),
    )
    ..registerLazySingleton<EnergyRemoteDataSource>(
      () => EnergyRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<EnergyRepository>(
      () => EnergyRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<ClimateRemoteDataSource>(
      () => ClimateRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<ClimateRepository>(
      () => ClimateRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<FetchEnergySnapshotUseCase>(
      () => FetchEnergySnapshotUseCase(getIt()),
    )
    ..registerLazySingleton<FetchClimateSnapshotUseCase>(
      () => FetchClimateSnapshotUseCase(getIt()),
    )
    ..registerLazySingleton<GetCachedSnapshotUseCase>(
      () => GetCachedSnapshotUseCase(getIt()),
    )
    ..registerLazySingleton<FetchEnergyConsumptionUseCase>(
      () => FetchEnergyConsumptionUseCase(getIt()),
    )
    ..registerLazySingleton<FetchEnergyConsumptionHistoryUseCase>(
      () => FetchEnergyConsumptionHistoryUseCase(getIt()),
    )
    ..registerLazySingleton<FetchEnergyCategoryBreakdownUseCase>(
      () => FetchEnergyCategoryBreakdownUseCase(getIt()),
    )
    ..registerLazySingleton<FetchClimateHistoryUseCase>(
      () => FetchClimateHistoryUseCase(getIt()),
    )
    ..registerLazySingleton<NotificationsRemoteDataSource>(
      () => NotificationsRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<FetchNotificationsUseCase>(
      () => FetchNotificationsUseCase(getIt()),
    )
    ..registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(getIt()),
    )
    ..registerLazySingleton<SaveSessionUseCase>(
      () => SaveSessionUseCase(getIt()),
    )
    ..registerLazySingleton<GetSessionUseCase>(
      () => GetSessionUseCase(getIt()),
    )
    ..registerLazySingleton<ClearSessionUseCase>(
      () => ClearSessionUseCase(getIt()),
    )
    ..registerLazySingleton<UpdateSessionSelectionUseCase>(
      () => UpdateSessionSelectionUseCase(getIt()),
    );

  await getIt.allReady();
}
