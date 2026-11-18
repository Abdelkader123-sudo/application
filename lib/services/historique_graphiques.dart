import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:traceur_app/services/historique_activite.dart';

const _vert = Color(0xFF16845D);
const _rouge = Color(0xFFE05353);
const _secondaire = Color(0xFF66766D);
const _grille = Color(0xFFE7EEE9);
const _fondGraphique = Color(0xFFFCFEFD);

String _p2(int n) => n.toString().padLeft(2, '0');
String _jour(DateTime d) => '${_p2(d.day)}/${_p2(d.month)}';
String _jourHeure(DateTime d) => '${_jour(d)} ${_p2(d.hour)}h';

List<PointActivite> _ordonner(List<PointActivite> points) =>
    List<PointActivite>.of(points)..sort((a, b) => a.heure.compareTo(b.heure));

/// Intervalle « rond » (1, 2, 5 × 10^n) pour environ 4 graduations sur l'axe Y.
double _intervalleY(double minY, double maxY) {
  final etendue = maxY - minY;
  if (!etendue.isFinite || etendue <= 0) return 1;
  final brut = etendue / 4;
  final puissance = math.pow(10, (math.log(brut) / math.ln10).floorToDouble())
      .toDouble();
  final fraction = brut / puissance;
  final double pas;
  if (fraction <= 1) {
    pas = 1;
  } else if (fraction <= 2) {
    pas = 2;
  } else if (fraction <= 5) {
    pas = 5;
  } else {
    pas = 10;
  }
  return pas * puissance;
}

/// Nombre de décimales à afficher selon l'intervalle.
int _decimales(double intervalle) {
  if (intervalle >= 1) return 0;
  if (intervalle >= 0.1) return 1;
  if (intervalle >= 0.01) return 2;
  return 3;
}

/// Axe X en heures depuis minuit du premier jour, sans conversion de fuseau.
class _Axe {
  _Axe(List<PointActivite> points) {
    assert(points.isNotEmpty);
    final premiereHeure = points.first.heure;
    t0 = DateTime.utc(
      premiereHeure.year,
      premiereHeure.month,
      premiereHeure.day,
    );

    final debut = x(points.first.heure);
    final fin = x(points.last.heure);
    if (debut == fin) {
      minX = debut - 0.5;
      maxX = fin + 0.5;
    } else {
      minX = debut;
      maxX = fin;
    }
  }

  late final DateTime t0;
  late final double minX;
  late final double maxX;

  double x(DateTime heure) =>
      DateTime.utc(
        heure.year,
        heure.month,
        heure.day,
        heure.hour,
        heure.minute,
      ).difference(t0).inMinutes /
      60.0;

  DateTime dateDe(double valeur) => t0.add(Duration(hours: valeur.round()));

  double get interval {
    final etendue = maxX - minX;
    if (etendue <= 24) return 6;
    if (etendue <= 72) return 12;
    if (etendue <= 168) return 24;
    if (etendue <= 336) return 48;
    return 72;
  }
}

FlTitlesData _titres(
  _Axe axe, {
  required double minY,
  required double maxY,
}) {
  final intervalY = _intervalleY(minY, maxY);
  final decimales = _decimales(intervalY);

  return FlTitlesData(
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 52,
        interval: intervalY,
        getTitlesWidget: (valeur, meta) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            valeur.toStringAsFixed(decimales),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _secondaire,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        interval: axe.interval,
        getTitlesWidget: (valeur, meta) {
          final date = axe.dateDe(valeur);
          final label = date.hour == 0 || date.hour == 12 || date.hour == 18
              ? '${_jour(date)}\n${_p2(date.hour)}h'
              : _jour(date);
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _secondaire,
                fontSize: 9,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    ),
  );
}

FlGridData _grilleY(double minY, double maxY) => FlGridData(
  drawVerticalLine: false,
  horizontalInterval: _intervalleY(minY, maxY),
  getDrawingHorizontalLine: (value) => FlLine(color: _grille, strokeWidth: 1),
);

List<VerticalRangeAnnotation> _zonesInvalides(
  List<PointActivite> points,
  _Axe axe,
) {
  final zones = <VerticalRangeAnnotation>[];
  double? debut;
  double? fin;

  void fermer() {
    if (debut == null || fin == null) return;
    final x1 = (debut! - 0.5).clamp(axe.minX, axe.maxX).toDouble();
    final x2 = (fin! + 0.5).clamp(axe.minX, axe.maxX).toDouble();
    if (x2 > x1) {
      zones.add(
        VerticalRangeAnnotation(
          x1: x1,
          x2: x2,
          color: _secondaire.withValues(alpha: 0.10),
        ),
      );
    }
    debut = null;
    fin = null;
  }

  for (final point in points) {
    final position = axe.x(point.heure);
    if (!point.valide) {
      debut ??= position;
      fin = position;
    } else {
      fermer();
    }
  }
  fermer();
  return zones;
}

Widget _fondDuGraphique({required double hauteur, required Widget enfant}) =>
    Container(
      height: hauteur,
      padding: const EdgeInsets.fromLTRB(10, 14, 14, 8),
      decoration: BoxDecoration(
        color: _fondGraphique,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EFEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A163D2B),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: enfant,
    );

