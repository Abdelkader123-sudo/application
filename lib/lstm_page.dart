// lib/lstm_page.dart
// Dépendances : http, flutter_map (^8.x ou ^7.x), latlong2
//   flutter pub add http flutter_map latlong2
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' show Distance, LatLng, LengthUnit;
import 'package:traceur_app/l10n/app_localizations.dart';

import 'auth_service.dart';
import 'fond_page.dart';

// Couleurs (même style que le reste de l'application)
const _vertFonce = Color(0xFF123D2E);
const _vert = Color(0xFF187653);
const _texte = Color(0xFF193C2D);
const _secondaire = Color(0xFF758178);
const _bordure = Color(0xFFE5ECE6);
const _orange = Color(0xFFE08A1E);
const _orangeClair = Color(0xFFFFF3E4);
const _rouge = Color(0xFFD34444);
const _rougeClair = Color(0xFFFFEEEE);
const _bleu = Color(0xFF2F6FDE); // position attendue
const _ardoise = Color(0xFF1B2B4B); // courbe d'écart

// ---------------------------------------------------------------------------
// Fond de carte : à changer ici (aucun ne demande de clé)
//   routier   : OpenStreetMap (par défaut)
//   plan      : plan Esri
//   satellite : image satellite Esri
// ---------------------------------------------------------------------------
enum FondCarte { routier, plan, satellite }

const FondCarte _fondChoisi = FondCarte.routier;

String get _fondUrl => switch (_fondChoisi) {
  FondCarte.routier => 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  FondCarte.plan => 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
  FondCarte.satellite => 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
};

// Mention obligatoire du fournisseur de carte (affichée en petit)
String get _fondAttribution => switch (_fondChoisi) {
  FondCarte.routier => '© OpenStreetMap contributors',
  FondCarte.plan => 'Tiles © Esri',
  FondCarte.satellite => 'Imagery © Esri, Maxar, Earthstar Geographics',
};

const double _hauteurCarte = 320;

// ---------------------------------------------------------------------------
// Niveau d'importance, déduit de l'écart par rapport à la limite normale
// ---------------------------------------------------------------------------
enum Niveau { modere, marque, fort }

