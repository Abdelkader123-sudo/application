double? _num(dynamic value) {
  if (value == null) return null;

  final double? parsed;
  if (value is num) {
    parsed = value.toDouble();
  } else if (value is String) {
    parsed = double.tryParse(value.trim().replaceAll(',', '.'));
  } else {
    return null;
  }

  return parsed != null && parsed.isFinite ? parsed : null;
}

int? _int(dynamic value) => _num(value)?.toInt();

bool? _bool(dynamic value) {
  if (value is bool) return value;
  if (value is num) {
    if (value == 1) return true;
    if (value == 0) return false;
    return null;
  }
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'oui':
      case 'yes':
        return true;
      case 'false':
      case '0':
      case 'non':
      case 'no':
        return false;
    }
  }
  return null;
}

String? _optionalString(dynamic value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _idString(dynamic value) {
  if (value is String) return value.trim();
  if (value is num) return value.toString();
  return '';
}

DateTime _dateTime(dynamic value, String field) {
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Le champ "$field" doit contenir une date ISO 8601.');
  }
  try {
    // Une date sans fuseau reste une heure locale, comme dans la réponse API.
    return DateTime.parse(value.trim());
  } on FormatException {
    throw FormatException('Date invalide dans le champ "$field".');
  }
}

Map<String, dynamic> _jsonMap(dynamic value, String field) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    final result = <String, dynamic>{};
    for (final entry in value.entries) {
      if (entry.key is! String) {
        throw FormatException('Une clé de "$field" n’est pas une chaîne.');
      }
      result[entry.key as String] = entry.value;
    }
    return result;
  }
  throw FormatException('Le champ "$field" doit être un objet JSON.');
}

enum StatutHistorique { normal, aSurveiller, historiqueInsuffisant }

StatutHistorique _parseStatut(String? valeur) {
  switch (valeur?.trim().toLowerCase()) {
    case 'normal':
      return StatutHistorique.normal;
    case 'a_surveiller':
      return StatutHistorique.aSurveiller;
    case 'historique_insuffisant':
      return StatutHistorique.historiqueInsuffisant;
    default:
      throw FormatException('Statut d’historique inconnu.');
  }
}

class PointActivite {
  /// Heure locale (sans fuseau) : parsée telle quelle, jamais convertie.
  final DateTime heure;
  final bool valide;
  final double? pas;
  final double? mi;
  final double? pasAttendus;
  final double? score;
  final bool? alerte;

  const PointActivite({
    required this.heure,
    required this.valide,
    this.pas,
    this.mi,
    this.pasAttendus,
    this.score,
    this.alerte,
  });

  factory PointActivite.fromJson(Map<String, dynamic> json) {
    return PointActivite(
      heure: _dateTime(json['heure'], 'heure'),
      valide: _bool(json['valide']) ?? false,
      pas: _num(json['pas']),
      mi: _num(json['mi']),
      pasAttendus: _num(json['pas_attendus']),
      score: _num(json['score']),
      alerte: _bool(json['alerte']),
    );
  }
}

class HistoriqueActivite {
  final String animalId;
  final StatutHistorique statut;
  final String? raison;
  final int? heuresAlerte24h;
  final double? scoreMax24h;
  final double? seuilScore;
  final int? seuilHeures;
  final int heuresValides;
  final String? fuseau;
  final List<PointActivite> points;

  const HistoriqueActivite({
    required this.animalId,
    required this.statut,
    this.raison,
    this.heuresAlerte24h,
    this.scoreMax24h,
    this.seuilScore,
    this.seuilHeures,
    required this.heuresValides,
    this.fuseau,
    required this.points,
  });

  bool get insuffisant => statut == StatutHistorique.historiqueInsuffisant;

  factory HistoriqueActivite.fromJson(Map<String, dynamic> json) {
    final valeurPoints = json['points'];
    final List<dynamic> rawPoints;
    if (valeurPoints == null) {
      rawPoints = const [];
    } else if (valeurPoints is List) {
      rawPoints = valeurPoints;
    } else {
      throw FormatException('Le champ "points" doit être une liste.');
    }

    final points = <PointActivite>[];
    for (var index = 0; index < rawPoints.length; index++) {
      final pointJson = _jsonMap(rawPoints[index], 'points[$index]');
      try {
        points.add(PointActivite.fromJson(pointJson));
      } on FormatException catch (error) {
        throw FormatException('Point $index invalide : ${error.message}');
      }
    }
    points.sort((a, b) => a.heure.compareTo(b.heure));

    return HistoriqueActivite(
      animalId: _idString(json['animal_id']),
      statut: _parseStatut(_optionalString(json['statut'])),
      raison: _optionalString(json['raison']),
      heuresAlerte24h: _int(json['heures_alerte_24h']),
      scoreMax24h: _num(json['score_max_24h']),
      seuilScore: _num(json['seuil_score']),
      seuilHeures: _int(json['seuil_heures']),
      heuresValides: _int(json['heures_valides']) ?? 0,
      fuseau: _optionalString(json['fuseau']),
      points: List.unmodifiable(points),
    );
  }
}