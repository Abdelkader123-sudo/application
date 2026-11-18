import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traceur_app/l10n/app_localizations.dart';

import 'auth_service.dart';
import 'fond_controller.dart';
import 'messagerie_service.dart';

// ---------------------------------------------------------------------------
// Style commun (look « Messenger »)
// ---------------------------------------------------------------------------

const _bleuMessenger = [Color(0xFF0A7CFF), Color(0xFF6A4CFF)];

const _palette = <List<Color>>[
  [Color(0xFFFF7A59), Color(0xFFFF3D77)],
  [Color(0xFF00C6FF), Color(0xFF0072FF)],
  [Color(0xFF7F7FD5), Color(0xFF86A8E7)],
  [Color(0xFF11998E), Color(0xFF38EF7D)],
  [Color(0xFFF7971E), Color(0xFFFFD200)],
  [Color(0xFFB24592), Color(0xFFF15F79)],
];

List<Color> _degradePour(String seed) {
  final somme = seed.codeUnits.fold<int>(0, (a, b) => a + b);
  return _palette[somme % _palette.length];
}

String _langue(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

String _heureCourte(BuildContext context, DateTime date) {
  final langue = _langue(context);
  final now = DateTime.now();
  final aujourdhui = DateTime(now.year, now.month, now.day);
  final jour = DateTime(date.year, date.month, date.day);
  final ecart = aujourdhui.difference(jour).inDays;
  if (ecart == 0) return DateFormat.Hm(langue).format(date);
  if (ecart < 7) return DateFormat.E(langue).format(date);
  return DateFormat.Md(langue).format(date);
}

String _separateurDate(BuildContext context, DateTime date) {
  final langue = _langue(context);
  final now = DateTime.now();
  final meme =
      now.year == date.year && now.month == date.month && now.day == date.day;
  final heure = DateFormat.Hm(langue).format(date);
  if (meme) return heure;
  return '${DateFormat.MMMEd(langue).format(date)} · $heure';
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.nom, this.groupe = false, this.radius = 26});

  final String nom;
  final bool groupe;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final couleurs = _degradePour(nom);
    final propre = nom.trim();
    return Container(
      width: radius * 2,
      height: radius * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: couleurs,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: groupe
          ? Icon(Icons.groups_rounded, color: Colors.white, size: radius * 1.05)
          : Text(
              propre.isEmpty ? '?' : propre.characters.first.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.85,
              ),
            ),
    );
  }
}

class _BoutonRond extends StatelessWidget {
  const _BoutonRond({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: couleurs.surfaceContainerHighest,
        foregroundColor: couleurs.onSurface,
      ),
      icon: Icon(icon, size: 22),
    );
  }
}

// ---------------------------------------------------------------------------
// Fond d'écran + effet « verre »
// ---------------------------------------------------------------------------

/// Image de fond. Déclare-la dans pubspec.yaml (voir instructions).
/// Si le fichier est absent, un fond dégradé est affiché à la place.
const _fondAsset = 'assets/images/message.jpg';

class _FondMessagerie extends StatelessWidget {
  const _FondMessagerie();

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    final base = Theme.of(context).colorScheme.surface;
    return ValueListenableBuilder<bool>(
      valueListenable: imageNaturelle,
      builder: (context, naturelle, _) => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _fondAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const _MotifFond(),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  base.withValues(
                    alpha: naturelle ? 0 : (sombre ? 0.70 : 0.78),
                  ),
                  base.withValues(
                    alpha: naturelle ? 0 : (sombre ? 0.86 : 0.90),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: naturelle ? 1 : 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        base.withValues(alpha: sombre ? 0.92 : 0.92),
                        base.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MotifFond extends StatelessWidget {
  const _MotifFond();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF0A7CFF), Color(0xFF6A4CFF), Color(0xFFFF3D77)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: CustomPaint(painter: _CerclesPainter(), size: Size.infinite),
  );
}

class _CerclesPainter extends CustomPainter {
  const _CerclesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final pinceau = Paint()..color = Colors.white.withValues(alpha: 0.12);
    final w = size.width;
    final h = size.height;
    canvas.drawCircle(Offset(w * 0.1, h * 0.12), w * 0.35, pinceau);
    canvas.drawCircle(Offset(w * 0.95, h * 0.35), w * 0.28, pinceau);
    canvas.drawCircle(Offset(w * 0.2, h * 0.7), w * 0.25, pinceau);
    canvas.drawCircle(Offset(w * 0.85, h * 0.92), w * 0.4, pinceau);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Conteneur translucide flouté (glassmorphism).
class _Verre extends StatelessWidget {
  const _Verre({required this.child, this.rayon = 24, this.padding});

