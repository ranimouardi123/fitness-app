// Programme générique réutilisable pour: alimentaire, musculation, cardio
import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

enum TypeProg { alimentaire, musculation, cardio }

class ProgSimpleScreen extends StatefulWidget {
  final int adherentId;
  final TypeProg type;
  const ProgSimpleScreen({super.key, required this.adherentId, required this.type});
  @override
  State<ProgSimpleScreen> createState() => _ProgSimpleScreenState();
}

class _ProgSimpleScreenState extends State<ProgSimpleScreen> {
  List<Map<String, dynamic>> _progs = [];
  Map<String, dynamic>? _adherent;

  String get _titre => switch (widget.type) {
    TypeProg.alimentaire  => 'Programme alimentaire',
    TypeProg.musculation  => 'Programme musculation',
    TypeProg.cardio       => 'Programme cardio',
  };

  Color get _couleur => switch (widget.type) {
    TypeProg.alimentaire  => AppTheme.secondary,
    TypeProg.musculation  => AppTheme.primary,
    TypeProg.cardio       => const Color(0xFFF59E0B),
  };

  IconData get _icon => switch (widget.type) {
    TypeProg.alimentaire  => Icons.restaurant_outlined,
    TypeProg.musculation  => Icons.fitness_center,
    TypeProg.cardio       => Icons.directions_run,
  };

  Future<List<Map<String, dynamic>>> _getProgs() => switch (widget.type) {
    TypeProg.alimentaire  => DatabaseHelper.instance.getProgsAlimentaires(widget.adherentId),
    TypeProg.musculation  => DatabaseHelper.instance.getProgsMusculation(widget.adherentId),
    TypeProg.cardio       => DatabaseHelper.instance.getProgsCardio(widget.adherentId),
  };

  Future<int> _ajouter(Map<String, dynamic> data) => switch (widget.type) {
    TypeProg.alimentaire  => DatabaseHelper.instance.ajouterProgAlimentaire(data),
    TypeProg.musculation  => DatabaseHelper.instance.ajouterProgMusculation(data),
    TypeProg.cardio       => DatabaseHelper.instance.ajouterProgCardio(data),
  };

  Future<void> _modifier(int id, Map<String, dynamic> data) => switch (widget.type) {
    TypeProg.alimentaire  => DatabaseHelper.instance.modifierProgAlimentaire(id, data),
    TypeProg.musculation  => DatabaseHelper.instance.modifierProgMusculation(id, data),
    TypeProg.cardio       => DatabaseHelper.instance.modifierProgCardio(id, data),
  };

  Future<void> _supprimer(int id) => switch (widget.type) {
    TypeProg.alimentaire  => DatabaseHelper.instance.supprimerProgAlimentaire(id),
    TypeProg.musculation  => DatabaseHelper.instance.supprimerProgMusculation(id),
    TypeProg.cardio       => DatabaseHelper.instance.supprimerProgCardio(id),
  };

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final a = await DatabaseHelper.instance.getAdherentParId(widget.adherentId);
    final p = await _getProgs();
    setState(() { _adherent = a; _progs = p; });
  }

  Future<void> _afficherFormulaire({Map<String, dynamic>? prog}) async {
    final result = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _FormProg(
        type: widget.type, adherentId: widget.adherentId,
        couleur: _couleur, prog: prog,
        onSave: (data) async {
          if (prog != null) { await _modifier(prog['id'], data); }
          else { await _ajouter(data); }
        },
      ),
    );
    if (result == true) _charger();
  }

  @override
  Widget build(BuildContext context) {
    final nom = _adherent != null ? '${_adherent!['prenom']} ${_adherent!['nom']}' : '';
    return Scaffold(
      appBar: AppBar(title: Text('$_titre — $nom')),
      body: _progs.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(_icon, size: 56, color: AppTheme.textSecondary.withOpacity(0.4)),
              const SizedBox(height: 12),
              Text('Aucun $_titre', style: const TextStyle(color: AppTheme.textSecondary)),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _progs.length,
              itemBuilder: (ctx, i) {
                final p = _progs[i];
                final actif = p['actif'] as bool? ?? false;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(p['titre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        if (actif) Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: _couleur.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                          child: Text('Actif', style: TextStyle(color: _couleur, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
                            onPressed: () => _afficherFormulaire(prog: p)),
                        IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                            onPressed: () async { await _supprimer(p['id']); _charger(); }),
                      ]),
                      if (p['description'] != null && (p['description'] as String).isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(p['description'], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                      ],
                      if (p['contenu'] != null && (p['contenu'] as String).isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: _couleur.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                          child: Text(p['contenu'], style: const TextStyle(fontSize: 14, height: 1.6)),
                        ),
                      ],
                    ]),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _afficherFormulaire(),
        icon: const Icon(Icons.add), label: const Text('Nouveau programme'),
        backgroundColor: _couleur, foregroundColor: Colors.white,
      ),
    );
  }
}

class _FormProg extends StatefulWidget {
  final TypeProg type;
  final int adherentId;
  final Color couleur;
  final Map<String, dynamic>? prog;
  final Future<void> Function(Map<String, dynamic>) onSave;
  const _FormProg({required this.type, required this.adherentId, required this.couleur, required this.onSave, this.prog});
  @override State<_FormProg> createState() => _FormProgState();
}
class _FormProgState extends State<_FormProg> {
  final _titreCtrl   = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _contenuCtrl = TextEditingController();
  bool _actif  = true;
  bool _loading = false;

  String get _hintContenu => switch (widget.type) {
    TypeProg.alimentaire  => 'Ex:\nPetit-déj: 3 œufs, avocat\nDéjeuner: 150g poulet, riz...',
    TypeProg.musculation  => 'Ex:\nLundi - Pectoraux:\n- Développé couché 4x10\n- Écarté 3x12...',
    TypeProg.cardio       => 'Ex:\nLundi: 30 min vélo intensité modérée\nMercredi: HIIT 20 min...',
  };

  @override
  void initState() {
    super.initState();
    final p = widget.prog;
    if (p != null) {
      _titreCtrl.text   = p['titre'] ?? '';
      _descCtrl.text    = p['description'] ?? '';
      _contenuCtrl.text = p['contenu'] ?? '';
      _actif            = p['actif'] as bool? ?? true;
    }
  }

  Future<void> _sauvegarder() async {
    if (_titreCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await widget.onSave({
      'adherent_id': widget.adherentId,
      'titre':       _titreCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'contenu':     _contenuCtrl.text.trim(),
      'actif':       _actif,
      if (widget.prog == null) 'date_creation': DateTime.now().toIso8601String(),
    });
    setState(() => _loading = false);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(widget.prog != null ? 'Modifier programme' : 'Nouveau programme',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(controller: _titreCtrl, decoration: const InputDecoration(labelText: 'Titre *')),
        const SizedBox(height: 10),
        TextFormField(controller: _descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description / Objectif')),
        const SizedBox(height: 10),
        TextFormField(controller: _contenuCtrl, maxLines: 8,
            decoration: InputDecoration(labelText: 'Contenu du programme', hintText: _hintContenu,
                alignLabelWithHint: true)),
        const SizedBox(height: 8),
        SwitchListTile(value: _actif, onChanged: (v) => setState(() => _actif = v),
            title: const Text('Programme actif'), contentPadding: EdgeInsets.zero,
            activeColor: widget.couleur),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loading ? null : _sauvegarder,
          style: ElevatedButton.styleFrom(backgroundColor: widget.couleur),
          child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : Text(widget.prog != null ? 'Enregistrer' : 'Créer le programme'),
        ),
        const SizedBox(height: 16),
      ])),
    );
  }
}
