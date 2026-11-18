import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

/// À adapter : même hôte que ton WebSocket, en http(s) au lieu de ws(s).
/// Exemple : ws://localhost:8000/ws  ->  http://localhost:8000
const String apiBase = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://traceur-backend.onrender.com',
);

class InfoAnimal {
  const InfoAnimal({
    this.type,
    this.sexe,
    this.age,
    this.poids,
    this.ferme = 'Ferme principale',
  });

  final String? type; // ex. « Vache laitière »
  final String? sexe; // 'femelle' | 'male'
  final double? age; // en années
  final double? poids; // en kg
  final String ferme;

  bool get vide => type == null && sexe == null && age == null && poids == null;

  String? get sexeTexte => switch (sexe) {
    'femelle' => 'Femelle',
    'male' => 'Mâle',
    _ => null,
  };

  String? get ageTexte {
    final a = age;
    if (a == null) return null;
    if (a < 1) return '${(a * 12).round()} mois';
    final entier = a == a.roundToDouble();
    return entier
        ? '${a.round()} an${a.round() > 1 ? 's' : ''}'
        : '${a.toStringAsFixed(1)} ans';
  }

  String? get poidsTexte {
    final p = poids;
    if (p == null) return null;
    return '${p.toStringAsFixed(p == p.roundToDouble() ? 0 : 1)} kg';
  }

  factory InfoAnimal.fromJson(Map<String, dynamic> j) => InfoAnimal(
    type: j['type']?.toString(),
    sexe: j['sexe']?.toString(),
    age: (j['age_ans'] as num?)?.toDouble(),
    poids: (j['poids_kg'] as num?)?.toDouble(),
    ferme: '${j['ferme'] ?? 'Ferme principale'}',
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'sexe': sexe,
    'age_ans': age,
    'poids_kg': poids,
    'ferme': ferme,
  };
}

class AnimauxApi {
  static Future<Map<String, InfoAnimal>> lireTous() async {
    final service = AuthService.instance;
    final liste = await service.requeteApi(
      () => http
          .get(service.uriApi('/animaux'), headers: service.entetesAutorisation)
          .timeout(const Duration(seconds: 10)),
    ) as List;
    final res = <String, InfoAnimal>{};
    for (final e in liste) {
      if (e is Map<String, dynamic> && e['animal_id'] != null) {
        res[e['animal_id'].toString()] = InfoAnimal.fromJson(e);
      }
    }
    return res;
  }

  static Future<InfoAnimal> enregistrer(String id, InfoAnimal info) async {
    final service = AuthService.instance;
    final resultat = await service.requeteApi(
      () => http
          .put(
            service.uriApi('/animaux/${Uri.encodeComponent(id)}'),
            headers: service.entetesAutorisation,
            body: jsonEncode(info.toJson()),
          )
          .timeout(const Duration(seconds: 10)),
    ) as Map<String, dynamic>;
    return InfoAnimal.fromJson(resultat);
  }
}
