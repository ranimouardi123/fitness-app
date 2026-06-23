import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class AjouterAdherentScreen extends StatefulWidget {
  final int? adherentId;
  const AjouterAdherentScreen({super.key, this.adherentId});
  @override
  State<AjouterAdherentScreen> createState() => _AjouterAdherentScreenState();
}

class _AjouterAdherentScreenState extends State<AjouterAdherentScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nomCtrl     = TextEditingController();
  final _prenomCtrl  = TextEditingController();
  final _telCtrl     = TextEditingController();
  final _objectifCtrl = TextEditingController();
  final _poidsCtrl   = TextEditingController();
  final _tailleCtrl  = TextEditingController();

  String? _codeAcces;
  String? _photoBase64; // photo stockée en base64
  bool _loading = false;
  bool get _enModif => widget.adherentId != null;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (_enModif) _chargerAdherent();
  }

  Future<void> _chargerAdherent() async {
    final a = await DatabaseHelper.instance.getAdherentParId(widget.adherentId!);
    if (a == null) return;
    setState(() {
      _nomCtrl.text      = a['nom']       ?? '';
      _prenomCtrl.text   = a['prenom']    ?? '';
      _telCtrl.text      = a['telephone'] ?? '';
      _objectifCtrl.text = a['objectif']  ?? '';
      _poidsCtrl.text    = a['poids']  != null ? '${a['poids']}'  : '';
      _tailleCtrl.text   = a['taille'] != null ? '${a['taille']}' : '';
      _codeAcces         = a['code_acces'];
      _photoBase64       = a['photo'];
    });
  }

  @override
  void dispose() {
    _nomCtrl.dispose(); _prenomCtrl.dispose(); _telCtrl.dispose();
    _objectifCtrl.dispose(); _poidsCtrl.dispose(); _tailleCtrl.dispose();
    super.dispose();
  }

  // ─── Choisir photo ───────────────────────────────────────────
  Future<void> _choisirPhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.blanc,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.grisClair,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.orange.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: AppTheme.orange)),
            title: const Text('Prendre une photo',
                style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () { Navigator.pop(ctx); _prendrePhoto(ImageSource.camera); },
          ),
          ListTile(
            leading: Container(width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.photo_library, color: AppTheme.primary)),
            title: const Text('Choisir depuis la galerie',
                style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () { Navigator.pop(ctx); _prendrePhoto(ImageSource.gallery); },
          ),
          if (_photoBase64 != null) ListTile(
            leading: Container(width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline, color: AppTheme.danger)),
            title: const Text('Supprimer la photo',
                style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.danger)),
            onTap: () { Navigator.pop(ctx); setState(() => _photoBase64 = null); },
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Future<void> _prendrePhoto(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 80,
    );
    if (file == null) return;
    final bytes = await File(file.path).readAsBytes();
    setState(() => _photoBase64 = base64Encode(bytes));
  }

  // ─── Sauvegarder ─────────────────────────────────────────────
  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final code = _enModif ? _codeAcces : AuthService.genererCodeAcces();

    final data = {
      'nom':        _nomCtrl.text.trim(),
      'prenom':     _prenomCtrl.text.trim(),
      'telephone':  _telCtrl.text.trim(),
      'objectif':   _objectifCtrl.text.trim(),
      'role':       'adherent',
      'code_acces': code,
      'photo':      _photoBase64,
      if (_poidsCtrl.text.isNotEmpty)
        'poids': double.tryParse(_poidsCtrl.text),
      if (_tailleCtrl.text.isNotEmpty)
        'taille': double.tryParse(_tailleCtrl.text),
      if (!_enModif)
        'date_creation': DateTime.now().toIso8601String(),
    };

    if (_enModif) {
      await DatabaseHelper.instance.modifierAdherent(widget.adherentId!, data);
    } else {
      await DatabaseHelper.instance.ajouterAdherent(data);
    }

    setState(() => _loading = false);
    if (mounted) {
      if (!_enModif) await _afficherCodeAcces(code!);
      context.pop();
    }
  }

  Future<void> _afficherCodeAcces(String code) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Adhérent créé !'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Transmettez ce code à votre adhérent :',
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: Text(code,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                    letterSpacing: 3, color: AppTheme.primary,
                    fontFamily: 'monospace')),
          ),
          const SizedBox(height: 12),
          const Text('Il pourra accéder à son programme depuis l\'écran d\'accueil.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ]),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK, j\'ai noté'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initiales = '${_prenomCtrl.text.isNotEmpty ? _prenomCtrl.text[0] : ''}'
        '${_nomCtrl.text.isNotEmpty ? _nomCtrl.text[0] : ''}'.toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(_enModif ? 'Modifier adhérent' : 'Nouvel adhérent'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Photo de profil ──
            Center(
              child: Column(children: [
                GestureDetector(
                  onTap: _choisirPhoto,
                  child: Stack(children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: AppTheme.orange.withOpacity(0.12),
                      backgroundImage: _photoBase64 != null
                          ? MemoryImage(base64Decode(_photoBase64!))
                          : null,
                      child: _photoBase64 == null
                          ? Text(initiales.isNotEmpty ? initiales : '?',
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold,
                                  color: AppTheme.orange))
                          : null,
                    ),
                    Positioned(bottom: 0, right: 0,
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: AppTheme.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.blanc, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 15, color: AppTheme.blanc),
                      )),
                  ]),
                ),
                const SizedBox(height: 8),
                Text(_photoBase64 != null ? 'Changer la photo' : 'Ajouter une photo',
                    style: const TextStyle(fontSize: 12, color: AppTheme.grisTexte)),
              ]),
            ),
            const SizedBox(height: 24),

            // Code accès si modification
            if (_enModif && _codeAcces != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.vpn_key, color: AppTheme.primary, size: 18),
                  const SizedBox(width: 8),
                  Text('Code d\'accès : $_codeAcces',
                      style: const TextStyle(fontFamily: 'monospace',
                          fontWeight: FontWeight.bold, color: AppTheme.primary)),
                ]),
              ),
              const SizedBox(height: 20),
            ],

            _label('Informations personnelles'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextFormField(
                controller: _prenomCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              )),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(
                controller: _nomCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              )),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone_outlined)),
            ),
            const SizedBox(height: 20),
            _label('Données physiques'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextFormField(
                controller: _poidsCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Poids (kg)',
                    prefixIcon: Icon(Icons.monitor_weight_outlined)),
              )),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(
                controller: _tailleCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Taille (cm)',
                    prefixIcon: Icon(Icons.height)),
              )),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              controller: _objectifCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Objectif',
                  hintText: 'Ex : Perte de poids, prise de masse...',
                  prefixIcon: Icon(Icons.flag_outlined)),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _sauvegarder,
              child: _loading
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(_enModif
                      ? 'Enregistrer les modifications'
                      : 'Créer l\'adhérent'),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary));
}
