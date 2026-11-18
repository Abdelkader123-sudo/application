import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'auth_service.dart';

class NouveauClientPage extends StatefulWidget {
  const NouveauClientPage({super.key, required this.versApplication});

  final Widget Function() versApplication;

  @override
  State<NouveauClientPage> createState() => _NouveauClientPageState();
}

class _NouveauClientPageState extends State<NouveauClientPage> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _nom = TextEditingController();
  final _motDePasse = TextEditingController();
  final _confirmation = TextEditingController();
  bool _envoi = false;
  String? _erreur;

  @override
  void dispose() {
    _code.dispose();
    _nom.dispose();
    _motDePasse.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _creer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _envoi = true;
      _erreur = null;
    });

    try {
      final auth = AuthService.instance;
      await auth.creerNouveauClient(
        codeActivation: _code.text.trim(),
        nom: _nom.text.trim(),
        motDePasse: _motDePasse.text,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Client créé'),
          content: Text(
            'Votre numéro client est ${auth.utilisateur!.numeroClient}. '
            'Conservez-le pour retrouver et identifier votre espace.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continuer'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => widget.versApplication()),
        (_) => false,
      );
    } on ErreurApi catch (e) {
      if (!mounted) return;
      setState(() {
        _erreur = e.message;
        _envoi = false;
      });
    }
  }

  Future<void> _scannerQr() async {
    final code = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (_) => const ScannerQrPage()));
    if (!mounted || code == null) return;
    setState(() {
      _code.text = code;
      _erreur = null;
    });
  }

  Widget _champ({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool secret = false,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: secret,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: suffix,
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau client')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  'Créez un espace indépendant. Scannez le QR d’activation '
                  'à usage unique fourni par l’administrateur du service.',
                  style: TextStyle(height: 1.5),
                ),
                const SizedBox(height: 20),
                _champ(
                  label: 'Code d’activation',
                  controller: _code,
                  validator: (v) => (v?.trim().isEmpty ?? true)
                      ? 'Le code d’activation est obligatoire.'
                      : null,
                  suffix: IconButton(
                    tooltip: 'Scanner le QR d’activation',
                    onPressed: _envoi ? null : _scannerQr,
                    icon: const Icon(Icons.qr_code_scanner),
                  ),
                ),
                _champ(
                  label: 'Nom du super administrateur',
                  controller: _nom,
                  validator: (v) => (v?.trim().length ?? 0) < 2
                      ? 'Saisissez au moins 2 caractères.'
                      : null,
                ),
                _champ(
                  label: 'Mot de passe (8 caractères minimum)',
                  controller: _motDePasse,
                  secret: true,
                  validator: (v) => (v?.length ?? 0) < 8
                      ? 'Le mot de passe doit contenir au moins 8 caractères.'
                      : null,
                ),
                _champ(
                  label: 'Confirmer le mot de passe',
                  controller: _confirmation,
                  secret: true,
                  validator: (v) => v != _motDePasse.text
                      ? 'Les mots de passe ne correspondent pas.'
                      : null,
                ),
                if (_erreur != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _erreur!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _envoi ? null : _creer,
                  icon: _envoi
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_add_alt_1),
                  label: Text(
                    _envoi ? 'Création en cours…' : 'Créer le compte',
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

class ScannerQrPage extends StatefulWidget {
  const ScannerQrPage({super.key});

  @override
  State<ScannerQrPage> createState() => _ScannerQrPageState();
}

class _ScannerQrPageState extends State<ScannerQrPage> {
  bool _codeLu = false;
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _lireCode(BarcodeCapture capture) {
    if (_codeLu) return;
    final code = capture.barcodes
        .map((barcode) => barcode.rawValue?.trim())
        .whereType<String>()
        .firstWhere((valeur) => valeur.isNotEmpty, orElse: () => '');
    if (code.isEmpty) return;
    _codeLu = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner le QR d’activation')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _lireCode,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Impossible d’ouvrir la caméra. Vérifiez son autorisation '
                  'ou saisissez le code manuellement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          const Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Text(
              'Placez le QR d’activation dans le cadre.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
