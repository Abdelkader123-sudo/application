import 'package:flutter/material.dart';

const _vert = Color(0xFF16845D);
const _fond = Color(0xFFF5F7F5);
const _texte = Color(0xFF18382C);
const _secondaire = Color(0xFF7A8981);
const _bordure = Color(0xFFE6ECE7);
const _vertPale = Color(0xFFE8F5EC);

/// Icône « tracker » : un capteur qui émet un signal (collier connecté).
/// Remplace l'ancienne icône de patte.
const IconData _iconeAnimal = Icons.sensors_rounded;

class HistoriqueAnimauxListPage extends StatefulWidget {
  const HistoriqueAnimauxListPage({
    super.key,
    required this.animalIds,
    required this.onAnimalTap,
    required this.onNavigationSelected,
    this.selectedNavigationIndex = 4,
    this.activitySubtitle = 'Voir l’activité ',
  });

  /// Identifiants affichés dans la liste, par exemple cow01 et cow02.
  final List<String> animalIds;

  /// Branche ce callback sur l’action de navigation déjà utilisée par ton app.
  final ValueChanged<String> onAnimalTap;

  /// Branche ce callback sur la navigation existante de l’application.
  final ValueChanged<int> onNavigationSelected;

  /// 4 correspond à « Historique » dans la barre de navigation ci-dessous.
  final int selectedNavigationIndex;

  final String activitySubtitle;

  /// Image de fond de la page (à ajouter dans assets/images/ et dans pubspec.yaml).
  static const String _imageFond = 'assets/images/historique1.jpg';

  /// Largeur maximale du contenu (utile sur grand écran / web).
  static const double _largeurMax = 640;

  static const _navigationItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.map_outlined),
      activeIcon: Icon(Icons.map_rounded),
      label: 'Carte',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.groups_outlined),
      activeIcon: Icon(Icons.groups_rounded),
      label: 'Troupeaux',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications_none_rounded),
      activeIcon: Icon(Icons.notifications_active_rounded),
      label: 'Alertes',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.pets_outlined),
      activeIcon: Icon(Icons.pets_rounded),
      label: 'Animaux',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.show_chart_rounded),
      activeIcon: Icon(Icons.show_chart_rounded),
      label: 'Historique',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings_rounded),
      label: 'Réglages',
    ),
  ];

  @override
  State<HistoriqueAnimauxListPage> createState() =>
      _HistoriqueAnimauxListPageState();
}

class _HistoriqueAnimauxListPageState extends State<HistoriqueAnimauxListPage> {
  final TextEditingController _rechercheController = TextEditingController();
  String _requete = '';

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  void _onRechercheChanged(String valeur) {
    setState(() => _requete = valeur.trim().toLowerCase());
  }

  void _effacerRecherche() {
    _rechercheController.clear();
    setState(() => _requete = '');
  }

