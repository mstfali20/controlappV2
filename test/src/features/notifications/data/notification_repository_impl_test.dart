// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';

// import 'package:controlapp/src/core/error/failures.dart';
// import 'package:controlapp/src/features/notifications/data/datasources/local/notification_local_data_source.dart';
// import 'package:controlapp/src/features/notifications/data/models/notification_model.dart';
// import 'package:controlapp/src/features/notifications/data/repositories/notification_repository_impl.dart';

// class _MockNotificationLocalDataSource extends Mock
//     implements NotificationLocalDataSource {}

// void main() {
//   late NotificationRepositoryImpl repository;
//   late _MockNotificationLocalDataSource localDataSource;

//   final tModel = NotificationModel(
//     title: 'Title',
//     body: 'Body',
//     timestamp: DateTime(2024, 1, 1, 12, 0),
//     actionUrl: 'https://example.com',
//   );

//   setUp(() {
//     localDataSource = _MockNotificationLocalDataSource();
//     repository = NotificationRepositoryImpl(localDataSource);
//   });

//   group('loadNotifications', () {
//     test('returns Success with mapped entities when datasource succeeds',
//         () async {
//       when(() => localDataSource.loadNotifications())
//           .thenAnswer((_) async => [tModel]);

//       final result = await repository.loadNotifications();

//       expect(result.isSuccess, isTrue);
//       expect(
//           result.when(
//             success: (entities) => entities.first.title,
//             failure: (failure) => fail('Should not reach failure'),
//           ),
//           'Title');
//     });

//     test('returns Failure when datasource throws', () async {
//       when(() => localDataSource.loadNotifications())
//           .thenThrow(Exception('boom'));

//       final result = await repository.loadNotifications();

//       expect(result.isFailure, isTrue);
//       result.when(
//         success: (_) => fail('Should not reach success'),
//         failure: (failure) => expect(failure, isA<CacheFailure>()),
//       );
//     });
//   });

//   group('deleteNotification', () {
//     test('returns updated entities list', () async {
//       when(() => localDataSource.deleteNotification(0))
//           .thenAnswer((_) async => [tModel]);

//       final result = await repository.deleteNotification(0);

//       expect(result.isSuccess, isTrue);
//       expect(
//         result.when(
//           success: (entities) => entities.length,
//           failure: (failure) => fail('Should not reach failure'),
//         ),
//         1,
//       );
//     });

//     test('returns Failure when datasource fails', () async {
//       when(() => localDataSource.deleteNotification(0))
//           .thenThrow(Exception('error'));

//       final result = await repository.deleteNotification(0);

//       expect(result.isFailure, isTrue);
//       result.when(
//         success: (_) => fail('Should not reach success'),
//         failure: (failure) => expect(failure, isA<CacheFailure>()),
//       );
//     });
//   });

//   group('clearNotifications', () {
//     test('returns Success when datasource clears', () async {
//       when(() => localDataSource.clearNotifications()).thenAnswer((_) async {});

//       final result = await repository.clearNotifications();

//       expect(result.isSuccess, isTrue);
//     });

//     test('returns Failure when datasource throws', () async {
//       when(() => localDataSource.clearNotifications())
//           .thenThrow(Exception('error'));

//       final result = await repository.clearNotifications();

//       expect(result.isFailure, isTrue);
//       result.when(
//         success: (_) => fail('Should not reach success'),
//         failure: (failure) => expect(failure, isA<CacheFailure>()),
//       );
//     });
//   });
// }
