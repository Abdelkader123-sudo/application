import 'package:flutter/material.dart';
import 'package:traceur_app/l10n/app_localizations.dart';

import 'fond_page.dart';
import 'ws_service.dart';

const Color _encre = Color(0xFF18352C);
const Color _vert = Color(0xFF23845B);
const Color _texteSecondaire = Color(0xFF708078);

Map<String, dynamic>? _asMap(dynamic valeur) {
  if (valeur is Map) {
    return Map<String, dynamic>.from(valeur);
  }
  return null;
}

List<dynamic> _asList(dynamic valeur) {
  return valeur is List ? valeur : const <dynamic>[];
}

int _asInt(dynamic valeur) {
  if (valeur is num) return valeur.toInt();
  return int.tryParse(valeur?.toString() ?? '') ?? 0;
}

String _nombreLisible(dynamic valeur) {
  if (valeur == null) return '—';

  if (valeur is num && valeur == valeur.roundToDouble()) {
    return valeur.toInt().toString();
  }

  return valeur.toString();
}

List<String> _identifiantsAnimaux(dynamic valeur) {
  return _asList(valeur)
      .where((animal) => animal != null)
      .map((animal) => animal.toString())
      .toList();
}

class TroupeauxPage extends StatelessWidget {
  final WsService service;