  List<String> get _animauxFiltres {
    if (_requete.isEmpty) return widget.animalIds;
    return widget.animalIds
        .where((id) => id.toLowerCase().contains(_requete))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final navItems = HistoriqueAnimauxListPage._navigationItems;
    final index = widget.selectedNavigationIndex >= 0 &&
            widget.selectedNavigationIndex < navItems.length
        ? widget.selectedNavigationIndex
        : 4;

    final animaux = _animauxFiltres;
    final rechercheActive = _requete.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          HistoriqueAnimauxListPage._imageFond,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(color: _fond),
        ),
        Container(
          color: _fond.withValues(alpha: 0.78),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: _texte,
            surfaceTintColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 20,
            toolbarHeight: 72,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Historique d’activité',
                  style: TextStyle(
                    color: _texte,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Suivi récent de vos animaux',
                  style: TextStyle(
                    color: _secondaire,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: HistoriqueAnimauxListPage._largeurMax,
                ),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
                  children: [
                    const _CarteLstm(),
                    const SizedBox(height: 22),
                    _EnTeteListe(nombreAnimaux: animaux.length),
                    const SizedBox(height: 14),
                    _BarreRecherche(
                      controller: _rechercheController,
                      onChanged: _onRechercheChanged,
                      onClear: _effacerRecherche,
                    ),
                    const SizedBox(height: 16),
                    if (animaux.isEmpty)
                      _ListeVide(
                        titre: rechercheActive
                            ? 'Aucun résultat'
                            : 'Aucun animal à afficher',
                        message: rechercheActive
                            ? 'Aucun animal ne correspond à « ${_rechercheController.text.trim()} ».'
                            : null,
                      )
                    else
                      for (final animalId in animaux) ...[
                        _CarteAnimal(
                          animalId: animalId,
                          sousTitre: widget.activitySubtitle,
                          onTap: () => widget.onAnimalTap(animalId),
                        ),
                        const SizedBox(height: 11),
                      ],
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: index,
            onTap: widget.onNavigationSelected,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: _vert,
            unselectedItemColor: _secondaire,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            items: navItems,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Carte explicative : rôle de la page et du modèle LSTM
// ---------------------------------------------------------------------------
class _CarteLstm extends StatelessWidget {
  const _CarteLstm();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _bordure),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12183A2C),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: _vert,
          collapsedIconColor: _secondaire,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF2FA06F), _vert],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.insights_rounded,
                color: Colors.white, size: 24),
          ),
          title: const Text(
            'Analyse d’activité par LSTM',
            style: TextStyle(
              color: _texte,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          subtitle: const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              'À quoi sert cette page ?',
              style: TextStyle(color: _secondaire, fontSize: 12),
            ),
          ),
          children: const [
            Text(
              'Cette page rassemble l’historique d’activité de chaque '
              'animal. Les données du collier (position GPS et mouvements) '
              'sont analysées par un modèle LSTM, un réseau de neurones '
              'conçu pour comprendre des séquences dans le temps : il ne '
              'regarde pas une mesure isolée, mais la façon dont le '
              'comportement évolue d’heure en heure.',
              style: TextStyle(
                color: _secondaire,
                fontSize: 13,
                height: 1.55,
              ),
            ),
            SizedBox(height: 16),
            _Etape(
              icone: Icons.sensors_rounded,
              titre: 'Collecte',
              texte: 'Le collier envoie régulièrement la position et les '
                  'mouvements de l’animal.',
            ),
            _Etape(
              icone: Icons.memory_rounded,
              titre: 'Analyse LSTM',
              texte: 'Le modèle étudie l’enchaînement des données pour '
                  'reconnaître l’activité : repos, marche, course…',
            ),
            _Etape(
              icone: Icons.fact_check_outlined,
              titre: 'Résultat',
              texte: 'L’historique met en évidence les comportements '
                  'inhabituels pour vous permettre de réagir plus tôt.',
              derniere: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _Etape extends StatelessWidget {
  const _Etape({
    required this.icone,
    required this.titre,
    required this.texte,
    this.derniere = false,
  });

  final IconData icone;
  final String titre;
  final String texte;
  final bool derniere;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: derniere ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _vertPale,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icone, color: _vert, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    color: _texte,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  texte,
                  style: const TextStyle(
                    color: _secondaire,
                    fontSize: 12.5,
                    height: 1.45,
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

class _BarreRecherche extends StatelessWidget {
  const _BarreRecherche({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      cursorColor: _vert,
      style: const TextStyle(
        color: _texte,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'Rechercher par ID (ex : cow01)',
        hintStyle: const TextStyle(
          color: _secondaire,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        prefixIcon: const Icon(Icons.search_rounded, color: _secondaire),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              tooltip: 'Effacer',
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, color: _secondaire),
            );
          },
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _bordure),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _vert, width: 1.4),
        ),
      ),
    );
  }
}

class _EnTeteListe extends StatelessWidget {
  const _EnTeteListe({required this.nombreAnimaux});

  final int nombreAnimaux;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vos animaux',
                style: TextStyle(
                  color: _texte,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Sélectionnez un animal pour consulter son activité.',
                style: TextStyle(
                  color: _secondaire,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _bordure),
          ),
          child: Text(
            '$nombreAnimaux',
            style: const TextStyle(
              color: _vert,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _CarteAnimal extends StatelessWidget {
  const _CarteAnimal({
    required this.animalId,
    required this.sousTitre,
    required this.onTap,
  });

  final String animalId;
  final String sousTitre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final forme = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(19),
      side: const BorderSide(color: _bordure),
    );

    return Semantics(
      button: true,
      label: '$animalId. $sousTitre',
      child: Material(
        color: Colors.white,
        shape: forme,
        child: InkWell(
          onTap: onTap,
          customBorder: forme,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 14,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _vertPale,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      _iconeAnimal,
                      color: _vert,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animalId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _texte,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          sousTitre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _secondaire,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F7F3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: _vert,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListeVide extends StatelessWidget {
  const _ListeVide({required this.titre, this.message});

  final String titre;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _bordure),
      ),
      child: Column(
        children: [
          const Icon(_iconeAnimal, color: _vert, size: 34),
          const SizedBox(height: 12),
          Text(
            titre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _texte,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _secondaire,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}