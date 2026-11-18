import 'package:flutter/material.dart';
import 'package:traceur_app/l10n/app_localizations.dart';

import 'animaux_api.dart';
import 'fond_page.dart';
import 'ws_service.dart';

class AnimauxPage extends StatefulWidget {
  final WsService service;
  const AnimauxPage({super.key, required this.service});

  @override
  State<AnimauxPage> createState() => _AnimauxPageState();
}

class _AnimauxPageState extends State<AnimauxPage> {
  final _recherche = TextEditingController();
  Map<String, InfoAnimal> _infos = {};
  _ModeAffichage _modeAffichage = _ModeAffichage.cartes;

  static const _vert = Color(0xFF187653);
  static const _orange = Color(0xFFE08A1E);
  static const _rouge = Color(0xFFD34444);
  static const _bleu = Color(0xFF2876D2);
  static const _violet = Color(0xFF9655D8);
  static const _cyan = Color(0xFF00A8C8);
  static const _rose = Color(0xFFE34B8C);
  static const _fond = Color(0xFFF5F8F5);
  static const _texte = Color(0xFF123D2E);

  /// Largeur maximale du contenu (utile sur grand écran / web).
  static const double _largeurMax = 720;

  static const _couleursGroupes = <Color>[
    _bleu,
    _orange,
    _violet,
    _cyan,
    _vert,
    _rose,
  ];

  // Mots-clés de recherche par espèce : chercher « mouton » ou « cheval »
  // retrouve les animaux dont la race appartient à cette espèce.
  static const _motsCles = {
    'Vaches': 'vache bovin',
    'Moutons': 'mouton ovin',
    'Chevaux': 'cheval équin',
  };

