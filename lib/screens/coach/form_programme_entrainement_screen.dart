import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class FormProgrammeEntrainementScreen extends StatefulWidget {
  final int adherentId;
  final int? programmeId;
  const FormProgrammeEntrainementScreen({super.key, required this.adherentId, this.programmeId});
  @override
  State<FormProgrammeEntrainementScreen> createState() => _FormProgrammeEntrainementScreenState();
}

class _FormProgrammeEntrainementScreenState extends State<FormProgrammeEntrainementScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _titreCtrl    = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _dureeCtrl    = TextEditingController();
  final _objectifCtrl = TextEditingController();
  String _niveau      = 'Débutant';
  bool _actif         = true;
  bool _loading       = false;
  bool get _enModif   => widget.programmeId != null;
  List<Map<String, dynamic>> _seances = [];

  static const _niveaux = ['Débutant', 'Intermédiaire', 'Avancé'];

  @override
  void initState() { super.initState(); if (_enModif) _charger(); }

  Future<void> _charger() async {
    final db   = DatabaseHelper.instance;
    final prog = await db.getProgrammeEntrainementParId(widget.programmeId!);
    if (prog == null) return;
    final seances = await db.getSeancesParProgramme(widget.programmeId!);
    setState(() {
      _titreCtrl.text    = prog['titre'] as String? ?? '';
      _descCtrl.text     = prog['description'] as String? ?? '';
      _dureeCtrl.text    = prog['duree_semaines'] != null ? '${prog['duree_semaines']}' : '';
      _objectifCtrl.text = prog['objectif'] as String? ?? '';
      _niveau            = prog['niveau'] as String? ?? _niveaux[0];
      _actif             = prog['actif'] as bool? ?? true;
      _seances           = seances;
    });
  }

  @override
  void dispose() {
    _titreCtrl.dispose(); _descCtrl.dispose();
    _dureeCtrl.dispose(); _objectifCtrl.dispose();
    super.dispose();
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'adherent_id': widget.adherentId,
      'titre': _titreCtrl.text.trim(), 'description': _descCtrl.text.trim(),
      'objectif': _objectifCtrl.text.trim(), 'niveau': _niveau, 'actif': _actif,
      if (_dureeCtrl.text.isNotEmpty) 'duree_semaines': int.tryParse(_dureeCtrl.text),
      if (!_enModif) 'date_creation': DateTime.now().toIso8601String(),
    };
    if (_enModif) {
      await DatabaseHelper.instance.modifierProgrammeEntrainement(widget.programmeId!, data);
    } else {
      await DatabaseHelper.instance.ajouterProgrammeEntrainement(data);
    }
    setState(() => _loading = false);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_enModif ? 'Modifier programme' : 'Nouveau programme entraînement')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(controller: _titreCtrl,
                  decoration: const InputDecoration(labelText: 'Titre du programme *'),
                  validator: (v) => v == null || v.isEmpty ? 'Requis' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _descCtrl, maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: DropdownButtonFormField<String>(
                  value: _niveau,
                  items: _niveaux.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                  onChanged: (v) => setState(() => _niveau = v!),
                  decoration: const InputDecoration(labelText: 'Niveau'),
                )),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: _dureeCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Durée (semaines)'))),
              ]),
              const SizedBox(height: 12),
              TextFormField(controller: _objectifCtrl,
                  decoration: const InputDecoration(labelText: 'Objectif', hintText: 'Ex : Prise de masse')),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _actif, onChanged: (v) => setState(() => _actif = v),
                title: const Text('Programme actif'), contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primary,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _sauvegarder,
                child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_enModif ? 'Enregistrer' : 'Créer le programme'),
              ),
              if (_enModif) ...[
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Séances', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    TextButton.icon(
                      onPressed: () async {
                        await context.push('/coach/entrainement/${widget.adherentId}/${widget.programmeId}/seances/ajouter');
                        _charger();
                      },
                      icon: const Icon(Icons.add, size: 18), label: const Text('Ajouter'),
                    ),
                  ],
                ),
                if (_seances.isEmpty)
                  const Text('Aucune séance.', style: TextStyle(color: AppTheme.textSecondary))
                else
                  ..._seances.map((s) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.fitness_center, color: AppTheme.primary),
                      title: Text(s['titre'], style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('${s['jour_semaine'] ?? ''}${s['duree_minutes'] != null ? ' • ${s['duree_minutes']} min' : ''}',
                          style: const TextStyle(fontSize: 12)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
                          onPressed: () async {
                            await context.push('/coach/entrainement/${widget.adherentId}/${widget.programmeId}/seances/${s['id']}/modifier');
                            _charger();
                          }),
                        IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                          onPressed: () async { await DatabaseHelper.instance.supprimerSeance(s['id']); _charger(); }),
                      ]),
                    ),
                  )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
