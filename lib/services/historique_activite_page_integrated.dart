import 'package:flutter/material.dart';
import 'package:traceur_app/l10n/app_localizations.dart';
import 'package:traceur_app/services/historique_activite.dart';

import '../services/historique_service.dart';

class HistoriqueActivitePage extends StatefulWidget {
  const HistoriqueActivitePage({
    super.key,
    required this.animalId,
    this.nomAnimal,
  });

  final String animalId;
  final String? nomAnimal;

  @override
  State<HistoriqueActivitePage> createState() => _HistoriqueActivitePageState();
}

enum _Niveau { calme, normal, eleve, inconnu, partiel }

/// Un jour est évalué (calme / normal / actif) seulement s'il a au moins
/// ce nombre d'heures de mesures. En dessous, il est considéré « partiel » :
/// jamais d'alerte, et masqué s'il s'agit du tout premier jour de la base.
const int _heuresMinJour = 12;

class _StatJour {
  _StatJour(this.jour);

  final DateTime jour;
  bool aMesures = false;

  /// Nombre d'heures avec une mesure réelle ce jour-là.
  int heures = 0;
  double reel = 0;
  double reelRef = 0;
  double attendu = 0;
  bool aReference = false;

  /// Total « habituel » connu pour ce jour, même sans mesure réelle
  /// (sert uniquement à dessiner la barre grise).
  double attenduTotal = 0;

  /// Valeur comparable à « attendu » (mêmes points que la référence).
  double get affiche => aReference ? reelRef : reel;

  double? get ratio => (aReference && attendu > 0) ? reelRef / attendu : null;

  bool get partiel => aMesures && heures < _heuresMinJour;
}

class _Analyse {
  _Analyse({required this.jours});

  final List<_StatJour> jours;
}

class _HistoriqueActivitePageState extends State<HistoriqueActivitePage> {
  // Le serveur garde 14 jours de mesures : on les charge toujours toutes,
  // puis on filtre sur la période choisie (pas de rechargement au curseur).
  static const _joursMax = 7;

  static const _vert = Color(0xFF187653);
  static const _orange = Color(0xFFE08A1E);
  static const _rouge = Color(0xFFD34444);
  static const _fond = Color(0xFFF3F7F3);
  static const _texte = Color(0xFF123D2E);
  static const _texteSecondaire = Color(0xFF758178);
  static const _bordure = Color(0xFFE4EBE5);
  static const _gris = Color(0xFFB9C3BC);

  static const _seuilCalme = 0.6;
  static const _seuilEleve = 1.4;

  final _service = HistoriqueService();
  int _joursChoisis = 7;
  late Future<HistoriqueActivite> _future;

  @override
  void initState() {
    super.initState();
    _future = _charger();
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }

  Future<HistoriqueActivite> _charger() async {
    try {
      return await _service.charger(widget.animalId, heures: _joursMax * 24);
    } catch (e, st) {
      debugPrint('Erreur historique ${widget.animalId} : $e\n$st');
      rethrow;
    }
  }

  // IMPORTANT : accolades obligatoires. Avec « => », le callback de setState
  // renverrait le Future et Flutter annulerait la mise à jour.
  void _recharger() {
    setState(() {
      _future = _charger();
    });
  }

