import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traceur_app/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('restaure la session sauvegardée au lancement', () async {
    FlutterSecureStorage.setMockInitialValues({
      'session_token': 'token-acces',
      'session_refresh_token': 'token-renouvellement',
      'session_user': jsonEncode({
        'id': 'user-1',
        'nom': 'Alice',
        'prenom': '',
        'role': 'superadmin',
        'numero_client': '00000001',
        'biometrie_activee': false,
      }),
    });

    final service = AuthService.instance;
    await service.restaurerSession();

    expect(service.connecte, isTrue);
    expect(service.utilisateur?.id, 'user-1');
    expect(service.utilisateur?.numeroClient, '00000001');
    expect(
      service.entetesAutorisation['Authorization'],
      'Bearer token-acces',
    );
  });
}