  final Widget child;
  final double rayon;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(rayon),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: couleurs.surface.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(rayon),
            border: Border.all(
              color: couleurs.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Liste des discussions
// ---------------------------------------------------------------------------

class MessageriePage extends StatefulWidget {
  const MessageriePage({super.key});

  @override
  State<MessageriePage> createState() => _MessageriePageState();
}

class _MessageriePageState extends State<MessageriePage> {
  final MessagerieService _service = MessagerieService();
  final TextEditingController _recherche = TextEditingController();
  List<ConversationMessagerie> _conversations = [];
  List<ContactMessagerie> _contacts = [];
  String _filtre = 'tout';
  String _requete = '';
  String? _erreur;
  bool _chargement = true;

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
      final conversations = await _service.listerConversations();
      if (!mounted) return;
      setState(() {
        _conversations = conversations;
        _erreur = null;
        _chargement = false;
      });
      _chargerContactsRapides();
    } on ErreurApi catch (e) {
      if (!mounted) return;
      setState(() {
        _erreur = e.message;
        _chargement = false;
      });
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() {
        _erreur = e.message;
        _chargement = false;
      });
    }
  }

  /// Contacts affichés en haut de la liste (accès rapide). Erreurs ignorées.
  Future<void> _chargerContactsRapides() async {
    try {
      final contacts = await _service.listerContacts();
      if (!mounted) return;
      setState(() => _contacts = contacts);
    } on ErreurApi catch (_) {
    } on FormatException catch (_) {}
  }

  /// Exécute [action] en affichant les erreurs dans un SnackBar.
  Future<T?> _garde<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ErreurApi catch (e) {
      if (mounted) _afficherErreur(e.message);
    } on FormatException catch (e) {
      if (mounted) _afficherErreur(e.message);
    }
    return null;
  }

  Future<void> _nouvelleDiscussion() async {
    final loc = AppLocalizations.of(context)!;
    final contacts = await _garde(_service.listerContacts);
    if (!mounted || contacts == null) return;
    if (contacts.isEmpty) {
      _afficherErreur(loc.messengerNoUsers);
      return;
    }
    final choix = await _selectionnerContacts(
      context,
      contacts: contacts,
      multiple: false,
      titre: loc.messengerNewDiscussion,
      action: loc.messengerContinue,
    );
    if (choix == null || choix.contacts.isEmpty) return;
    await _ouvrirAvec(choix.contacts.single);
  }

  Future<void> _ouvrirAvec(ContactMessagerie contact) async {
    final conversation = await _garde(
      () => _service.ouvrirConversation(contact.id),
    );
    if (!mounted || conversation == null) return;
    await _ouvrirConversation(conversation);
  }

  Future<void> _nouveauGroupe() async {
    final loc = AppLocalizations.of(context)!;
    final contacts = await _garde(_service.listerContacts);
    if (!mounted || contacts == null) return;
    if (contacts.isEmpty) {
      _afficherErreur(loc.messengerNoUsers);
      return;
    }
    final choix = await _selectionnerContacts(
      context,
      contacts: contacts,
      multiple: true,
      titre: loc.messengerCreateGroup,
      action: loc.messengerCreate,
      demandeTitre: true,
    );
    if (choix == null) return;
    if (choix.contacts.isEmpty) {
      _afficherErreur(loc.messengerSelectOne);
      return;
    }
    if (choix.titre.trim().isEmpty) {
      _afficherErreur(loc.messengerGroupNameRequired);
      return;
    }
    final conversation = await _garde(
      () => _service.creerGroupe(
        titre: choix.titre.trim(),
        membres: choix.contacts.map((contact) => contact.id).toList(),
      ),
    );
    if (!mounted || conversation == null) return;
    await _ouvrirConversation(conversation);
  }

