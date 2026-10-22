import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_srs7/main.dart';

void main() {
  testWidgets('Smoke test for Lab 7 App', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const Lab7App());

    // Verify that the registration page shows up
    expect(find.text('Лабораторная 7: Регистрация'), findsOneWidget);
    expect(find.text('Форма регистрации'), findsOneWidget);
  });
}