class _GraphiqueVide extends StatelessWidget {
  const _GraphiqueVide({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    height: 140,
    alignment: Alignment.center,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: _fondGraphique,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE7EFEA)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A163D2B),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _vert.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.show_chart_rounded,
            color: _vert.withValues(alpha: 0.85),
            size: 24,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _secondaire,
            fontSize: 12,
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

/// Graphique principal : pas, routine habituelle, alertes et données manquantes.
class ActiviteChart extends StatelessWidget {
  const ActiviteChart({super.key, required this.points});
  final List<PointActivite> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const _GraphiqueVide(
        message: 'Aucune donnée d’activité à afficher.',
      );
    }

    final donnees = _ordonner(points);
    final axe = _Axe(donnees);
    final spotsPas = <FlSpot>[
      for (final point in donnees)
        if (point.valide && point.pas != null && point.pas!.isFinite)
          FlSpot(axe.x(point.heure), point.pas!)
        else
          FlSpot.nullSpot,
    ];
    final aRoutine = donnees.any(
      (point) => point.pasAttendus != null && point.pasAttendus!.isFinite,
    );
    final spotsRoutine = <FlSpot>[
      for (final point in donnees)
        if (point.pasAttendus != null && point.pasAttendus!.isFinite)
          FlSpot(axe.x(point.heure), point.pasAttendus!)
        else
          FlSpot.nullSpot,
    ];
    final spotsAlerte = <FlSpot>[
      for (final point in donnees)
        if (point.valide &&
            point.alerte == true &&
            point.pas != null &&
            point.pas!.isFinite)
          FlSpot(axe.x(point.heure), point.pas!),
    ];

    var maxY = 0.0;
    for (final point in donnees) {
      if (point.valide &&
          point.pas != null &&
          point.pas!.isFinite &&
          point.pas! > maxY) {
        maxY = point.pas!;
      }
      if (point.pasAttendus != null &&
          point.pasAttendus!.isFinite &&
          point.pasAttendus! > maxY) {
        maxY = point.pasAttendus!;
      }
    }
    maxY = maxY <= 0 ? 10 : maxY * 1.15;
    const minY = 0.0;

    final lignes = <LineChartBarData>[
      LineChartBarData(
        spots: spotsPas,
        color: _vert,
        barWidth: 3,
        isCurved: false,
        belowBarData: BarAreaData(
          show: true,
          color: _vert.withValues(alpha: 0.08),
        ),
        dotData: const FlDotData(show: false),
      ),
      if (aRoutine)
        LineChartBarData(
          spots: spotsRoutine,
          color: _secondaire.withValues(alpha: 0.75),
          barWidth: 1.7,
          dashArray: [5, 4],
          dotData: const FlDotData(show: false),
        ),
      if (spotsAlerte.isNotEmpty)
        LineChartBarData(
          spots: spotsAlerte,
          barWidth: 0,
          color: Colors.transparent,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 4.5,
              color: _rouge,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
        ),
    ];

    return _fondDuGraphique(
      hauteur: 280,
      enfant: LineChart(
        LineChartData(
          minX: axe.minX,
          maxX: axe.maxX,
          minY: minY,
          maxY: maxY,
          lineBarsData: lignes,
          titlesData: _titres(axe, minY: minY, maxY: maxY),
          gridData: _grilleY(minY, maxY),
          borderData: FlBorderData(show: false),
          rangeAnnotations: RangeAnnotations(
            verticalRangeAnnotations: _zonesInvalides(donnees, axe),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                // La série principale fournit une seule infobulle par heure.
                if (spot.barIndex != 0 || spot.spotIndex >= donnees.length) {
                  return null;
                }
                final point = donnees[spot.spotIndex];
                final lignesTexte = <String>[
                  _jourHeure(point.heure),
                  'Pas : ${point.pas?.round().toString() ?? '—'}',
                  if (point.pasAttendus != null)
                    'Attendus : ${point.pasAttendus!.round()}',
                  if (point.score != null)
                    'Score : ${point.score!.toStringAsFixed(3)}',
                ];
                return LineTooltipItem(
                  lignesTexte.join('\n'),
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class LegendeHistorique extends StatelessWidget {
  const LegendeHistorique({super.key, this.avecRoutine = true});
  final bool avecRoutine;

  @override
  Widget build(BuildContext context) {
    Widget item({required Widget marque, required String texte}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5ECE7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          marque,
          const SizedBox(width: 6),
          Text(
            texte,
            style: const TextStyle(
              color: _secondaire,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        item(
          marque: Container(
            width: 15,
            height: 3,
            decoration: BoxDecoration(
              color: _vert,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          texte: 'Pas',
        ),
        if (avecRoutine)
          item(
            marque: Container(
              width: 15,
              height: 2,
              decoration: BoxDecoration(
                color: _secondaire,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            texte: 'Routine',
          ),
        item(
          marque: const Icon(Icons.circle, color: _rouge, size: 9),
          texte: 'Alerte',
        ),
        item(
          marque: Container(
            width: 12,
            height: 9,
            decoration: BoxDecoration(
              color: _secondaire.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          texte: 'Données manquantes',
        ),
      ],
    );
  }
}