double? _nombre(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse('${v ?? ''}');

// ---------------------------------------------------------------------------
// Modèle
// ---------------------------------------------------------------------------
class EvenementLstm {
  final String animalId;

  /// Heure locale de l'événement (déjà en heure de l'élevage, sans conversion).
  final DateTime? heure;

  /// Valeur brute de instant_local.
  final String? instantBrut;
  final double? ecartM;
  final double? limiteM;
  final int? mesures;

  /// Position réelle de l'animal au moment de l'alerte (absente des anciennes alertes).
  final double? reelLat;
  final double? reelLon;

  /// Position attendue (calculée) à ce moment (absente des anciennes alertes).
  final double? prevuLat;
  final double? prevuLon;

  EvenementLstm({
    required this.animalId,
    required this.heure,
    required this.instantBrut,
    required this.ecartM,
    required this.limiteM,
    required this.mesures,
    this.reelLat,
    this.reelLon,
    this.prevuLat,
    this.prevuLon,
  });

  /// Vrai si l'alerte contient les positions attendue ET réelle.
  bool get aPrevision =>
      reelLat != null &&
      reelLon != null &&
      prevuLat != null &&
      prevuLon != null;

  factory EvenementLstm.fromJson(Map<String, dynamic> json) {
    DateTime? heure;
    final local = DateTime.tryParse('${json['instant_local'] ?? ''}');
    if (local != null) {
      // instant_local est déjà l'heure locale : on garde les chiffres tels quels
      heure = DateTime(
        local.year,
        local.month,
        local.day,
        local.hour,
        local.minute,
      );
    } else {
      heure = DateTime.tryParse('${json['cree_le'] ?? json['timestamp'] ?? ''}')
          ?.toLocal();
    }
    return EvenementLstm(
      animalId: '${json['animal_id'] ?? '?'}',
      heure: heure,
      instantBrut: json['instant_local'] == null
          ? null
          : '${json['instant_local']}',
      ecartM: _nombre(json['erreur_m']),
      limiteM: _nombre(json['seuil_m']),
      mesures: _nombre(json['k'])?.toInt(),
      reelLat: _nombre(json['reel_lat']),
      reelLon: _nombre(json['reel_lon']),
      prevuLat: _nombre(json['prevu_lat']),
      prevuLon: _nombre(json['prevu_lon']),
    );
  }

  Niveau get niveau {
    if (ecartM == null || limiteM == null || limiteM! <= 0) {
      return Niveau.modere;
    }
    final ratio = ecartM! / limiteM!;
    if (ratio >= 2) return Niveau.fort;
    if (ratio >= 1.5) return Niveau.marque;
    return Niveau.modere;
  }
}

Future<List<EvenementLstm>> chargerEvenementsLstm({String? animalId}) async {
  final auth = AuthService.instance;
  final uri = auth
      .uriApi('/lstm/evenements')
      .replace(queryParameters: {'animal_id': ?animalId, 'limite': '100'});
  final reponse = await http
      .get(uri, headers: auth.entetesAutorisation)
      .timeout(const Duration(seconds: 25));
  if (reponse.statusCode != 200) {
    throw Exception('Erreur serveur (${reponse.statusCode})');
  }
  final liste = jsonDecode(utf8.decode(reponse.bodyBytes)) as List;
  return liste
      .map((e) => EvenementLstm.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}

// ---------------------------------------------------------------------------
// Outils de placement des étiquettes (sans chevauchement, dans le cadre)
// ---------------------------------------------------------------------------
const double _hEtiq = 26;

// Taille de la boîte invisible qui porte une étiquette (centrée sur son point)
const double _boiteL = 400;
const double _boiteH = 160;

const _margeCarte = EdgeInsets.all(52);

enum _Cote {
  haut,
  hautDroite,
  hautGauche,
  bas,
  basDroite,
  basGauche,
  droite,
  gauche,
}

const _ordreHaut = [
  _Cote.haut,
  _Cote.hautDroite,
  _Cote.hautGauche,
  _Cote.bas,
  _Cote.basDroite,
  _Cote.basGauche,
  _Cote.droite,
  _Cote.gauche,
];

const _ordreBas = [
  _Cote.bas,
  _Cote.basDroite,
  _Cote.basGauche,
  _Cote.haut,
  _Cote.hautDroite,
  _Cote.hautGauche,
  _Cote.droite,
  _Cote.gauche,
];

Rect _rectCote(Offset a, double rayon, double w, _Cote c) {
  final d = rayon + 4;
  return switch (c) {
    _Cote.haut => Rect.fromLTWH(a.dx - w / 2, a.dy - d - _hEtiq, w, _hEtiq),
    _Cote.hautDroite => Rect.fromLTWH(a.dx - 12, a.dy - d - _hEtiq, w, _hEtiq),
    _Cote.hautGauche => Rect.fromLTWH(
      a.dx + 12 - w,
      a.dy - d - _hEtiq,
      w,
      _hEtiq,
    ),
    _Cote.bas => Rect.fromLTWH(a.dx - w / 2, a.dy + d, w, _hEtiq),
    _Cote.basDroite => Rect.fromLTWH(a.dx - 12, a.dy + d, w, _hEtiq),
    _Cote.basGauche => Rect.fromLTWH(a.dx + 12 - w, a.dy + d, w, _hEtiq),
    _Cote.droite => Rect.fromLTWH(a.dx + d, a.dy - _hEtiq / 2, w, _hEtiq),
    _Cote.gauche => Rect.fromLTWH(a.dx - d - w, a.dy - _hEtiq / 2, w, _hEtiq),
  };
}

double _aire(Rect r) =>
    (r.width <= 0 || r.height <= 0) ? 0 : r.width * r.height;

/// Pénalité = surface qui sort du cadre + surface qui en recouvre d'autres.
double _penalite(Rect r, Rect cadre, List<Rect> occupes) {
  var p = _aire(r) - _aire(r.intersect(cadre));
  for (final o in occupes) {
    if (r.overlaps(o)) p += _aire(r.intersect(o));
  }
  return p;
}

/// Ramène un rectangle à l'intérieur du cadre.
Rect _dansCadre(Rect r, Rect cadre) {
  var dx = 0.0, dy = 0.0;
  if (r.left < cadre.left) {
    dx = cadre.left - r.left;
  } else if (r.right > cadre.right) {
    dx = cadre.right - r.right;
  }
  if (r.top < cadre.top) {
    dy = cadre.top - r.top;
  } else if (r.bottom > cadre.bottom) {
    dy = cadre.bottom - r.bottom;
  }
  return r.shift(Offset(dx, dy));
}

/// Choisit le meilleur côté pour une étiquette et réserve sa place.
Rect _placer({
  required Offset ancre,
  required double rayon,
  required double largeur,
  required bool prefereHaut,
  required Rect cadre,
  required List<Rect> occupes,
}) {
  final ordre = prefereHaut ? _ordreHaut : _ordreBas;
  var meilleur = _rectCote(ancre, rayon, largeur, ordre.first);
  var meilleurScore = double.infinity;
  for (var i = 0; i < ordre.length; i++) {
    final r = _rectCote(ancre, rayon, largeur, ordre[i]);
    final score = _penalite(r, cadre, occupes) + i * 0.01;
    if (score < meilleurScore) {
      meilleurScore = score;
      meilleur = r;
    }
  }
  occupes.add(meilleur);
  return meilleur;
}

/// Projection approchée (Mercator) pour prévoir où les points tomberont à
/// l'écran une fois le zoom ajusté. Sert uniquement à placer les étiquettes.
class _Projection {
  final Size taille;
  late final double _echelle;
  late final double _cx;
  late final double _cy;

  _Projection(List<LatLng> pts, this.taille, EdgeInsets marge, double zoomMax) {
    var minX = double.infinity, maxX = -double.infinity;
    var minY = double.infinity, maxY = -double.infinity;
    for (final p in pts) {
      final x = _mx(p.longitude);
      final y = _my(p.latitude);
      minX = math.min(minX, x);
      maxX = math.max(maxX, x);
      minY = math.min(minY, y);
      maxY = math.max(maxY, y);
    }
    _cx = (minX + maxX) / 2;
    _cy = (minY + maxY) / 2;
    // Échelle maximale (zoom maximal) en pixels par radian
    var e = (256 * math.pow(2, zoomMax) / (2 * math.pi)).toDouble();
    final dx = maxX - minX;
    final dy = maxY - minY;
    if (dx > 1e-12) {
      e = math.min(e, math.max(1.0, taille.width - marge.horizontal) / dx);
    }
    if (dy > 1e-12) {
      e = math.min(e, math.max(1.0, taille.height - marge.vertical) / dy);
    }
    _echelle = e;
  }

  static double _mx(double lon) => lon * math.pi / 180;
  static double _my(double lat) =>
      math.log(math.tan(math.pi / 4 + lat * math.pi / 360));

  Offset projeter(LatLng p) => Offset(
    taille.width / 2 + (_mx(p.longitude) - _cx) * _echelle,
    taille.height / 2 - (_my(p.latitude) - _cy) * _echelle,
  );
}

// ---------------------------------------------------------------------------
// Éléments graphiques de la carte
// ---------------------------------------------------------------------------
Widget _etiquette(
  String texte,
  Color fond,
  Color couleurTexte, {
  Color? bordure,
  required double largeur,
}) {
  return Container(
    width: largeur,
    height: _hEtiq,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: fond,
      borderRadius: BorderRadius.circular(20),
      border: bordure == null ? null : Border.all(color: bordure, width: 1.4),
      boxShadow: const [
        BoxShadow(
          color: Color(0x40000000),
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        texte,
        maxLines: 1,
        style: TextStyle(
          color: couleurTexte,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

/// Marqueur invisible, centré sur [point], qui porte un widget placé à un
/// endroit précis de l'écran ([rect], en pixels, autour de [ancre]).
Marker _marqueurRect({
  required LatLng point,
  required Offset ancre,
  required Rect rect,
  required Widget child,
}) {
  return Marker(
    point: point,
    width: _boiteL,
    height: _boiteH,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: _boiteL / 2 + rect.left - ancre.dx,
          top: _boiteH / 2 + rect.top - ancre.dy,
          width: rect.width,
          height: rect.height,
          child: child,
        ),
      ],
    ),
  );
}

String _formaterDistance(double m, AppLocalizations loc) {
  if (m >= 1000) {
    return loc.lstmKilometers(
      (m / 1000).toStringAsFixed(1).replaceAll('.', ','),
    );
  }
  final arrondi = m < 100 ? (m / 5).round() * 5 : (m / 10).round() * 10;
  return loc.lstmMeters(math.max(5, arrondi));
}

/// Courbe (arc) entre deux positions, légèrement bombée vers le nord.
List<LatLng> _courbe(LatLng a, LatLng b) {
  const mLat = 111320.0;
  final mLon = 111320.0 * math.cos(a.latitude * math.pi / 180);
  final dx = (b.longitude - a.longitude) * mLon;
  final dy = (b.latitude - a.latitude) * mLat;
  final longueur = math.sqrt(dx * dx + dy * dy);
  if (longueur < 1) return [a, b];
  var nx = -dy / longueur;
  var ny = dx / longueur;
  if (ny < 0) {
    nx = -nx;
    ny = -ny;
  }
  final cx = dx / 2 + nx * longueur * 0.25; // point de contrôle
  final cy = dy / 2 + ny * longueur * 0.25;
  const n = 32;
  final points = <LatLng>[];
  for (var i = 0; i <= n; i++) {
    final t = i / n;
    final x = 2 * (1 - t) * t * cx + t * t * dx;
    final y = 2 * (1 - t) * t * cy + t * t * dy;
    points.add(LatLng(a.latitude + y / mLat, a.longitude + x / mLon));
  }
  return points;
}

// Mention du fournisseur de carte, petite et discrète
double get _largeurAttribution => _fondAttribution.length * 5.4 + 12;

Widget _attribution() {
  return Align(
    alignment: Alignment.bottomRight,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: const BoxDecoration(
        color: Color(0xCCFFFFFF),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(6)),
      ),
      child: Text(
        _fondAttribution,
        style: const TextStyle(fontSize: 9.5, color: Colors.black87),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Carte : position attendue, position réelle, courbe et distance
// ---------------------------------------------------------------------------
class _CarteEcart extends StatelessWidget {
  final EvenementLstm evenement;
  const _CarteEcart(this.evenement);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, c) {
        final largeur = c.maxWidth.isFinite ? c.maxWidth : 340.0;
        final hauteur = c.maxHeight.isFinite ? c.maxHeight : _hauteurCarte;
        return _carte(Size(largeur, hauteur), loc);
      },
    );
  }

  Widget _carte(Size taille, AppLocalizations loc) {
    const distance = Distance();
    final e = evenement;
    final prevu = LatLng(e.prevuLat!, e.prevuLon!);
    final reel = LatLng(e.reelLat!, e.reelLon!);
    final metres = distance.as(LengthUnit.Meter, prevu, reel);
    final courbe = _courbe(prevu, reel);
    final sommet = courbe[courbe.length ~/ 2];

    // --- Placement des étiquettes (positions estimées à l'écran) -----------
    final proj = _Projection(courbe, taille, _margeCarte, 17);
    final pPrevu = proj.projeter(prevu);
    final pReel = proj.projeter(reel);
    final pSommet = proj.projeter(sommet);

    final cadre = Rect.fromLTWH(3, 3, taille.width - 6, taille.height - 6);
    final occupes = <Rect>[
      Rect.fromLTWH(
        taille.width - _largeurAttribution,
        taille.height - 18,
        _largeurAttribution,
        18,
      ),
      Rect.fromCircle(center: pPrevu, radius: 12),
      Rect.fromCircle(center: pReel, radius: 18),
    ];

    // Pastille de distance, posée sur la courbe (décalée si elle gêne)
    var rectEcart = _dansCadre(
      Rect.fromCenter(center: pSommet, width: 112, height: _hEtiq),
      cadre,
    );
    var meilleurScore = double.infinity;
    for (final dy in const [0.0, -30.0, -60.0, 30.0]) {
      final r = _dansCadre(
        Rect.fromCenter(
          center: pSommet + Offset(0, dy),
          width: 112,
          height: _hEtiq,
        ),
        cadre,
      );
      final s = _penalite(r, cadre, occupes);
      if (s < meilleurScore) {
        meilleurScore = s;
        rectEcart = r;
      }
    }
    occupes.add(rectEcart);

    // Étiquettes : le point le plus haut a son étiquette au-dessus
    final reelEnHaut = pReel.dy <= pPrevu.dy;
    final rectReel = _placer(
      ancre: pReel,
      rayon: 18,
      largeur: 128,
      prefereHaut: reelEnHaut,
      cadre: cadre,
      occupes: occupes,
    );
    final rectPrevu = _placer(
      ancre: pPrevu,
      rayon: 12,
      largeur: 140,
      prefereHaut: !reelEnHaut,
      cadre: cadre,
      occupes: occupes,
    );

    final marqueurs = <Marker>[
      // Position attendue : rond creux bleu
      Marker(
        point: prevu,
        width: 28,
        height: 28,
        child: Center(
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: _bleu, width: 4.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
      // Position réelle : rond rouge avec « ! »
      Marker(
        point: reel,
        width: 38,
        height: 38,
        child: Center(
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _rouge,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              '!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ),
      ),
      _marqueurRect(
        point: sommet,
        ancre: pSommet,
        rect: rectEcart,
        child: _etiquette(
          loc.lstmDistanceLabel(_formaterDistance(metres, loc)),
          _ardoise,
          Colors.white,
          largeur: 112,
        ),
      ),
      _marqueurRect(
        point: prevu,
        ancre: pPrevu,
        rect: rectPrevu,
        child: _etiquette(
          loc.lstmExpectedPosition,
          Colors.white,
          _bleu,
          bordure: _bleu,
          largeur: 140,
        ),
      ),
      _marqueurRect(
        point: reel,
        ancre: pReel,
        rect: rectReel,
        child: _etiquette(
          loc.lstmActualPosition,
          _rouge,
          Colors.white,
          largeur: 128,
        ),
      ),
    ];

    return FlutterMap(
      options: MapOptions(
        // Le zoom s'ajuste tout seul pour que tout soit visible
        initialCameraFit: CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(courbe),
          padding: _margeCarte,
          maxZoom: 17,
        ),
        // Image fixe : ne gêne pas le défilement de la liste
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: _fondUrl,
          userAgentPackageName: 'com.example.traceur',
        ),
        // Courbe entre la position attendue et la position réelle
        PolylineLayer(
          polylines: [
            Polyline(
              points: courbe,
              strokeWidth: 4,
              color: _ardoise,
              borderStrokeWidth: 1.5,
              borderColor: Colors.white,
              pattern: StrokePattern.dashed(segments: const [10, 7]),
            ),
          ],
        ),
        MarkerLayer(markers: marqueurs),
        _attribution(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Carte d'une alerte
// ---------------------------------------------------------------------------
class _CarteEvenement extends StatelessWidget {
  final EvenementLstm evenement;
  final String dateTexte;
  const _CarteEvenement({
    super.key,
    required this.evenement,
    required this.dateTexte,
  });

  /// Description simple, sans vocabulaire technique.
  Widget _description(EvenementLstm e, Color accent, AppLocalizations loc) {
    const distance = Distance();
    final metres = distance.as(
      LengthUnit.Meter,
      LatLng(e.prevuLat!, e.prevuLon!),
      LatLng(e.reelLat!, e.reelLon!),
    );
    final conseil = switch (e.niveau) {
      Niveau.fort => loc.lstmAdviceStrong,
      Niveau.marque => loc.lstmAdviceMarked,
      Niveau.modere => loc.lstmAdviceModerate,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.lstmMovementDescription(_formaterDistance(metres, loc)),
          style: const TextStyle(
            color: _texte,
            fontSize: 13.5,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          conseil,
          style: TextStyle(
            color: accent,
            fontSize: 13,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final e = evenement;
    final fort = e.niveau == Niveau.fort;
    final accent = fort ? _rouge : _orange;
    final teinte = fort ? _rougeClair : _orangeClair;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _bordure),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10183A2C),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: teinte,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.directions_run_rounded,
                  color: accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.animalId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF526157),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.lstmEventTitle,
                      style: TextStyle(
                        color: _texte,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: Color(0xFF89948C),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            dateTexte,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _secondaire,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (e.aPrevision) ...[
            Container(
              height: _hauteurCarte,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFE9EFEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _bordure),
              ),
              child: _CarteEcart(e),
            ),
            const SizedBox(height: 12),
            _description(e, accent, loc),
          ] else
            // Anciennes alertes, enregistrées sans les deux positions
            Text(
              loc.lstmLegacyPositionUnavailable,
              style: TextStyle(
                color: _secondaire,
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------
class LstmPage extends StatefulWidget {
  /// Si renseigné, n'affiche que les événements de cet animal.
  final String? animalId;
  const LstmPage({super.key, this.animalId});

  @override
  State<LstmPage> createState() => _LstmPageState();
}

class _LstmPageState extends State<LstmPage> {
  late Future<List<EvenementLstm>> _futur;

  @override
  void initState() {
    super.initState();
    _futur = chargerEvenementsLstm(animalId: widget.animalId);
  }

  void _recharger() {
    setState(() {
      _futur = chargerEvenementsLstm(animalId: widget.animalId);
    });
  }

  Future<void> _rafraichir() async {
    _recharger();
    try {
      await _futur;
    } catch (_) {}
  }

  String _deux(int n) => n.toString().padLeft(2, '0');

  String _formaterDate(DateTime? d, AppLocalizations loc) {
    if (d == null) return loc.dateUnavailable;
    final maintenant = DateTime.now();
    final aujourdhui = DateTime(
      maintenant.year,
      maintenant.month,
      maintenant.day,
    );
    final jour = DateTime(d.year, d.month, d.day);
    final heure = '${_deux(d.hour)}:${_deux(d.minute)}';
    final ecart = aujourdhui.difference(jour).inDays;
    if (ecart == 0) return loc.lstmTodayAt(heure);
    if (ecart == 1) return loc.lstmYesterdayAt(heure);
    return loc.lstmDateAt(_deux(d.day), _deux(d.month), d.year, heure);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return FondPage(
      image: 'assets/images/LSTM.jpg',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: _vertFonce,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.lstmPageTitle,
                style: TextStyle(
                  color: _vertFonce,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.45,
                ),
              ),
              SizedBox(height: 2),
              Text(
                loc.lstmPageSubtitle,
                style: TextStyle(
                  color: _secondaire,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            color: _vert,
            onRefresh: _rafraichir,
            child: FutureBuilder<List<EvenementLstm>>(
              future: _futur,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: _vert),
                  );
                }
                if (snap.hasError) {
                  return _Etat(
                    icone: Icons.cloud_off_rounded,
                    couleur: const Color(0xFFB77832),
                    fond: _orangeClair,
                    titre: loc.connectionInterrupted,
                    message: loc.lstmLoadError,
                    onRetry: _recharger,
                  );
                }
                final evenements = snap.data ?? [];
                if (evenements.isEmpty) {
                  return _Etat(
                    icone: Icons.verified_rounded,
                    couleur: _vert,
                    fond: Color(0xFFE8F4EC),
                    titre: loc.lstmNoEvents,
                    message: loc.lstmNoEventsMessage,
                  );
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: evenements.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final e = evenements[i];
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: _CarteEvenement(
                          key: ValueKey('${e.animalId}|${e.instantBrut}'),
                          evenement: e,
                          dateTexte: _formaterDate(e.heure, loc),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Etat extends StatelessWidget {
  final IconData icone;
  final Color couleur;
  final Color fond;
  final String titre;
  final String message;
  final VoidCallback? onRetry;

  const _Etat({
    required this.icone,
    required this.couleur,
    required this.fond,
    required this.titre,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(28),
      children: [
        const SizedBox(height: 60),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(color: fond, shape: BoxShape.circle),
                child: Icon(icone, color: couleur, size: 34),
              ),
              const SizedBox(height: 18),
              Text(
                titre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _texte,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 310),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _secondaire,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _vert),
                  onPressed: onRetry,
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