  String _espece(String? type) {
    if (type == null) return '';
    for (final e in _FormulaireAnimalState._especes.entries) {
      if (e.value.contains(type)) return _motsCles[e.key] ?? '';
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _charger();
  }

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  Future<void> _charger() async {
    try {
      final infos = await AnimauxApi.lireTous();
      if (!mounted) return;
      setState(() => _infos = infos);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.animalInfoUnavailable} $e',
          ),
        ),
      );
    }
  }

  Future<void> _modifier(String id) async {
    final res = await showModalBottomSheet<InfoAnimal>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      // Fiche de saisie centrée et limitée en largeur sur grand écran
      constraints: const BoxConstraints(maxWidth: _largeurMax),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) =>
          _FormulaireAnimal(id: id, initial: _infos[id] ?? const InfoAnimal()),
    );
    if (res != null && mounted) {
      setState(() => _infos[id] = res);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.animalInfoSaved(id)),
        ),
      );
    }
  }

  List<String> _lireIds(dynamic animaux) {
    if (animaux is! List) return const [];
    return animaux
        .map((animal) {
          if (animal is Map) {
            return (animal['animal_id'] ?? animal['id'] ?? animal['tag'])
                ?.toString();
          }
          return animal?.toString();
        })
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
  }

  /// animal_id -> libellé et couleur, identiques à ceux de la carte.
  Map<String, _GroupeAnimal> _groupes(AppLocalizations loc) {
    final res = <String, _GroupeAnimal>{};
    final t = widget.service.troupeau;
    if (t == null || t['statut'] != 'ok') return res;

    final grand = t['grand_troupeau'];
    if (grand is Map) {
      for (final id in _lireIds(grand['animaux'])) {
        res[id] = _GroupeAnimal(nom: loc.herdGroupLabel, couleur: _bleu);
      }
    }

    final groupes = t['autres_groupes'];
    if (groupes is List) {
      var numeroPetitGroupe = 0;
      var indexCouleur = 1;
      for (final groupe in groupes) {
        if (groupe is! Map) continue;
        final zone = groupe['zone'] is Map ? groupe['zone'] as Map : groupe;
        final ids = _lireIds(zone['animaux'] ?? groupe['animaux']);
        final individuel = ids.length == 1;
        if (!individuel) numeroPetitGroupe++;

        final nom = individuel
            ? loc.isolatedAnimal
            : loc.smallHerdLabel(numeroPetitGroupe);
        final couleur = groupe['depasse_seuil'] == true
            ? _rouge
            : _couleursGroupes[indexCouleur % _couleursGroupes.length];
        indexCouleur++;

        for (final id in ids) {
          res[id] = _GroupeAnimal(nom: nom, couleur: couleur);
        }
      }
    }
    return res;
  }

  String _age(dynamic iso, AppLocalizations loc) {
    final d = DateTime.tryParse('$iso')?.toUtc();
    if (d == null) return '—';
    final s = DateTime.now().toUtc().difference(d).inSeconds;
    if (s < 0) return loc.now;
    if (s < 60) return loc.timeAgo(s, loc.secondsShort);
    if (s < 3600) return loc.timeAgo(s ~/ 60, loc.minutesShort);
    if (s < 86400) return loc.timeAgo(s ~/ 3600, loc.hoursShort);
    return loc.timeAgo(s ~/ 86400, loc.daysShort);
  }

  String _coordonnees(dynamic value, AppLocalizations loc) {
    if (value is! Map) return loc.gpsUnavailable;
    final latitude = value['lat'] ?? value['latitude'];
    final longitude = value['lon'] ?? value['lng'] ?? value['longitude'];
    if (latitude is! num || longitude is! num) return loc.gpsUnavailable;
    return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
  }

  static String? _sexeTexte(String? sexe, AppLocalizations loc) =>
      switch (sexe) {
        'femelle' => loc.female,
        'male' => loc.male,
        _ => null,
      };

  static String? _ageAnimal(double? age, AppLocalizations loc) {
    if (age == null) return null;
    if (age < 1) return loc.ageMonths((age * 12).round());
    if (age == age.roundToDouble()) return loc.ageYears(age.round());
    return '${age.toStringAsFixed(1)} ${loc.yearsUnit}';
  }

  static String? _poidsAnimal(double? poids) {
    if (poids == null) return null;
    return '${poids.toStringAsFixed(poids == poids.roundToDouble() ? 0 : 1)} kg';
  }

  static String? _localiserType(String? type, AppLocalizations loc) {
    if (type == null) return null;
    return switch (type) {
      'Prim’Holstein (Pie-noire)' => loc.breedHolstein,
      'Brune des Alpes (Brune)' => loc.breedBrownSwiss,
      'Tarentaise (Tarasconnaise)' => loc.breedTarentaise,
      'Montbéliarde' => loc.breedMontbeliarde,
      'Normande' => loc.breedNormande,
      'Pie Rouge' => loc.breedRedPied,
      'Jersiaise' => loc.breedJersey,
      "Brune de l'Atlas (vache locale / « Arbi »)" => loc.breedAtlasBrown,
      'Blonde du Cap-Bon' => loc.breedCapBonBlonde,
      'Races croisées' => loc.breedCrossbred,
      'Barbarine (« Arbi »)' => loc.breedBarbarine,
      "Queue Fine de l'Ouest (« Gharbi »)" => loc.breedFineTail,
      'Noire de Thibar' => loc.breedThibar,
      'Sicilo-Sarde' => loc.breedSiciloSarde,
      'Cherki (hybride)' => loc.breedCherki,
      'Barbe (Barbe tunisien)' => loc.breedBarb,
      'Pur-Sang Arabe' => loc.breedArabian,
      'Arabe-Barbe' => loc.breedArabBarb,
      'Poney des Mogods' => loc.breedMogodsPony,
      'Pur-Sang (Anglais)' => loc.breedThoroughbred,
      _ => type,
    };
  }

  static String _localiserEspece(String espece, AppLocalizations loc) =>
      switch (espece) {
        'Vaches' => loc.speciesCattle,
        'Moutons' => loc.speciesSheep,
        'Chevaux' => loc.speciesHorses,
        _ => espece,
      };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.service,
      builder: (context, _) {
        final loc = AppLocalizations.of(context)!;
        final groupes = _groupes(loc);
        final requete = _recherche.text.trim().toLowerCase();
        final positions = widget.service.positions;
        final total = positions.length;

        var ids = positions.keys.map((id) => id.toString()).toList();
        ids.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        ids = ids.where((id) {
          final groupe = groupes[id]?.nom.toLowerCase() ?? '';
          final type = '${_infos[id]?.type ?? ''} ${_espece(_infos[id]?.type)}'
              .toLowerCase();
          return requete.isEmpty ||
              id.toLowerCase().contains(requete) ||
              groupe.contains(requete) ||
              type.contains(requete);
        }).toList();

        return FondPage(
          image: 'assets/images/animal.jpg',
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.white,
              foregroundColor: _texte,
              surfaceTintColor: Colors.white,
              elevation: 0,
              titleSpacing: 16,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loc.myHerd,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _texte,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    loc.animalTrackingLive,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF758178),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Center(
                    child: _BadgeConnexion(connecte: widget.service.connecte),
                  ),
                ),
              ],
            ),
            body: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _largeurMax),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                      child: _StatCard(
                        icon: Icons.pets_rounded,
                        label: loc.trackedAnimals,
                        value: '$total',
                        color: _bleu,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
                      child: TextField(
                        controller: _recherche,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(
                          color: _texte,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: loc.searchAnimalsGroupsTypes,
                          hintStyle: const TextStyle(
                            color: Color(0xFF929C94),
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: _vert,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5ECE6),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5ECE6),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: _vert,
                              width: 1.5,
                            ),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 13,
                            horizontal: 8,
                          ),
                          suffixIcon: requete.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: loc.clearSearch,
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () =>
                                      setState(() => _recherche.clear()),
                                ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<_ModeAffichage>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: _ModeAffichage.cartes,
                              label: Text(loc.cardsView),
                              icon: const Icon(Icons.grid_view_rounded),
                            ),
                            ButtonSegment(
                              value: _ModeAffichage.tableau,
                              label: Text(loc.tableView),
                              icon: const Icon(Icons.table_chart_outlined),
                            ),
                          ],
                          selected: {_modeAffichage},
                          onSelectionChanged: (selection) {
                            setState(() => _modeAffichage = selection.first);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 7),
                      child: Row(
                        children: [
                          Text(
                            loc.animalsHeading,
                            style: const TextStyle(
                              color: Color(0xFF758178),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.7,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            loc.resultCount(ids.length),
                            style: const TextStyle(
                              color: Color(0xFF758178),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ids.isEmpty
                          ? _EtatVide(
                              sansPosition: total == 0,
                              connecte: widget.service.connecte,
                              recherche: requete.isNotEmpty,
                              loc: loc,
                              onReset: () => setState(() => _recherche.clear()),
                            )
                          : switch (_modeAffichage) {
                              _ModeAffichage.cartes => ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  2,
                                  12,
                                  18,
                                ),
                                itemCount: ids.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, i) {
                                  final id = ids[i];
                                  final position = positions[id];
                                  if (position == null) {
                                    return const SizedBox.shrink();
                                  }
                                  final groupe = groupes[id];
                                  return _CarteAnimal(
                                    id: id,
                                    groupe: groupe,
                                    couleur: groupe?.couleur ?? _vert,
                                    info: _infos[id] ?? const InfoAnimal(),
                                    age: _age(position['timestamp'], loc),
                                    coordonnees: _coordonnees(position, loc),
                                    loc: loc,
                                    onModifier: () => _modifier(id),
                                  );
                                },
                              ),
                              _ModeAffichage.tableau => SingleChildScrollView(
                                padding: const EdgeInsets.all(12),
                                child: PanneauLisible(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columns: [
                                        DataColumn(label: Text(loc.identifier)),
                                        DataColumn(label: Text(loc.group)),
                                        DataColumn(label: Text(loc.type)),
                                        DataColumn(label: Text(loc.sex)),
                                        DataColumn(label: Text(loc.age)),
                                        DataColumn(label: Text(loc.weight)),
                                        DataColumn(label: Text(loc.gps)),
                                        DataColumn(
                                          label: Text(loc.lastMeasurement),
                                        ),
                                        DataColumn(label: Text(loc.action)),
                                      ],
                                      rows: ids.map((id) {
                                        final position = positions[id] ?? {};
                                        final groupe = groupes[id];
                                        final info =
                                            _infos[id] ?? const InfoAnimal();
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(id)),
                                            DataCell(Text(groupe?.nom ?? '—')),
                                            DataCell(
                                              Text(
                                                _localiserType(
                                                      info.type,
                                                      loc,
                                                    ) ??
                                                    '—',
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                _sexeTexte(info.sexe, loc) ??
                                                    '—',
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                _ageAnimal(info.age, loc) ??
                                                    '—',
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                _poidsAnimal(info.poids) ?? '—',
                                              ),
                                            ),
                                            DataCell(
                                              Text(_coordonnees(position, loc)),
                                            ),
                                            DataCell(
                                              Text(
                                                _age(
                                                  position['timestamp'],
                                                  loc,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              IconButton(
                                                tooltip: loc.edit,
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                ),
                                                onPressed: () => _modifier(id),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _ModeAffichage { cartes, tableau }

class _GroupeAnimal {
  const _GroupeAnimal({required this.nom, required this.couleur});

  final String nom;
  final Color couleur;
}

// ---------------------------------------------------------------------------
// Fiche de saisie
// ---------------------------------------------------------------------------
class _FormulaireAnimal extends StatefulWidget {
  const _FormulaireAnimal({required this.id, required this.initial});

  final String id;
  final InfoAnimal initial;

  @override
  State<_FormulaireAnimal> createState() => _FormulaireAnimalState();
}

class _FormulaireAnimalState extends State<_FormulaireAnimal> {
  /// Espèces et races proposées (l'ordre est conservé à l'affichage).
  static const _especes = <String, List<String>>{
    'Vaches': [
      'Prim’Holstein (Pie-noire)',
      'Brune des Alpes (Brune)',
      'Tarentaise (Tarasconnaise)',
      'Montbéliarde',
      'Normande',
      'Pie Rouge',
      'Jersiaise',
      "Brune de l'Atlas (vache locale / « Arbi »)",
      'Blonde du Cap-Bon',
      'Races croisées',
    ],
    'Moutons': [
      'Barbarine (« Arbi »)',
      "Queue Fine de l'Ouest (« Gharbi »)",
      'Noire de Thibar',
      'Sicilo-Sarde',
      'Cherki (hybride)',
    ],
    'Chevaux': [
      'Barbe (Barbe tunisien)',
      'Pur-Sang Arabe',
      'Arabe-Barbe',
      'Poney des Mogods',
      'Pur-Sang (Anglais)',
    ],
  };

  final _cle = GlobalKey<FormState>();
  late final TextEditingController _age;
  late final TextEditingController _poids;
  late final TextEditingController _ferme;
  String? _type;
  String? _sexe;
  bool _envoi = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _type = widget.initial.type;
    _sexe = widget.initial.sexe;
    _age = TextEditingController(text: _texteNombre(widget.initial.age));
    _poids = TextEditingController(text: _texteNombre(widget.initial.poids));
    _ferme = TextEditingController(text: widget.initial.ferme);
  }

  @override
  void dispose() {
    _age.dispose();
    _poids.dispose();
    _ferme.dispose();
    super.dispose();
  }

  /// Éléments du menu : un titre non sélectionnable par espèce, puis ses races.
  List<DropdownMenuItem<String>> _itemsTypes(AppLocalizations loc) {
    DropdownMenuItem<String> titre(String t) => DropdownMenuItem<String>(
      value: '#$t', // valeur factice : titre non sélectionnable
      enabled: false,
      child: Text(
        _AnimauxPageState._localiserEspece(t, loc).toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF758178),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
    DropdownMenuItem<String> race(String r) => DropdownMenuItem<String>(
      value: r,
      child: Text(
        _AnimauxPageState._localiserType(r, loc) ?? r,
        overflow: TextOverflow.ellipsis,
      ),
    );

    return [
      for (final e in _especes.entries) ...[titre(e.key), ...e.value.map(race)],
      // Ancienne valeur déjà enregistrée (ex. « Vache laitière ») : on la garde visible.
      if (_type != null && !_especes.values.any((l) => l.contains(_type))) ...[
        titre(loc.currentValue),
        race(_type!),
      ],
    ];
  }

  String _texteNombre(double? v) {
    if (v == null) return '';
    return v == v.roundToDouble() ? v.round().toString() : v.toString();
  }

  double? _nombre(String s) {
    final t = s.trim().replaceAll(',', '.');
    return t.isEmpty ? null : double.tryParse(t);
  }

  String? _validerAge(String? s, AppLocalizations loc) {
    if (s == null || s.trim().isEmpty) return null;
    final v = _nombre(s);
    if (v == null) return loc.invalidNumber;
    if (v < 0 || v > 40) return loc.ageRangeError;
    return null;
  }

  String? _validerPoids(String? s, AppLocalizations loc) {
    if (s == null || s.trim().isEmpty) return null;
    final v = _nombre(s);
    if (v == null) return loc.invalidNumber;
    if (v <= 0 || v > 1500) return loc.weightRangeError;
    return null;
  }

  Future<void> _enregistrer() async {
    final loc = AppLocalizations.of(context)!;
    if (!_cle.currentState!.validate()) return;
    setState(() {
      _envoi = true;
      _erreur = null;
    });
    try {
      final info = InfoAnimal(
        type: _type,
        sexe: _sexe,
        age: _nombre(_age.text),
        poids: _nombre(_poids.text),
        ferme: _ferme.text.trim(),
      );
      final res = await AnimauxApi.enregistrer(widget.id, info);
      if (!mounted) return;
      Navigator.of(context).pop(res);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _envoi = false;
        _erreur = '${loc.saveFailed} $e';
      });
    }
  }

  InputDecoration _deco(String label, IconData icone, {String? suffixe}) {
    OutlineInputBorder bord(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      labelText: label,
      suffixText: suffixe,
      prefixIcon: Icon(icone, color: _AnimauxPageState._vert, size: 20),
      filled: true,
      fillColor: _AnimauxPageState._fond,
      border: bord(const Color(0xFFE5ECE6)),
      enabledBorder: bord(const Color(0xFFE5ECE6)),
      focusedBorder: bord(_AnimauxPageState._vert, 1.5),
      isDense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _cle,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.id,
                style: const TextStyle(
                  color: _AnimauxPageState._texte,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                loc.animalFeatures,
                style: const TextStyle(color: Color(0xFF758178), fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ferme,
                decoration: _deco('Ferme', Icons.agriculture_outlined),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Le nom de la ferme est obligatoire.'
                    : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _type,
                isExpanded: true,
                menuMaxHeight: 380,
                decoration: _deco(loc.typeAndBreed, Icons.category_outlined),
                items: _itemsTypes(loc),
                onChanged: (v) => setState(() => _type = v),
              ),
              const SizedBox(height: 14),
              Text(
                loc.sex,
                style: const TextStyle(
                  color: Color(0xFF758178),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  emptySelectionAllowed: true,
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: 'femelle',
                      label: Text(loc.female),
                      icon: const Icon(Icons.female_rounded),
                    ),
                    ButtonSegment(
                      value: 'male',
                      label: Text(loc.male),
                      icon: const Icon(Icons.male_rounded),
                    ),
                  ],
                  selected: _sexe == null ? <String>{} : {_sexe!},
                  onSelectionChanged: (s) =>
                      setState(() => _sexe = s.isEmpty ? null : s.first),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _age,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _deco(
                        loc.age,
                        Icons.cake_outlined,
                        suffixe: loc.yearsUnit,
                      ),
                      validator: (value) => _validerAge(value, loc),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _poids,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _deco(
                        loc.weight,
                        Icons.monitor_weight_outlined,
                        suffixe: 'kg',
                      ),
                      validator: (value) => _validerPoids(value, loc),
                    ),
                  ),
                ],
              ),
              if (_erreur != null) ...[
                const SizedBox(height: 12),
                Text(
                  _erreur!,
                  style: const TextStyle(
                    color: _AnimauxPageState._rouge,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _envoi
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(loc.cancel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _envoi ? null : _enregistrer,
                      style: FilledButton.styleFrom(
                        backgroundColor: _AnimauxPageState._vert,
                      ),
                      child: _envoi
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(loc.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets d'affichage
// ---------------------------------------------------------------------------
class _BadgeConnexion extends StatelessWidget {
  const _BadgeConnexion({required this.connecte});

  final bool connecte;

  @override
  Widget build(BuildContext context) {
    final color = connecte ? const Color(0xFF218455) : _AnimauxPageState._rouge;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            connecte ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            connecte
                ? AppLocalizations.of(context)!.onlineStatus
                : AppLocalizations.of(context)!.offlineStatus,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5ECE6)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 19,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF758178),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EtatVide extends StatelessWidget {
  const _EtatVide({
    required this.sansPosition,
    required this.connecte,
    required this.recherche,
    required this.onReset,
    required this.loc,
  });

  final bool sansPosition;
  final bool connecte;
  final bool recherche;
  final VoidCallback onReset;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final title = sansPosition
        ? (connecte ? loc.waitingPositions : loc.trackingOffline)
        : loc.noAnimalFound;
    final subtitle = sansPosition
        ? (connecte ? loc.animalsAppearOnGps : loc.connectionInterruptedAnimals)
        : loc.tryDifferentSearch;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4EC),
                borderRadius: BorderRadius.circular(21),
              ),
              child: Icon(
                sansPosition
                    ? (connecte
                          ? Icons.sensors_rounded
                          : Icons.wifi_off_rounded)
                    : Icons.search_off_rounded,
                color: sansPosition && !connecte
                    ? _AnimauxPageState._orange
                    : _AnimauxPageState._vert,
                size: 29,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _AnimauxPageState._texte,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF758178),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            if (!sansPosition && recherche) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.restart_alt_rounded, size: 18),
                label: Text(loc.resetSearch),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CarteAnimal extends StatelessWidget {
  const _CarteAnimal({
    required this.id,
    required this.groupe,
    required this.couleur,
    required this.info,
    required this.age,
    required this.coordonnees,
    required this.onModifier,
    required this.loc,
  });

  final String id;
  final _GroupeAnimal? groupe;
  final Color couleur;
  final InfoAnimal info;
  final String age;
  final String coordonnees;
  final VoidCallback onModifier;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE5ECE6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D183A2C),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: couleur.withValues(alpha: 0.12),
              child: Icon(Icons.pets_rounded, color: couleur, size: 21),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _AnimauxPageState._texte,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton(
                          tooltip: loc.editInformation,
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          color: _AnimauxPageState._vert,
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: onModifier,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 5,
                    children: [
                      _InfoPill(
                        icon: Icons.groups_rounded,
                        label: groupe?.nom ?? loc.unknownGroup,
                        color: groupe?.couleur ?? const Color(0xFF758178),
                      ),
                      _InfoPill(
                        icon: Icons.agriculture_outlined,
                        label: info.ferme,
                        color: _AnimauxPageState._vert,
                      ),
                      if (info.type != null)
                        _InfoPill(
                          icon: Icons.category_outlined,
                          label: _AnimauxPageState._localiserType(
                            info.type,
                            loc,
                          )!,
                          color: _AnimauxPageState._violet,
                        ),
                      if (info.sexeTexte != null)
                        _InfoPill(
                          icon: info.sexe == 'male'
                              ? Icons.male_rounded
                              : Icons.female_rounded,
                          label: info.sexe == 'male' ? loc.male : loc.female,
                          color: info.sexe == 'male'
                              ? _AnimauxPageState._bleu
                              : _AnimauxPageState._rose,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (info.vide)
                    InkWell(
                      onTap: onModifier,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_circle_outline_rounded,
                              size: 14,
                              color: _AnimauxPageState._vert,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              loc.addAnimalDetails,
                              style: const TextStyle(
                                color: _AnimauxPageState._vert,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        if (info.age != null)
                          _DetailAnimal(
                            icon: Icons.cake_outlined,
                            text: _AnimauxPageState._ageAnimal(info.age, loc)!,
                          ),
                        if (info.poids != null)
                          _DetailAnimal(
                            icon: Icons.monitor_weight_outlined,
                            text: _AnimauxPageState._poidsAnimal(info.poids)!,
                          ),
                      ],
                    ),
                  const SizedBox(height: 6),
                  _DetailAnimal(icon: Icons.schedule_rounded, text: age),
                  const SizedBox(height: 4),
                  _DetailAnimal(
                    icon: Icons.location_on_outlined,
                    text: coordonnees,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailAnimal extends StatelessWidget {
  const _DetailAnimal({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF8A958D), size: 13),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF66736A),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