  Future<void> _ouvrirConversation(ConversationMessagerie conversation) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            ConversationPage(service: _service, conversation: conversation),
      ),
    );
    if (mounted) await _charger();
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

  String _nomContact(ConversationMessagerie c, String? utilisateurId) {
    if (c.estGroupe) return c.titre;
    final autre = c.membres
        .where((membre) => membre.id != utilisateurId)
        .firstOrNull;
    return autre?.nomComplet ?? c.titre;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final couleurs = Theme.of(context).colorScheme;
    final utilisateurId = AuthService.instance.utilisateur?.id;

    final conversations =
        _conversations.where((conversation) {
          if (_filtre == 'prives' && conversation.estGroupe) return false;
          if (_filtre == 'groupes' && !conversation.estGroupe) return false;
          return _nomContact(
            conversation,
            utilisateurId,
          ).toLowerCase().contains(_requete);
        }).toList()..sort((a, b) {
          final da = a.dernierMessage?.creeLe;
          final db = b.dernierMessage?.creeLe;
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return db.compareTo(da);
        });

    final contactsRapides = _contacts
        .where((contact) => contact.id != utilisateurId)
        .take(15)
        .toList();
    final afficherContacts =
        _requete.isEmpty && _filtre == 'tout' && contactsRapides.isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _FondMessagerie()),
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // En-tête
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
                      child: Row(
                        children: [
                          if (Navigator.of(context).canPop())
                            IconButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              icon: const Icon(Icons.arrow_back),
                            )
                          else
                            const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              loc.messengerTitle,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          _BoutonRond(
                            icon: Icons.edit_square,
                            tooltip: loc.messengerNewConversation,
                            onPressed: _afficherNouveauMenu,
                          ),
                        ],
                      ),
                    ),
                    // Recherche
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: TextField(
                        controller: _recherche,
                        onChanged: (value) => setState(
                          () => _requete = value.trim().toLowerCase(),
                        ),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: loc.messengerSearch,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _requete.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _recherche.clear();
                                    setState(() => _requete = '');
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                          filled: true,
                          fillColor: couleurs.surface.withValues(alpha: 0.72),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    // Filtres
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _chipFiltre('tout', loc.messengerAll),
                          _chipFiltre('prives', loc.messengerPrivate),
                          _chipFiltre('groupes', loc.messengerGroups),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: _chargement
                          ? const Center(child: CircularProgressIndicator())
                          : _erreur != null
                          ? _etatErreur(loc)
                          : RefreshIndicator(
                              onRefresh: _charger,
                              child: CustomScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                slivers: [
                                  if (afficherContacts)
                                    SliverToBoxAdapter(
                                      child: _rangeeContacts(contactsRapides),
                                    ),
                                  if (conversations.isEmpty)
                                    SliverFillRemaining(
                                      hasScrollBody: false,
                                      child: _etatVide(
                                        loc.messengerNoConversations,
                                      ),
                                    )
                                  else
                                    SliverPadding(
                                      padding: const EdgeInsets.only(
                                        bottom: 24,
                                      ),
                                      sliver: SliverList.builder(
                                        itemCount: conversations.length,
                                        itemBuilder: (context, index) =>
                                            _tuileConversation(
                                              conversations[index],
                                              utilisateurId,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ), // fin Column
              ), // fin ConstrainedBox
            ), // fin Center
          ), // fin SafeArea
        ],
      ),
    );
  }

  Widget _chipFiltre(String valeur, String label) {
    final couleurs = Theme.of(context).colorScheme;
    final actif = _filtre == valeur;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: actif,
        showCheckmark: false,
        onSelected: (_) => setState(() => _filtre = valeur),
        shape: const StadiumBorder(),
        side: BorderSide.none,
        backgroundColor: couleurs.surface.withValues(alpha: 0.72),
        selectedColor: couleurs.primaryContainer,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: actif ? couleurs.onPrimaryContainer : couleurs.onSurface,
        ),
      ),
    );
  }

  Widget _rangeeContacts(List<ContactMessagerie> contacts) {
    return SizedBox(
      height: 98,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          final prenom = contact.prenom.isEmpty ? contact.nom : contact.prenom;
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _ouvrirAvec(contact),
            child: SizedBox(
              width: 70,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Avatar(nom: contact.nomComplet, radius: 28),
                  const SizedBox(height: 6),
                  Text(
                    prenom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _etatErreur(AppLocalizations loc) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 44),
          const SizedBox(height: 12),
          Text(
            _erreur ?? loc.messengerLoadingError,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () {
              setState(() => _chargement = true);
              _charger();
            },
            child: Text(loc.messengerRetry),
          ),
        ],
      ),
    ),
  );

  Widget _etatVide(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );

  Widget _tuileConversation(
    ConversationMessagerie conversation,
    String? utilisateurId,
  ) {
    final couleurs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: couleurs.surface.withValues(alpha: 0.74),
          child: _contenuTuile(conversation, utilisateurId),
        ),
      ),
    );
  }

  Widget _contenuTuile(
    ConversationMessagerie conversation,
    String? utilisateurId,
  ) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final titre = _nomContact(conversation, utilisateurId);
    final dernier = conversation.dernierMessage;
    final apercu = dernier == null
        ? loc.messengerNoMessages
        : '${dernier.senderId == utilisateurId ? '${loc.messengerYou} : ' : ''}'
              '${dernier.texte}';

    return InkWell(
      onTap: () => _ouvrirConversation(conversation),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _Avatar(nom: titre, groupe: conversation.estGroupe, radius: 29),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre.isEmpty ? loc.messengerTitle : titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          apercu,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (dernier != null)
                        Text(
                          ' · ${_heureCourte(context, dernier.creeLe)}',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _afficherNouveauMenu() async {
    final loc = AppLocalizations.of(context)!;
    final choix = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_add_alt_1)),
              title: Text(
                loc.messengerNewDiscussion,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () => Navigator.pop(context, 'discussion'),
            ),
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.group_add_outlined),
              ),
              title: Text(
                loc.messengerCreateGroup,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () => Navigator.pop(context, 'groupe'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (choix == 'discussion') await _nouvelleDiscussion();
    if (choix == 'groupe') await _nouveauGroupe();
  }
}

