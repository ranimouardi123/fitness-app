import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class FormRepasScreen extends StatefulWidget {
  final int programmeId;
  final int? repasId;
  const FormRepasScreen({super.key, required this.programmeId, this.repasId});
  @override
  State<FormRepasScreen> createState() => _FormRepasScreenState();
}

class _FormRepasScreenState extends State<FormRepasScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nomCtrl      = TextEditingController();
  final _heureCtrl    = TextEditingController();
  final _calCtrl      = TextEditingController();
  final _protCtrl     = TextEditingController();
  final _glucCtrl     = TextEditingController();
  final _lipCtrl      = TextEditingController();
  final _alimentsCtrl = TextEditingController();
  final _notesCtrl    = TextEditingController();
  String _typeRepas   = 'Petit-déjeuner';
  bool _loading       = false;
  bool get _enModif   => widget.repasId != null;

  static const _types = ['Petit-déjeuner','Collation matin','Déjeuner','Collation après-midi','Dîner','Collation soir'];

  @override
  void initState() { super.initState(); if (_enModif) _charger(); }

  Future<void> _charger() async {
    final r = await DatabaseHelper.instance.getRepasParId(widget.repasId!);
    if (r == null) return;
    setState(() {
      _nomCtrl.text      = r['nom'] as String? ?? '';
      _typeRepas         = r['type_repas'] as String? ?? _types[0];
      _heureCtrl.text    = r['heure'] as String? ?? '';
      _calCtrl.text      = r['calories'] != null ? '${r['calories']}' : '';
      _protCtrl.text     = r['proteines'] != null ? '${r['proteines']}' : '';
      _glucCtrl.text     = r['glucides'] != null ? '${r['glucides']}' : '';
      _lipCtrl.text      = r['lipides'] != null ? '${r['lipides']}' : '';
      _alimentsCtrl.text = r['aliments'] as String? ?? '';
      _notesCtrl.text    = r['notes'] as String? ?? '';
    });
  }

  @override
  void dispose() {
    _nomCtrl.dispose(); _heureCtrl.dispose(); _calCtrl.dispose();
    _protCtrl.dispose(); _glucCtrl.dispose(); _lipCtrl.dispose();
    _alimentsCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'programme_nutrition_id': widget.programmeId,
      'nom': _nomCtrl.text.trim(), 'type_repas': _typeRepas,
      'heure': _heureCtrl.text.trim(), 'aliments': _alimentsCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
      if (_calCtrl.text.isNotEmpty)  'calories':  int.tryParse(_calCtrl.text),
      if (_protCtrl.text.isNotEmpty) 'proteines': double.tryParse(_protCtrl.text),
      if (_glucCtrl.text.isNotEmpty) 'glucides':  double.tryParse(_glucCtrl.text),
      if (_lipCtrl.text.isNotEmpty)  'lipides':   double.tryParse(_lipCtrl.text),
    };
    if (_enModif) {
      await DatabaseHelper.instance.modifierRepas(widget.repasId!, data);
    } else {
      await DatabaseHelper.instance.ajouterRepas(data);
    }
    setState(() => _loading = false);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_enModif ? 'Modifier repas' : 'Nouveau repas')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(controller: _nomCtrl,
                  decoration: const InputDecoration(labelText: 'Nom du repas *'),
                  validator: (v) => v == null || v.isEmpty ? 'Requis' : null),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _typeRepas,
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _typeRepas = v!),
                decoration: const InputDecoration(labelText: 'Type de repas'),
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _heureCtrl,
                  decoration: const InputDecoration(labelText: 'Heure', hintText: '08:00')),
              const SizedBox(height: 16),
              const Text('Valeurs nutritionnelles',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextFormField(controller: _calCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Calories'))),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: _protCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Protéines (g)'))),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextFormField(controller: _glucCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Glucides (g)'))),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: _lipCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Lipides (g)'))),
              ]),
              const SizedBox(height: 12),
              TextFormField(controller: _alimentsCtrl, maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Aliments / Composition',
                      hintText: '- 150g poulet grillé\n- 100g riz complet')),
              const SizedBox(height: 12),
              TextFormField(controller: _notesCtrl, maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Notes')),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _sauvegarder,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary),
                child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_enModif ? 'Enregistrer' : 'Ajouter le repas'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
