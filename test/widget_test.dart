import 'package:controlapp/main.dart';
import 'package:controlapp/src/core/di/injector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await configureDependencies();
  });

  testWidgets('App renders Splash screen', (tester) async {
    await tester.pumpWidget(const ControllerWidgat());

    await tester.pump();

    expect(find.byType(ControllerWidgat), findsOneWidget);
  });
}