  const TroupeauxPage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        return _construirePage(context, service.troupeau);
      },
    );
  }

  Widget _construirePage(BuildContext context, dynamic donnees) {
    final loc = AppLocalizations.of(context)!;
    final troupeau = _asMap(donnees);
    final statutOk = troupeau?['statut'] == 'ok';
    final grandTroupeau = statutOk ? _asMap(troupeau?['grand_troupeau']) : null;

    final autresGroupes = _asList(troupeau?['autres_groupes'])
        .map(_asMap)
        .whereType<Map<String, dynamic>>()
        .toList();

    return FondPage(
      image: 'assets/images/Groupe.jpg',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: _encre,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 76,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.herdsTab,
                style: const TextStyle(
                  color: _encre,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                loc.herdOverviewTitle,
                style: const TextStyle(
                  color: _texteSecondaire,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        body: grandTroupeau == null
            ? _construireEtatVide(troupeau, statutOk, loc)
            : _construireContenu(grandTroupeau, autresGroupes, loc),
      ),
    );
  }

  Widget _construireEtatVide(
    Map<String, dynamic>? troupeau,
    bool statutOk,
    AppLocalizations loc,
  ) {
    final bool enAttente = troupeau == null;
    final String titre;
    final String description;

    if (enAttente) {
      titre = loc.waitingForData;
      description = loc.groupsWillAppearHere;
    } else if (statutOk) {
      titre = loc.herdDataIncomplete;
      description = loc.grandHerdNotYetDisplayed;
    } else {
      titre = loc.noHerdDetected;
      description = loc.groupAppearsWhenEnoughAnimals;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: _vert.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                enAttente
                    ? Icons.hourglass_top_rounded
                    : Icons.groups_2_outlined,
                size: 36,
                color: _vert,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _encre,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _texteSecondaire, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireContenu(
    Map<String, dynamic> grandTroupeau,
    List<Map<String, dynamic>> autresGroupes,
    AppLocalizations loc,
  ) {
    final animauxGrandTroupeau = _identifiantsAnimaux(grandTroupeau['animaux']);

    final animauxGrand = _asInt(
      grandTroupeau['nb_animaux'] ?? animauxGrandTroupeau.length,
    );

    final nombreIsoles = autresGroupes
        .where((groupe) => groupe['type'] == 'individuel')
        .length;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            _construireEntete(
              loc: loc,
              animauxGrand: animauxGrand,
              nombreGroupes: autresGroupes.length,
              nombreIsoles: nombreIsoles,
            ),
            const SizedBox(height: 20),
            _construireCarteGrandTroupeau(
              grandTroupeau,
              animauxGrandTroupeau,
              animauxGrand,
              loc,
            ),
            const SizedBox(height: 26),
            _construireTitreGroupes(autresGroupes.length, loc),
            const SizedBox(height: 12),
            if (autresGroupes.isEmpty)
              _construireAucunAutreGroupe(loc)
            else
              for (final groupe in autresGroupes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _construireCarteGroupe(groupe, loc),
                ),
          ],
        ),
      ),
    );
  }

  Widget _construireEntete({
    required AppLocalizations loc,
    required int animauxGrand,
    required int nombreGroupes,
    required int nombreIsoles,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E5F43), Color(0xFF23845B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _vert.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        loc.herdTracking,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      loc.currentComposition,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      loc.herdCompositionDescription,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.groups_2_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _construireStatistique(
                  valeur: animauxGrand.toString(),
                  libelle: loc.herdGroupLabel,
                  icone: Icons.groups_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _construireStatistique(
                  valeur: nombreGroupes.toString(),
                  libelle: loc.isolatedGroups,
                  icone: Icons.group_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _construireStatistique(
                  valeur: nombreIsoles.toString(),
                  libelle: loc.animalsAlone,
                  icone: Icons.pets_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construireStatistique({
    required String valeur,
    required String libelle,
    required IconData icone,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 17, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(height: 8),
          Text(
            valeur,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            libelle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 10,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireCarteGrandTroupeau(
    Map<String, dynamic> grandTroupeau,
    List<String> animaux,
    int nombreAnimaux,
    AppLocalizations loc,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDEBE2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080D2B1D),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _vert.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.groups_rounded, color: _vert),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.herdGroupLabel,
                      style: const TextStyle(
                        color: _encre,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      loc.animalsInGroup(nombreAnimaux),
                      style: const TextStyle(
                        color: _texteSecondaire,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          Text(
            loc.animalsInGroupLabel,
            style: const TextStyle(
              color: _texteSecondaire,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _construireAnimaux(animaux, loc),
        ],
      ),
    );
  }

  Widget _construireTitreGroupes(int nombre, AppLocalizations loc) {
    return Row(
      children: [
        Expanded(
          child: Text(
            loc.otherGroups,
            style: const TextStyle(
              color: _encre,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE9EFEB),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            '$nombre',
            style: const TextStyle(
              color: _encre,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _construireAucunAutreGroupe(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEEA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: _vert),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              loc.noOtherGroups,
              style: const TextStyle(color: _texteSecondaire, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireCarteGroupe(
    Map<String, dynamic> groupe,
    AppLocalizations loc,
  ) {
    final estIndividuel = groupe['type'] == 'individuel';
    final depasseSeuil = groupe['depasse_seuil'] == true;
    final zone = _asMap(groupe['zone']) ?? <String, dynamic>{};
    final animaux = _identifiantsAnimaux(zone['animaux']);
    final nombreAnimaux = _asInt(zone['nb_animaux'] ?? animaux.length);
    final ecart = groupe['ecart_m'];

    final Color couleur = depasseSeuil
        ? const Color(0xFFB33C42)
        : const Color(0xFFB77828);

    final IconData icone = estIndividuel
        ? Icons.pets_rounded
        : Icons.group_outlined;

    final String titre = estIndividuel ? loc.isolatedAnimal : loc.smallHerd;
    final String libelleAnimaux = loc.animalsInGroup(nombreAnimaux);
    final String distance = ecart == null
        ? loc.distanceUnavailable
        : loc.distanceFromMainHerd(_nombreLisible(ecart));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EEEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060D2B1D),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: couleur.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icone, color: couleur),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titre,
                      style: const TextStyle(
                        color: _encre,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      libelleAnimaux,
                      style: const TextStyle(
                        color: _texteSecondaire,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _construireBadge(
                depasseSeuil ? loc.thresholdExceeded : loc.belowThreshold,
                couleur: couleur,
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.near_me_outlined,
                size: 16,
                color: _texteSecondaire,
              ),
              const SizedBox(width: 6),
              Text(
                distance,
                style: const TextStyle(color: _texteSecondaire, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _construireAnimaux(animaux, loc),
        ],
      ),
    );
  }

  Widget _construireBadge(String texte, {required Color couleur}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        texte,
        style: TextStyle(
          color: couleur,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _construireAnimaux(List<String> animaux, AppLocalizations loc) {
    if (animaux.isEmpty) {
      return Text(
        loc.animalIdsUnavailable,
        style: const TextStyle(
          color: _texteSecondaire,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        for (final animal in animaux)
          Container(
            constraints: const BoxConstraints(maxWidth: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              animal,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _encre,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
