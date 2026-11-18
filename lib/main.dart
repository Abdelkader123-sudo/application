import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:traceur_app/l10n/app_localizations.dart';
import 'package:traceur_app/locale_controller.dart';

import 'accueil_page.dart'; // AJOUT AUTH : première page de l'application
import 'alertes_page.dart';
import 'animaux_page.dart';
import 'auth_service.dart'; // AJOUT AUTH
import 'carte_page.dart';
import 'fond_controller.dart'; // AJOUT BOUTON IMAGE
import 'fond_page.dart'; // AJOUT BOUTON IMAGE
import 'gestion_utilisateurs_page.dart'; // AJOUT AUTH
import 'lstm_page.dart'; // AJOUT LSTM
import 'messagerie_page.dart';
import 'native/canaux.dart';
import 'parametres_page.dart';
import 'services/historique_activite_page_integrated.dart';
import 'troupeaux_page.dart';
import 'ws_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await appLocaleController.charger();
  await AuthService.instance.restaurerSession();
  runApp(TraceurApp(localeController: appLocaleController));
}

class TraceurApp extends StatefulWidget {
  const TraceurApp({super.key, required this.localeController});

  final LocaleController localeController;

  @override
  State<TraceurApp> createState() => _TraceurAppState();
}

class _TraceurAppState extends State<TraceurApp> {
  final service = WsService();
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    AuthService.instance.addListener(_gererFinSession);
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_gererFinSession);
    service.dispose();
    super.dispose();
  }

  void _gererFinSession() {
    if (AuthService.instance.connecte) return;
    _navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => _construireAccueil()),
      (_) => false,
    );
  }

  /// AJOUT AUTH : accueil -> connexion / inscription -> application.
  Widget _construireAccueil() {
    return AccueilPage(versApplication: () => EcranPrincipal(service: service));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.localeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Traceur GPS',
          theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
          locale: widget.localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => Directionality(
            textDirection: widget.localeController.locale.languageCode == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
          navigatorKey: _navigatorKey,
          home: AuthService.instance.connecte
              ? EcranPrincipal(service: service)
              : _construireAccueil(),
        );
      },
    );
  }
}

/// AJOUT AUTH : ancien contenu de `home:` (pages + barre de navigation),
/// affiché uniquement une fois l'utilisateur connecté.
class EcranPrincipal extends StatefulWidget {
  const EcranPrincipal({super.key, required this.service});

  final WsService service;

  @override
  State<EcranPrincipal> createState() => _EcranPrincipalState();
}

