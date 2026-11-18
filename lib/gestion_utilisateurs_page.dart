// lib/gestion_utilisateurs_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traceur_app/l10n/app_localizations.dart';

import 'auth_service.dart';
import 'fond_page.dart';

/// Image de fond de la page. Ajoute ce fichier dans assets/images/
/// (ou remplace le nom par une image que tu as déjà, ex. Groupe.jpg).
const String _imageFond = 'assets/images/utilisateurs.jpg';

const Color _encre = Color(0xFF18352C);
const Color _vert = Color(0xFF23845B);
const Color _secondaire = Color(0xFF708078);
const Color _bleu = Color(0xFF2876D2);
const Color _rouge = Color(0xFFB33C42);
const Color _bordure = Color(0xFFE5ECE7);

const double _largeurMax = 640;

/// Ombre douce commune aux cartes.
const List<BoxShadow> _ombre = [
  BoxShadow(color: Color(0x14183A2C), blurRadius: 18, offset: Offset(0, 6)),
];

String _traduireErreurApi(String message, AppLocalizations loc) {
  if (message ==
      'Connexion impossible. Vérifiez votre réseau puis réessayez.') {
    return loc.authNetworkError;
  }
  if (message == 'Certaines informations sont invalides.') {
    return loc.authInvalidInformation;
  }
  final code = RegExp(r'^Erreur serveur \((\d+)\)\.$').firstMatch(message);
  if (code != null) {
    return loc.authServerError(int.parse(code.group(1)!));
  }
  return message;
}

// ---------------------------------------------------------------------------
// Liste des utilisateurs (réservée au super admin)
// ---------------------------------------------------------------------------
class GestionUtilisateursPage extends StatefulWidget {
  const GestionUtilisateursPage({super.key});

  @override
  State<GestionUtilisateursPage> createState() =>
      _GestionUtilisateursPageState();
}

class _GestionUtilisateursPageState extends State<GestionUtilisateursPage> {
  late Future<List<Utilisateur>> _futur;

  @override
  void initState() {
    super.initState();
    _futur = AuthService.instance.listerUtilisateurs();
  }

  /// Recharge la vraie liste depuis le serveur.
  void _recharger() {
    setState(() => _futur = AuthService.instance.listerUtilisateurs());
  }

  /// Liste actuellement affichée (vide si le chargement a échoué).
  Future<List<Utilisateur>> _listeActuelle() async {
    try {
      return await _futur;
    } catch (_) {
      return [];
    }
  }

  Future<void> _ajouter() async {
    final cree = await Navigator.of(context).push<Utilisateur>(
      MaterialPageRoute(builder: (_) => const FormulaireUtilisateurPage()),
    );
    if (cree == null || !mounted) return;
    final actuelle = await _listeActuelle();
    if (!mounted) return;
    // Mise à jour immédiate de l'écran, sans attendre le serveur.
    setState(() => _futur = Future.value([...actuelle, cree]));
  }