// ---------------------------------------------------------------------------
// Page de conversation
// ---------------------------------------------------------------------------

class ConversationPage extends StatefulWidget {
  const ConversationPage({
    super.key,
    required this.service,
    required this.conversation,
  });

  final MessagerieService service;
  final ConversationMessagerie conversation;

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _message = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final Set<String> _heuresVisibles = {};
  late ConversationMessagerie _conversation;
  List<MessageMessagerie> _messages = [];
  bool _chargement = true;
  bool _envoiEnCours = false;
  bool _chargementMessagesEnCours = false;
  bool _afficherBoutonBas = false;
  String? _erreur;
  Timer? _actualisation;

  @override
  void initState() {
    super.initState();
    _conversation = widget.conversation;
    _scroll.addListener(_surDefilement);
    _chargerMessages(initial: true);
    _actualisation = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _chargerMessages(),
    );
  }

  @override
  void dispose() {
    _actualisation?.cancel();
    _message.dispose();
    _scroll.removeListener(_surDefilement);
    _scroll.dispose();
    super.dispose();
  }

  void _surDefilement() {
    if (!_scroll.hasClients) return;
    final loin =
        _scroll.position.maxScrollExtent - _scroll.position.pixels > 400;
    if (loin != _afficherBoutonBas) setState(() => _afficherBoutonBas = loin);
  }

  Future<void> _chargerMessages({bool initial = false}) async {
    if (_chargementMessagesEnCours) return;
    _chargementMessagesEnCours = true;
    final presDuBas =
        !_scroll.hasClients ||
        _scroll.position.maxScrollExtent - _scroll.position.pixels < 180;
    try {
      final messages = await widget.service.listerMessages(
        widget.conversation.id,
      );
      if (!mounted) return;
      final nouvelArrivant = messages.length > _messages.length;
      setState(() {
        _messages = messages;
        _erreur = null;
        _chargement = false;
      });
      if (initial || (presDuBas && nouvelArrivant)) _allerEnBas(!initial);
    } on ErreurApi catch (e) {
      if (!mounted) return;
      setState(() {
        _erreur = e.message;
        if (initial || _messages.isEmpty) _chargement = false;
      });
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() {
        _erreur = e.message;
        if (initial || _messages.isEmpty) _chargement = false;
      });
    } finally {
      _chargementMessagesEnCours = false;
    }
  }

  void _allerEnBas([bool animer = true]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final cible = _scroll.position.maxScrollExtent;
      if (animer) {
        _scroll.animateTo(
          cible,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      } else {
        _scroll.jumpTo(cible);
      }
    });
  }

  Future<void> _envoyer() async {
    final texte = _message.text.trim();
    if (texte.isEmpty || _envoiEnCours) return;
    setState(() => _envoiEnCours = true);
    try {
      await widget.service.envoyerMessage(widget.conversation.id, texte);
      if (!mounted) return;
      _message.clear();
      await _chargerMessages();
      _allerEnBas();
    } on ErreurApi catch (e) {
      if (mounted) _afficherErreur(e.message);
    } on FormatException catch (e) {
      if (mounted) _afficherErreur(e.message);
    } finally {
      if (mounted) setState(() => _envoiEnCours = false);
    }
  }

  Future<void> _ajouterParticipants() async {
    final loc = AppLocalizations.of(context)!;
    try {
      final contacts = await widget.service.listerContacts();
      if (!mounted) return;
      final membresActuels = _conversation.membres
          .map((membre) => membre.id)
          .toSet();
      final disponibles = contacts
          .where((contact) => !membresActuels.contains(contact.id))
          .toList();
      if (disponibles.isEmpty) {
        _afficherErreur(loc.messengerNoUsers);
        return;
      }
      final choix = await _selectionnerContacts(
        context,
        contacts: disponibles,
        multiple: true,
        titre: loc.messengerAddMembers,
        action: loc.messengerAddMembers,
      );
      if (choix == null || choix.contacts.isEmpty) return;
      final conversation = await widget.service.ajouterMembres(
        _conversation.id,
        choix.contacts.map((contact) => contact.id).toList(),
      );
      if (!mounted) return;
      setState(() => _conversation = conversation);
      await _chargerMessages();
    } on ErreurApi catch (e) {
      if (mounted) _afficherErreur(e.message);
    } on FormatException catch (e) {
      if (mounted) _afficherErreur(e.message);
    }
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

  ContactMessagerie? _autreMembre() {
    final moi = AuthService.instance.utilisateur?.id;
    return _conversation.membres
        .where((membre) => membre.id != moi)
        .firstOrNull;
  }

  String _nomConversation() {
    if (_conversation.estGroupe) return _conversation.titre;
    return _autreMembre()?.nomComplet ?? widget.conversation.titre;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final couleurs = Theme.of(context).colorScheme;
    final moi = AuthService.instance.utilisateur?.id;
    final nom = _nomConversation();
    final sousTitre = _conversation.estGroupe
        ? '${_conversation.membres.length} ${loc.messengerMembers}'
        : _autreMembre()?.role;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(color: couleurs.surface.withValues(alpha: 0.6)),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            _Avatar(nom: nom, groupe: _conversation.estGroupe, radius: 19),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  if (sousTitre != null && sousTitre.isNotEmpty)
                    Text(
                      sousTitre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: couleurs.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_conversation.estGroupe)
            IconButton(
              tooltip: loc.messengerAddMembers,
              onPressed: _ajouterParticipants,
              icon: Icon(Icons.person_add_alt_1, color: couleurs.primary),
            ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _FondMessagerie()),
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: _corps(loc, moi)),
                    Positioned(
                      right: 16,
                      bottom: 12,
                      child: AnimatedScale(
                        scale: _afficherBoutonBas ? 1 : 0,
                        duration: const Duration(milliseconds: 150),
                        child: FloatingActionButton.small(
                          heroTag: null,
                          elevation: 2,
                          onPressed: _allerEnBas,
                          child: const Icon(Icons.keyboard_arrow_down_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _barreSaisie(loc),
            ],
          ),
        ],
      ),
    );
  }

  Widget _corps(AppLocalizations loc, String? moi) {
    if (_chargement) return const Center(child: CircularProgressIndicator());
    if (_erreur != null && _messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_erreur!),
            TextButton(
              onPressed: () {
                setState(() => _chargement = true);
                _chargerMessages(initial: true);
              },
              child: Text(loc.messengerRetry),
            ),
          ],
        ),
      );
    }
    if (_messages.isEmpty) {
      final nom = _nomConversation();
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Avatar(nom: nom, groupe: _conversation.estGroupe, radius: 40),
            const SizedBox(height: 12),
            Text(
              nom,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(loc.messengerNoMessages),
          ],
        ),
      );
    }
    return Column(
      children: [
        if (_erreur != null)
          MaterialBanner(
            content: Text(_erreur!),
            actions: [
              TextButton(
                onPressed: () => _chargerMessages(),
                child: Text(loc.messengerRetry),
              ),
            ],
          ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: EdgeInsets.fromLTRB(
              10,
              MediaQuery.paddingOf(context).top + kToolbarHeight + 8,
              10,
              12,
            ),
            itemCount: _messages.length,
            itemBuilder: (context, index) => _elementMessage(index, moi),
          ),
        ),
      ],
    );
  }

  static const _ecartSeparateur = Duration(minutes: 30);

  Widget _elementMessage(int index, String? moi) {
    final message = _messages[index];
    final precedent = index > 0 ? _messages[index - 1] : null;
    final suivant = index < _messages.length - 1 ? _messages[index + 1] : null;

    final separateur =
        precedent == null ||
        message.creeLe.difference(precedent.creeLe) >= _ecartSeparateur;
    final groupeAvecPrecedent =
        !separateur &&
        // ignore: unnecessary_null_comparison
        precedent != null &&
        precedent.senderId == message.senderId;
    final groupeAvecSuivant =
        suivant != null &&
        suivant.senderId == message.senderId &&
        suivant.creeLe.difference(message.creeLe) < _ecartSeparateur;

    return Column(
      children: [
        if (separateur)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: _Verre(
              rayon: 14,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                _separateurDate(context, message.creeLe),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        _bulle(
          message,
          moi,
          premier: !groupeAvecPrecedent,
          dernier: !groupeAvecSuivant,
        ),
      ],
    );
  }

  Widget _bulle(
    MessageMessagerie message,
    String? utilisateurId, {
    required bool premier,
    required bool dernier,
  }) {
    final estMoi = message.senderId == utilisateurId;
    final membre = _conversation.membres
        .where((contact) => contact.id == message.senderId)
        .firstOrNull;
    final couleurs = Theme.of(context).colorScheme;
    const grand = Radius.circular(20);
    const petit = Radius.circular(5);

    final rayon = BorderRadiusDirectional.only(
      topStart: estMoi ? grand : (premier ? grand : petit),
      bottomStart: estMoi ? grand : (dernier ? grand : petit),
      topEnd: estMoi ? (premier ? grand : petit) : grand,
      bottomEnd: estMoi ? (dernier ? grand : petit) : grand,
    );

    final afficherAvatar = !estMoi && _conversation.estGroupe;
    final heureVisible = _heuresVisibles.contains(message.id);

    final bulle = GestureDetector(
      onTap: () => setState(() {
        if (!_heuresVisibles.remove(message.id)) {
          _heuresVisibles.add(message.id);
        }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: rayon,
          color: estMoi ? null : couleurs.surface.withValues(alpha: 0.94),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          gradient: estMoi
              ? const LinearGradient(
                  colors: _bleuMessenger,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Text(
          message.texte,
          style: TextStyle(
            fontSize: 15.5,
            height: 1.25,
            color: estMoi ? Colors.white : couleurs.onSurface,
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(top: premier ? 6 : 0, bottom: dernier ? 2 : 2),
      child: Row(
        mainAxisAlignment: estMoi
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (afficherAvatar)
            SizedBox(
              width: 34,
              child: dernier
                  ? _Avatar(nom: membre?.nomComplet ?? '', radius: 14)
                  : null,
            ),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.75,
              ),
              child: Column(
                crossAxisAlignment: estMoi
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (afficherAvatar && premier)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 2),
                      child: Text(
                        membre?.nomComplet ?? '',
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: couleurs.onSurfaceVariant),
                      ),
                    ),
                  bulle,
                  AnimatedSize(
                    duration: const Duration(milliseconds: 150),
                    child: heureVisible
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: 3,
                              left: 6,
                              right: 6,
                            ),
                            child: Text(
                              DateFormat.Hm(_langue(context))
                                  .format(message.creeLe),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: couleurs.onSurfaceVariant),
                            ),
                          )
                        : const SizedBox(width: 0, height: 0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barreSaisie(AppLocalizations loc) {
    final couleurs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _Verre(
                rayon: 26,
                child: TextField(
                  controller: _message,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: loc.messengerMessageHint,
                    filled: false,
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _message,
              builder: (context, valeur, _) {
                final actif = valeur.text.trim().isNotEmpty || _envoiEnCours;
                return Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: Tooltip(
                    message: loc.messengerSend,
                    child: GestureDetector(
                      onTap: _envoiEnCours ? null : _envoyer,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: actif
                              ? const LinearGradient(
                                  colors: _bleuMessenger,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: actif
                              ? null
                              : couleurs.surface.withValues(alpha: 0.7),
                          boxShadow: actif
                              ? [
                                  BoxShadow(
                                    color: _bleuMessenger.first.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: _envoiEnCours
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  Icons.send_rounded,
                                  size: 22,
                                  color: actif
                                      ? Colors.white
                                      : couleurs.onSurfaceVariant,
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sélecteur de contacts (bottom sheet)
// ---------------------------------------------------------------------------

class _ChoixContacts {
  const _ChoixContacts({required this.contacts, this.titre = ''});

  final List<ContactMessagerie> contacts;
  final String titre;
}

Future<_ChoixContacts?> _selectionnerContacts(
  BuildContext context, {
  required List<ContactMessagerie> contacts,
  required bool multiple,
  required String titre,
  required String action,
  bool demandeTitre = false,
}) {
  return showModalBottomSheet<_ChoixContacts>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _SelecteurContacts(
      contacts: contacts,
      multiple: multiple,
      titre: titre,
      action: action,
      demandeTitre: demandeTitre,
    ),
  );
}

class _SelecteurContacts extends StatefulWidget {
  const _SelecteurContacts({
    required this.contacts,
    required this.multiple,
    required this.titre,
    required this.action,
    required this.demandeTitre,
  });

  final List<ContactMessagerie> contacts;
  final bool multiple;
  final String titre;
  final String action;
  final bool demandeTitre;

  @override
  State<_SelecteurContacts> createState() => _SelecteurContactsState();
}

class _SelecteurContactsState extends State<_SelecteurContacts> {
  final Set<String> _selection = {};
  final TextEditingController _titreGroupe = TextEditingController();
  String _requete = '';
  String? _erreurTitre;

  @override
  void dispose() {
    _titreGroupe.dispose();
    super.dispose();
  }

  void _valider() {
    final loc = AppLocalizations.of(context)!;
    if (widget.demandeTitre && _titreGroupe.text.trim().isEmpty) {
      setState(() => _erreurTitre = loc.messengerGroupNameRequired);
      return;
    }
    Navigator.pop(
      context,
      _ChoixContacts(
        contacts: widget.contacts
            .where((contact) => _selection.contains(contact.id))
            .toList(),
        titre: _titreGroupe.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final couleurs = Theme.of(context).colorScheme;
    final visibles = widget.contacts
        .where((c) => c.nomComplet.toLowerCase().contains(_requete))
        .toList();
    final selectionnes = widget.contacts
        .where((contact) => _selection.contains(contact.id))
        .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  widget.titre,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (widget.demandeTitre)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TextField(
                  controller: _titreGroupe,
                  maxLength: 80,
                  onChanged: (_) {
                    if (_erreurTitre != null) {
                      setState(() => _erreurTitre = null);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: loc.messengerGroupName,
                    errorText: _erreurTitre,
                    counterText: '',
                    prefixIcon: const Icon(Icons.group_outlined),
                    filled: true,
                    fillColor: couleurs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                onChanged: (v) =>
                    setState(() => _requete = v.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: loc.messengerSearch,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: couleurs.surfaceContainerHighest,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (selectionnes.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: selectionnes.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final contact = selectionnes[index];
                    return InputChip(
                      avatar: _Avatar(nom: contact.nomComplet, radius: 12),
                      label: Text(contact.nomComplet),
                      onDeleted: () =>
                          setState(() => _selection.remove(contact.id)),
                    );
                  },
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: visibles.length,
                itemBuilder: (context, index) {
                  final contact = visibles[index];
                  final choisi = _selection.contains(contact.id);
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: _Avatar(nom: contact.nomComplet, radius: 22),
                    title: Text(
                      contact.nomComplet,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(contact.role),
                    trailing: widget.multiple
                        ? Icon(
                            choisi
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: choisi ? couleurs.primary : couleurs.outline,
                          )
                        : null,
                    onTap: () {
                      if (!widget.multiple) {
                        Navigator.pop(
                          context,
                          _ChoixContacts(contacts: [contact]),
                        );
                        return;
                      }
                      setState(() {
                        if (choisi) {
                          _selection.remove(contact.id);
                        } else {
                          _selection.add(contact.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            if (widget.multiple)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _selection.isEmpty ? null : _valider,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        _selection.isEmpty
                            ? widget.action
                            : '${widget.action} (${_selection.length})',
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