  Future<void> _onRefresh() async {
    _recharger();
    try {
      await _future;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final nom = widget.nomAnimal ?? widget.animalId;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/historique2.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const ColoredBox(color: _fond),
        ),
        Container(color: _fond.withValues(alpha: 0.85)),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: _texte,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 16,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.historyTitle,
                  style: const TextStyle(
                    color: _texte,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _texteSecondaire,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          body: RefreshIndicator(
            color: _vert,
            onRefresh: _onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: FutureBuilder<HistoriqueActivite>(
                      future: _future,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return _avecSelecteur(_chargement());
                        }
                        if (snap.hasError) {
                          return _avecSelecteur(_erreur(snap.error!));
                        }
                        final historique = snap.data;
                        if (historique == null) {
                          return _avecSelecteur(
                            _erreur(Exception('Réponse vide')),
                          );
                        }
                        return _avecSelecteur(_contenu(historique));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Sélecteur de période suivi du corps de la page.
  Widget _avecSelecteur(Widget corps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_selecteurPeriode(), const SizedBox(height: 16), corps],
    );
  }

  // ── Sélecteur de période ───────────────────────────────────────────────────

  Widget _selecteurPeriode() {
    final loc = AppLocalizations.of(context)!;
    return _carte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _vert.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.date_range_rounded,
                  color: _vert,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.historyPeriod,
                      style: const TextStyle(
                        color: _texte,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      loc.historyPeriodHint,
                      style: const TextStyle(
                        color: _texteSecondaire,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _vert,
                    inactiveTrackColor: _vert.withValues(alpha: 0.16),
                    thumbColor: _vert,
                    activeTickMarkColor: Colors.white.withValues(alpha: 0.7),
                    inactiveTickMarkColor: _vert.withValues(alpha: 0.35),
                    overlayColor: _vert.withValues(alpha: 0.10),
                    valueIndicatorColor: _vert,
                  ),
                  child: Slider(
                    value: _joursChoisis.toDouble(),
                    min: 1,
                    max: _joursMax.toDouble(),
                    divisions: _joursMax - 1,
                    label: '$_joursChoisis ${loc.dayShort}',
                    onChanged: (v) => setState(() => _joursChoisis = v.round()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _vert.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  loc.dayCount(_joursChoisis),
                  style: const TextStyle(
                    color: _vert,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chargement() {
    final loc = AppLocalizations.of(context)!;
    return _carte(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 38),
        child: Column(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: _vert),
            ),
            SizedBox(height: 14),
            Text(
              loc.loadingHistory,
              style: const TextStyle(
                color: _texteSecondaire,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _erreur(Object error) {
    final loc = AppLocalizations.of(context)!;
    var message = loc.errorOccurred;
    var reessayer = true;

    if (error is HistoriqueException) {
      switch (error.type) {
        case HistoriqueErreur.aucuneMesure:
          message = loc.noMeasurementForAnimal;
          reessayer = false;
          break;
        case HistoriqueErreur.serviceIndisponible:
          message = loc.analysisServiceUnavailable;
          break;
        case HistoriqueErreur.reseau:
          message = loc.historyNetworkError;
          break;
        case HistoriqueErreur.requeteInvalide:
          message = loc.invalidHistoryPeriod;
          break;
        case HistoriqueErreur.inconnue:
          message = loc.historyLoadError;
          break;
      }
    }

    return _carte(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: _rouge.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: _rouge,
                size: 27,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              loc.historyUnavailable,
              style: const TextStyle(
                color: _texte,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _texteSecondaire,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            if (reessayer) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _recharger,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _vert,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  loc.retry,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Contenu ────────────────────────────────────────────────────────────────

  Widget _contenu(HistoriqueActivite historique) {
    if (historique.points.isEmpty) return _aucuneDonnee();

    if (historique.insuffisant ||
        historique.points.every((p) => p.pasAttendus == null)) {
      return _historiqueInsuffisant(historique);
    }

    // Analyse faite UNE seule fois sur toutes les données : le statut d'un
    // jour ne dépend jamais de la période choisie.
    final analyse = _analyser(historique.points);
    if (analyse.jours.isEmpty) return _aucuneDonnee();

    final disponibles = _nbJoursDisponibles(analyse);
    final nombre = _joursChoisis < disponibles ? _joursChoisis : disponibles;
    final fenetre = _fenetre(analyse, nombre);
    if (fenetre.isEmpty) return _aucuneDonnee();

    return _carteBarres(fenetre);
  }

  Widget _historiqueInsuffisant(HistoriqueActivite historique) {
    final loc = AppLocalizations.of(context)!;
    final message = historique.raison ?? loc.insufficientHistoryExplanation;

    return _carte(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: _orange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: _orange,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              loc.insufficientAiReference,
              style: const TextStyle(
                color: _texte,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _texteSecondaire,
                fontSize: 12,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _Analyse _analyser(List<PointActivite> points) {
    final parJour = <DateTime, _StatJour>{};

    for (final p in points) {
      final pas = p.pas;
      final attendu = p.pasAttendus;

      // Rien d'exploitable dans ce point.
      if (pas == null && attendu == null) continue;

      // toLocal() évite un décalage d'un jour si l'heure est en UTC.
      final date = p.heure.toLocal();
      final cle = DateTime(date.year, date.month, date.day);
      final jour = parJour.putIfAbsent(cle, () => _StatJour(cle));

      if (attendu != null) {
        jour.attenduTotal += attendu;
      }

      if (pas != null) {
        jour.aMesures = true;
        jour.heures += 1;
        jour.reel += pas;
        if (attendu != null) {
          jour.reelRef += pas;
          jour.attendu += attendu;
          jour.aReference = true;
        }
      }
    }

    final jours = parJour.values.toList()
      ..sort((a, b) => a.jour.compareTo(b.jour));
    return _Analyse(jours: jours);
  }

  /// Nombre de jours (calendaires) entre le premier et le dernier jour qui
  /// ont des données, bornes comprises.
  int _nbJoursDisponibles(_Analyse analyse) {
    final dernier = analyse.jours.last.jour;
    final premier = analyse.jours.first.jour;
    return DateTime.utc(dernier.year, dernier.month, dernier.day)
            .difference(DateTime.utc(premier.year, premier.month, premier.day))
            .inDays +
        1;
  }

  /// Les N derniers jours, comptés depuis le dernier jour qui a des données.
  /// Le tout premier jour de la base est masqué s'il est incomplet (la
  /// collecte commence en cours de journée). Un jour sans mesure au milieu
  /// reste dans la liste.
  List<_StatJour> _fenetre(_Analyse analyse, int nombre) {
    final dernier = analyse.jours.last.jour;
    final premier = analyse.jours.first;
    final index = {for (final j in analyse.jours) j.jour: j};
    final resultat = <_StatJour>[];
    for (var k = nombre - 1; k >= 0; k--) {
      final d = DateTime(dernier.year, dernier.month, dernier.day - k);
      if (d == premier.jour && premier.partiel) continue;
      resultat.add(index[d] ?? _StatJour(d));
    }
    return resultat;
  }

  _Niveau _niveau(_StatJour j) {
    if (!j.aMesures) return _Niveau.inconnu;
    // Journée trop incomplète pour être jugée : jamais d'alerte.
    if (j.partiel) return _Niveau.partiel;
    final ratio = j.ratio;
    if (ratio == null) return _Niveau.inconnu;
    if (ratio < _seuilCalme) return _Niveau.calme;
    if (ratio > _seuilEleve) return _Niveau.eleve;
    return _Niveau.normal;
  }

  Color _couleurNiveau(_Niveau n) {
    switch (n) {
      case _Niveau.calme:
        return _orange;
      case _Niveau.normal:
        return _vert;
      case _Niveau.eleve:
        return _rouge;
      case _Niveau.inconnu:
        return _vert;
      case _Niveau.partiel:
        return _texteSecondaire;
    }
  }

  String _etiquette(_StatJour j, _Niveau n) {
    final loc = AppLocalizations.of(context)!;
    if (!j.aMesures) return loc.noMeasurement;
    switch (n) {
      case _Niveau.calme:
        return loc.calm;
      case _Niveau.normal:
        return loc.normalActivity;
      case _Niveau.eleve:
        return loc.active;
      case _Niveau.inconnu:
        return loc.measured;
      case _Niveau.partiel:
        return loc.partial;
    }
  }

  String _etiquetteLongue(_StatJour j, _Niveau n) {
    final loc = AppLocalizations.of(context)!;
    if (!j.aMesures) return loc.noMeasurementThisDay;
    switch (n) {
      case _Niveau.calme:
        return loc.calmerThanUsualLong;
      case _Niveau.normal:
        return loc.usualActivity;
      case _Niveau.eleve:
        return loc.moreActiveThanUsualLong;
      case _Niveau.inconnu:
        return loc.noReferenceForComparison;
      case _Niveau.partiel:
        return loc.incompleteDayNoEvaluation(j.heures);
    }
  }

  String _nombre(num valeur) {
    final s = valeur.round().toString();
    final tampon = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) tampon.write('\u202F');
      tampon.write(s[i]);
    }
    return tampon.toString();
  }

  String _jourMois(DateTime d) {
    final jour = d.day.toString().padLeft(2, '0');
    final mois = d.month.toString().padLeft(2, '0');
    return '$jour/$mois';
  }

  String _nomJour(int weekday) {
    final loc = AppLocalizations.of(context)!;
    return switch (weekday) {
      DateTime.monday => loc.daysMondayShort,
      DateTime.tuesday => loc.daysTuesdayShort,
      DateTime.wednesday => loc.daysWednesdayShort,
      DateTime.thursday => loc.daysThursdayShort,
      DateTime.friday => loc.daysFridayShort,
      DateTime.saturday => loc.daysSaturdayShort,
      _ => loc.daysSundayShort,
    };
  }

  // ── Histogramme : mesuré vs habituel ───────────────────────────────────────

  Widget _carteBarres(List<_StatJour> jours) {
    final loc = AppLocalizations.of(context)!;
    var maximum = 1.0;
    for (final j in jours) {
      if (j.affiche > maximum) maximum = j.affiche;
      if (j.attenduTotal > maximum) maximum = j.attenduTotal;
    }

    return _sectionGraphique(
      icon: Icons.bar_chart_rounded,
      titre: loc.activityChartTitle,
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, contraintes) {
              const largeurMin = 58.0;
              final largeur = (contraintes.maxWidth / jours.length)
                  .clamp(largeurMin, 120.0)
                  .toDouble();
              final contenuLarge = largeur * jours.length;

              final barres = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final j in jours)
                    SizedBox(
                      width: largeur,
                      child: _colonneJour(j, maximum, loc),
                    ),
                ],
              );

              if (contenuLarge <= contraintes.maxWidth) return barres;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: SizedBox(width: contenuLarge, child: barres),
              );
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _pastille(_vert, loc.normalActivity),
              _pastille(_orange, loc.calmerThanUsual),
              _pastille(_rouge, loc.moreActiveThanUsual),
              _pastille(_gris, loc.usualRhythmAi),
            ],
          ),
        ],
      ),
    );
  }

  Widget _colonneJour(_StatJour j, double maximum, AppLocalizations loc) {
    const hauteur = 120.0;
    const largeurBarre = 16.0;

    final niveau = _niveau(j);
    final couleur = _couleurNiveau(niveau);

    double haut(double v) =>
        (v / maximum * hauteur).clamp(3.0, hauteur).toDouble();

    final hReel = j.aMesures ? haut(j.affiche) : 0.0;
    final hAttendu = j.attenduTotal > 0 ? haut(j.attenduTotal) : 0.0;

    final usualSteps = j.attenduTotal > 0
        ? '\n${loc.usualStepsTooltip(_nombre(j.attenduTotal))}'
        : '';
    final message =
        '${_nomJour(j.jour.weekday)} ${_jourMois(j.jour)}\n'
        '${_etiquetteLongue(j, niveau)}$usualSteps';

    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      child: Column(
        children: [
          // Zone des barres (fond de repère + ligne de base).
          Container(
            height: hauteur,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _bordure, width: 1.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: largeurBarre,
                  height: hReel,
                  decoration: BoxDecoration(
                    color: couleur,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: largeurBarre,
                  height: hAttendu,
                  decoration: BoxDecoration(
                    color: _gris,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _nomJour(j.jour.weekday),
            style: const TextStyle(
              color: _texteSecondaire,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            _jourMois(j.jour),
            style: const TextStyle(
              color: _texte,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _etiquette(j, niveau),
            style: TextStyle(
              color: j.aMesures ? couleur : _texteSecondaire,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pastille(Color couleur, String texte) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: couleur,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          texte,
          style: const TextStyle(
            color: _texteSecondaire,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _sectionGraphique({
    required IconData icon,
    required String titre,
    required Widget contenu,
  }) {
    return _carte(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _vert.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _vert, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titre,
                  style: const TextStyle(
                    color: _texte,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          contenu,
        ],
      ),
    );
  }

  Widget _aucuneDonnee() {
    final loc = AppLocalizations.of(context)!;
    return _carte(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: _orange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.show_chart_rounded,
                color: _orange,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              loc.noDataYet,
              style: const TextStyle(
                color: _texte,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              loc.noActivityForAnimal,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _texteSecondaire,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _carte({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _bordure),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A183A2C),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