  Future<void> _supprimer(Utilisateur u) async {
    final loc = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: const Icon(Icons.delete_outline_rounded, color: _rouge, size: 30),
        title: Text(
          loc.usersDeleteTitle,
          style: TextStyle(
            color: _encre,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: Text(
          loc.usersDeleteMessage(u.nomComplet),
          textAlign: TextAlign.center,
          style: const TextStyle(color: _secondaire, height: 1.4),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _rouge),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.usersDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AuthService.instance.supprimerUtilisateur(u.id);
      final actuelle = await _listeActuelle();
      if (!mounted) return;
      // Mise à jour immédiate de l'écran, sans attendre le serveur.
      setState(
        () =>
            _futur = Future.value(actuelle.where((x) => x.id != u.id).toList()),
      );
    } on ErreurApi catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_traduireErreurApi(e.message, loc))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return FondPage(
      image: _imageFond,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: _encre,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          toolbarHeight: 68,
          title: Text(
            loc.manageUsers,
            style: TextStyle(
              color: _encre,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.35,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: _vert,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          onPressed: _ajouter,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: Text(
            loc.usersAdd,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: RefreshIndicator(
          color: _vert,
          onRefresh: () async {
            _recharger();
            try {
              await _futur;
            } catch (_) {}
          },
          child: FutureBuilder<List<Utilisateur>>(
            future: _futur,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(color: _vert),
                );
              }
              if (snap.hasError) {
                return _etat(
                  icone: Icons.cloud_off_outlined,
                  couleur: _rouge,
                  message: _traduireErreurApi('${snap.error}', loc),
                  action: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: _vert),
                    onPressed: _recharger,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(loc.retry),
                  ),
                );
              }

              final tous = snap.data ?? [];
              if (tous.isEmpty) {
                return _etat(
                  icone: Icons.group_add_outlined,
                  couleur: _vert,
                  message: loc.usersEmpty,
                );
              }

              final admins = tous.where((u) => u.role == 'admin').toList();
              final normaux = tous.where((u) => u.role != 'admin').toList();

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _largeurMax),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    children: [
                      _resume(admins.length, normaux.length),
                      const SizedBox(height: 18),
                      _titre(
                        loc.usersAdministrators,
                        admins.length,
                        _bleu,
                        Icons.shield_outlined,
                      ),
                      if (admins.isEmpty) _vide(loc.usersNoAdministrators),
                      for (final u in admins) _carte(u),
                      const SizedBox(height: 14),
                      _titre(
                        loc.usersTitle,
                        normaux.length,
                        _vert,
                        Icons.person_outline_rounded,
                      ),
                      if (normaux.isEmpty) _vide(loc.usersNoUsers),
                      for (final u in normaux) _carte(u),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---- États (erreur / vide) -----------------------------------------------
  Widget _etat({
    required IconData icone,
    required Color couleur,
    required String message,
    Widget? action,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _bordure),
                boxShadow: _ombre,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: couleur.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(icone, color: couleur, size: 30),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _encre,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (action != null) ...[const SizedBox(height: 18), action],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---- Bandeau de résumé ---------------------------------------------------
  Widget _resume(int nbAdmins, int nbUtilisateurs) {
    final loc = AppLocalizations.of(context)!;
    Widget bloc(IconData icone, int n, String libelle, Color couleur) {
      return Expanded(
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(icone, color: couleur, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$n',
                    style: const TextStyle(
                      color: _encre,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    libelle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _secondaire,
                      fontSize: 12,
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _bordure),
        boxShadow: _ombre,
      ),
      child: Row(
        children: [
          bloc(Icons.shield_outlined, nbAdmins, loc.usersAdministrators, _bleu),
          Container(width: 1, height: 36, color: _bordure),
          const SizedBox(width: 14),
          bloc(Icons.groups_rounded, nbUtilisateurs, loc.usersTitle, _vert),
        ],
      ),
    );
  }

  // ---- Titre de section (pastille blanche, lisible sur l'image) ------------
  Widget _titre(String texte, int n, Color couleur, IconData icone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _bordure),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icone, size: 16, color: couleur),
              const SizedBox(width: 6),
              Text(
                texte.toUpperCase(),
                style: TextStyle(
                  color: couleur,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: couleur.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$n',
                  style: TextStyle(
                    color: couleur,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vide(String texte) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _bordure),
      ),
      child: Text(
        texte,
        style: const TextStyle(color: _secondaire, fontSize: 12.5),
      ),
    ),
  );

  // ---- Carte d'un utilisateur ----------------------------------------------
  String _initiales(Utilisateur u) {
    String premiere(String s) =>
        s.trim().isEmpty ? '' : s.trim().substring(0, 1).toUpperCase();
    final i = premiere(u.prenom) + premiere(u.nom);
    return i.isEmpty ? '?' : i;
  }

  Widget _carte(Utilisateur u) {
    final loc = AppLocalizations.of(context)!;
    final admin = u.role == 'admin';
    final couleur = admin ? _bleu : _vert;
    final peutSupprimer = u.role != 'superadmin';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _bordure),
        boxShadow: _ombre,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [couleur.withValues(alpha: 0.85), couleur],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _initiales(u),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        u.nomComplet,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _encre,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: couleur.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        admin ? loc.usersAdminRole : loc.usersTitle,
                        style: TextStyle(
                          color: couleur,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _ligne(
                  Icons.cake_outlined,
                  u.age == null ? '—' : loc.usersAge(u.age!),
                ),
                _ligne(
                  Icons.location_on_outlined,
                  u.residence.isEmpty ? '—' : u.residence,
                ),
                _ligne(
                  Icons.phone_outlined,
                  u.telephone.isEmpty ? '—' : u.telephone,
                ),
              ],
            ),
          ),
          if (peutSupprimer)
            PopupMenuButton<String>(
              tooltip: loc.usersActions,
              icon: const Icon(Icons.more_vert_rounded, color: _secondaire),
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onSelected: (v) {
                if (v == 'supprimer') _supprimer(u);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'supprimer',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        color: _rouge,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(loc.usersDelete),
                    ],
                  ),
                ),
              ],
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _ligne(IconData icone, String texte) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Icon(icone, size: 15, color: const Color(0xFF8A958D)),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            texte,
            style: const TextStyle(
              color: _secondaire,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Formulaire d'ajout (le CIN sert de mot de passe)
// Renvoie l'Utilisateur créé à la page de liste (Navigator.pop).
// ---------------------------------------------------------------------------
class FormulaireUtilisateurPage extends StatefulWidget {
  const FormulaireUtilisateurPage({super.key});

  @override
  State<FormulaireUtilisateurPage> createState() =>
      _FormulaireUtilisateurPageState();
}

class _FormulaireUtilisateurPageState extends State<FormulaireUtilisateurPage> {
  final _cle = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _age = TextEditingController();
  final _residence = TextEditingController();
  final _telephone = TextEditingController();
  final _cin = TextEditingController();
  String _role = 'utilisateur';
  bool _envoi = false;
  String? _erreur;

  @override
  void dispose() {
    for (final c in [_nom, _prenom, _age, _residence, _telephone, _cin]) {
      c.dispose();
    }
    super.dispose();
  }

  InputDecoration _deco(String label, IconData icone, {String? aide}) {
    OutlineInputBorder bord(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      labelText: label,
      helperText: aide,
      prefixIcon: Icon(icone, color: _vert, size: 21),
      filled: true,
      fillColor: const Color(0xFFF7FAF8),
      border: bord(_bordure),
      enabledBorder: bord(_bordure),
      focusedBorder: bord(_vert, 1.6),
      errorBorder: bord(_rouge),
      focusedErrorBorder: bord(_rouge, 1.6),
    );
  }

  String? _obligatoire(String? v, AppLocalizations loc) =>
      (v == null || v.trim().isEmpty) ? loc.usersRequiredField : null;

  Future<void> _enregistrer() async {
    if (!_cle.currentState!.validate()) return;
    setState(() {
      _envoi = true;
      _erreur = null;
    });
    try {
      final cree = await AuthService.instance.ajouterUtilisateur(
        nom: _nom.text.trim(),
        prenom: _prenom.text.trim(),
        age: int.parse(_age.text.trim()),
        residence: _residence.text.trim(),
        telephone: _telephone.text.trim(),
        cin: _cin.text.trim(),
        role: _role,
      );
      if (!mounted) return;
      Navigator.of(context).pop(cree);
    } on ErreurApi catch (e) {
      if (!mounted) return;
      setState(() {
        _erreur = _traduireErreurApi(e.message, AppLocalizations.of(context)!);
        _envoi = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return FondPage(
      image: _imageFond,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: _encre,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          toolbarHeight: 68,
          title: Text(
            loc.usersNewUser,
            style: TextStyle(
              color: _encre,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.35,
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _cle,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _bordure),
                      boxShadow: _ombre,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          loc.usersRole,
                          style: const TextStyle(
                            color: _secondaire,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SegmentedButton<String>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: 'utilisateur',
                              label: Text(loc.usersTitle),
                              icon: const Icon(Icons.person_outline_rounded),
                            ),
                            ButtonSegment(
                              value: 'admin',
                              label: Text(loc.usersAdministrator),
                              icon: const Icon(Icons.shield_outlined),
                            ),
                          ],
                          selected: {_role},
                          onSelectionChanged: (s) =>
                              setState(() => _role = s.first),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _nom,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: _deco(
                            loc.authName,
                            Icons.badge_outlined,
                            aide: loc.usersLoginNameHint,
                          ),
                          validator: (v) => _obligatoire(v, loc),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _prenom,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: _deco(
                            loc.usersFirstName,
                            Icons.person_outline_rounded,
                          ),
                          validator: (v) => _obligatoire(v, loc),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _age,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: _deco(
                            loc.usersAgeLabel,
                            Icons.cake_outlined,
                          ),
                          validator: (v) {
                            final n = int.tryParse(v?.trim() ?? '');
                            if (n == null) return loc.usersAgeRequired;
                            if (n < 0 || n > 120) return loc.usersAgeRange;
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _residence,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: _deco(
                            loc.usersResidence,
                            Icons.location_on_outlined,
                          ),
                          validator: (v) => _obligatoire(v, loc),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _telephone,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9+ ]'),
                            ),
                          ],
                          decoration: _deco(
                            loc.usersPhone,
                            Icons.phone_outlined,
                          ),
                          validator: (v) {
                            final t = (v ?? '').replaceAll(' ', '');
                            if (t.length < 6) return loc.usersPhoneInvalid;
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _cin,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          maxLength: 8,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: _deco(
                            loc.usersCinPassword,
                            Icons.key_outlined,
                            aide: loc.usersCinHint,
                          ),
                          validator: (v) => (v ?? '').trim().length == 8
                              ? null
                              : loc.usersCinInvalid,
                        ),
                        if (_erreur != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFECEB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _erreur!,
                              style: const TextStyle(
                                color: _rouge,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 54,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: _vert,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: _envoi ? null : _enregistrer,
                            icon: _envoi
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(_envoi ? loc.usersSaving : loc.save),
                          ),
                        ),
                      ],
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
