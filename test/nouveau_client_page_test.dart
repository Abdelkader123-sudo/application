import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traceur_app/nouveau_client_page.dart';

void main() {
  testWidgets('inscription client propose le scan du QR sans empreinte', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NouveauClientPage(versApplication: () => const SizedBox()),
      ),
    );

    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    expect(find.byIcon(Icons.fingerprint), findsNothing);
    expect(find.text('Nom de la ferme principale'), findsNothing);
    expect(find.text('Code d’activation'), findsOneWidget);
  });
}