class _EcranPrincipalState extends State<EcranPrincipal>
    with WidgetsBindingObserver {
  int _onglet = 0;
  StreamSubscription<Map<String, Object?>>? _abonnementNotifications;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.service.demarrer();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      _abonnementNotifications = CanauxNatifs.ouverturesNotifications.listen(
        _ouvrirDepuisNotification,
        onError: (Object erreur) {
          debugPrint('Ouverture depuis notification impossible : $erreur');
        },
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        widget.service.reprendre();
        unawaited(AuthService.instance.synchroniserNotificationsMessages());
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        widget.service.suspendre();
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _ouvrirDepuisNotification(Map<String, Object?> donnees) {
    if (!mounted) return;
    setState(() {
      _onglet = donnees['notification_type'] == 'nouveau_message' ? 5 : 2;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _abonnementNotifications?.cancel();
    widget.service.arreter();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final service = widget.service;
    final pages = [
      CartePage(service: service),
      TroupeauxPage(service: service),
      AlertesPage(service: service),
      AnimauxPage(service: service),
      HistoriqueSelectionPage(service: service),
      const MessageriePage(),
      const ParametresPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _onglet, children: pages),
      bottomNavigationBar: Builder(
        builder: (context) {
          final fondBarre = Theme.of(context).colorScheme.surfaceContainer;
          // Barre de navigation + boutons (image, compte) à droite.
          return Material(
            color: fondBarre,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: NavigationBar(
                    backgroundColor: fondBarre,
                    selectedIndex: _onglet,
                    onDestinationSelected: (i) => setState(() => _onglet = i),
                    destinations: [
                      NavigationDestination(
                        icon: const Icon(Icons.map),
                        label: loc.mapTab,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.groups),
                        label: loc.herdsTab,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.notifications),
                        label: loc.alertsTab,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.pets),
                        label: loc.animalsTab,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.timeline),
                        label: loc.historyTab,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.forum_outlined),
                        label: loc.messengerTab,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.tune),
                        label: loc.settingsTab,
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  left: false,
                  child: SizedBox(
                    height: 80,
                    width: 56,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _BoutonImage(),
                        const SizedBox(height: 4),
                        const _BoutonCompte(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// AJOUT BOUTON IMAGE : bascule l'image de fond entre l'affichage atténué
/// (voile blanc) et l'affichage naturel (couleurs d'origine).
class _BoutonImage extends StatelessWidget {
  const _BoutonImage();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ValueListenableBuilder<bool>(
      valueListenable: imageNaturelle,
      builder: (context, naturelle, _) {
        return IconButton.filledTonal(
          visualDensity: VisualDensity.compact,
          tooltip: naturelle
              ? loc.toggleBackgroundImage
              : loc.showBackgroundImage,
          onPressed: () => imageNaturelle.value = !naturelle,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Icon(
              naturelle ? Icons.image_rounded : Icons.image_outlined,
              key: ValueKey(naturelle),
            ),
          ),
        );
      },
    );
  }
}

/// AJOUT AUTH : menu du compte. « Gestion des utilisateurs » n'apparaît que
/// pour le superadmin ; « Se déconnecter » ramène à l'accueil.
class _BoutonCompte extends StatelessWidget {
  const _BoutonCompte();

  Future<void> _deconnecter(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await AuthService.instance.deconnecter();
    } on ErreurApi catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final estSuperAdmin = AuthService.instance.estSuperAdmin;

    return SizedBox(
      width: 36,
      height: 36,
      child: PopupMenuButton<String>(
        tooltip: loc.account,
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.account_circle_outlined),
        onSelected: (valeur) {
          if (valeur == 'gestion') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const GestionUtilisateursPage(),
              ),
            );
          } else if (valeur == 'deconnexion') {
            unawaited(_deconnecter(context));
          }
        },
        itemBuilder: (_) => [
          if (estSuperAdmin)
            PopupMenuItem(
              value: 'gestion',
              child: Row(
                children: [
                  const Icon(Icons.manage_accounts_rounded),
                  const SizedBox(width: 12),
                  Text(loc.manageUsers),
                ],
              ),
            ),
          PopupMenuItem(
            value: 'deconnexion',
            child: Row(
              children: [
                const Icon(Icons.logout_rounded),
                const SizedBox(width: 12),
                Text(loc.disconnect),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HistoriqueSelectionPage extends StatefulWidget {
  const HistoriqueSelectionPage({super.key, required this.service});

  final WsService service;

  @override
  State<HistoriqueSelectionPage> createState() =>
      _HistoriqueSelectionPageState();
}

class _HistoriqueSelectionPageState extends State<HistoriqueSelectionPage> {
  static const _vert = Color(0xFF16845D);
  static const _texte = Color(0xFF18382C);
  static const _secondaire = Color(0xFF76847C);
  static const _bordure = Color(0xFFE5ECE7);

  /// Largeur maximale d'une carte (sur téléphone, la carte reste pleine largeur).
  static const double _largeurCarte = 480;

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

  /// Ouvre la page d'analyse LSTM (mouvements agités).
  void _ouvrirLstm(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const LstmPage()));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.service,
      builder: (context, _) {
        final loc = AppLocalizations.of(context)!;
        final ids = widget.service.positions.keys.toList()..sort();
        final filtres = _requete.isEmpty
            ? ids
            : ids.where((id) => id.toLowerCase().contains(_requete)).toList();

        return FondPage(
          image: 'assets/images/historique1.jpg',
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: _texte,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              titleSpacing: 20,
              toolbarHeight: 68,
              title: Text(
                loc.historyTitle,
                style: const TextStyle(
                  color: _texte,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.35,
                ),
              ),
              // AJOUT LSTM : accès à la page d'analyse des mouvements agités
              // (remplace l'ancienne icône de bonhomme qui court).
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: _BoutonLstm(onTap: () => _ouvrirLstm(context)),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: ids.isEmpty
                      ? Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: _etatVide(
                              icone: Icons.timeline_rounded,
                              message: loc.noHistoryAnimals,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: _largeurCarte,
                                  ),
                                  child: _barreRecherche(loc),
                                ),
                              ),
                            ),
                            Expanded(
                              child: filtres.isEmpty
                                  ? Center(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 440,
                                        ),
                                        child: _etatVide(
                                          icone: Icons.search_off_rounded,
                                          message: loc.noAnimalMatchesSearch(
                                            _rechercheController.text.trim(),
                                          ),
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      keyboardDismissBehavior:
                                          ScrollViewKeyboardDismissBehavior
                                              .onDrag,
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        4,
                                        16,
                                        24,
                                      ),
                                      itemCount: filtres.length,
                                      separatorBuilder: (_, _) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        final animalId = filtres[index];

                                        return Center(
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: _largeurCarte,
                                            ),
                                            child: _carteAnimal(
                                              context,
                                              animalId,
                                              loc,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _barreRecherche(AppLocalizations loc) {
    return TextField(
      controller: _rechercheController,
      onChanged: _onRechercheChanged,
      textInputAction: TextInputAction.search,
      cursorColor: _vert,
      style: const TextStyle(
        color: _texte,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: loc.searchAnimalId,
        hintStyle: const TextStyle(
          color: _secondaire,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: _secondaire),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _rechercheController,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              tooltip: loc.clear,
              onPressed: _effacerRecherche,
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

  Widget _carteAnimal(
    BuildContext context,
    String animalId,
    AppLocalizations loc,
  ) {
    final forme = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(19),
      side: const BorderSide(color: _bordure),
    );
    final rayon = BorderRadius.circular(19);

    return Semantics(
      button: true,
      label: '$animalId. ${loc.viewActivityForSevenDays}',
      child: Material(
        color: Colors.white,
        shape: forme,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: rayon,
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HistoriqueActivitePage(animalId: animalId),
              ),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: rayon,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x09183A2C),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5EC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.pets_rounded,
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
                          animalId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _texte,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.viewActivityForSevenDays,
                          style: const TextStyle(
                            color: _secondaire,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F6F2),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: _vert,
                      size: 21,
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

  Widget _etatVide({required IconData icone, required String message}) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _bordure),
        boxShadow: const [
          BoxShadow(
            color: Color(0x09183A2C),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5EC),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icone, color: _vert, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _texte,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AJOUT LSTM : bouton d'accès (remplace l'icône de bonhomme qui court)
// ---------------------------------------------------------------------------
const Color _lstmVert = Color(0xFF16845D);
const Color _lstmBordure = Color(0xFFE5ECE7);

class _BoutonLstm extends StatelessWidget {
  const _BoutonLstm({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Tooltip(
      message: loc.historyAnalysisTooltip,
      child: Material(
        color: Colors.white,
        shape: const StadiumBorder(side: BorderSide(color: _lstmBordure)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.insights_rounded, color: _lstmVert, size: 19),
                const SizedBox(width: 6),
                Text(
                  loc.aiAnalysis,
                  style: const TextStyle(
                    color: _lstmVert,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
