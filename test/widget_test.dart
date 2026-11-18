// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:traceur_app/locale_controller.dart';
import 'package:traceur_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('le bouton Nouveau client est caché avant cinq appuis', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'langue': 'fr'});
    final localeController = LocaleController();
    await localeController.charger();

    await tester.pumpWidget(TraceurApp(localeController: localeController));
    await tester.pumpAndSettle();

    expect(find.text('TRACEUR'), findsOneWidget);
    await tester.tap(find.text('Commencer'));
    await tester.pumpAndSettle();

    expect(find.text('Code ferme'), findsOneWidget);
    expect(find.text('Nouveau client'), findsNothing);
    for (var i = 0; i < 5; i++) {
      await tester.tapAt(const Offset(20, 200));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nouveau client'), findsOneWidget);
  });
}
