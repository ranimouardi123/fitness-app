import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class FormProgrammeNutritionScreen extends StatefulWidget {
  final int adherentId;
  final int? programmeId;
  const FormProgrammeNutritionScreen({super.key, required this.adherentId, this.programmeId});
  @override
  State<FormProgrammeNutritionScreen> createState() => _FormProgrammeNutritionScreenState();
}

class _FormProgrammeNutritionScreenState extends State<FormProgrammeNutritionScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _titreCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _calCtrl   = TextEditingController();
  bool _actif      = true;
  bool _loading    = false;
  bool get _enModif => widget.programmeId != null;
  List<Map<String, dynamic>> _repas = [];

  @override
  void initState() { super.initState(); if (_enModif) _charger(); }

  Future<void> _charger() async {
    final db   = DatabaseHelper.instance;
    final prog = await db.getProgrammeNutritionParId(widget.programmeId!);
    if (prog == null) return;
    final repas = await db.getRepasParProgramme(widget.programmeId!);
    setState(() {
      _titreCtrl.text = prog['titre'] as String? ?? '';
      _descCtrl.text  = prog['description'] as String? ?? '';
      _calCtrl.text   = prog['calories_jour'] != null ? '${prog['calories_jour']}' : '';
      _actif          = prog['actif'] as bool? ?? true;
      _repas          = repas;
    });
  }

  @override
  void dispose() { _titreCtrl.dispose(); _descCtrl.dispose(); _calCtrl.dispose(); super.dispose(); }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'adherent_id': widget.adherentId,
      'titre':       _titreCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'actif':       _actif,
      if (_calCtrl.text.isNotEmpty) 'calories_jour': int.tryParse(_calCtrl.text),
      if (!_enModif) 'date_creation': DateTime.now().toIso8601String(),
    };
    if (_enModif) {
      await DatabaseHelper.instance.modifierProgrammeNutrition(widget.programmeId!, data);
    } else {
      await DatabaseHelper.instance.ajouterProgrammeNutrition(data);
    }
    setState(() => _loading = false);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_enModif ? 'Modifier programme' : 'Nouveau programme nutrition')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titreCtrl,
                decoration: const InputDecoration(labelText: 'Titre du programme *'),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _descCtrl, maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              TextFormField(controller: _calCtrl, keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Calories journalières (kcal)',
                      prefixIcon: Icon(Icons.local_fire_department_outlined))),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _actif, onChanged: (v) => setState(() => _actif = v),
                title: const Text('Programme actif'), contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.secondary,
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
                    const Text('Repas du programme',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    TextButton.icon(
                      onPressed: () async {
                        await context.push('/coach/nutrition/${widget.adherentId}/${widget.programmeId}/repas/ajouter');
                        _charger();
                      },
                      icon: const Icon(Icons.add, size: 18), label: const Text('Ajouter'),
                    ),
                  ],
                ),
                if (_repas.isEmpty)
                  const Text('Aucun repas ajouté.', style: TextStyle(color: AppTheme.textSecondary))
                else
                  ..._repas.map((r) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.restaurant_menu, color: AppTheme.secondary),
                      title: Text(r['nom'], style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('${r['type_repas']}${r['calories'] != null ? ' • ${r['calories']} kcal' : ''}',
                          style: const TextStyle(fontSize: 12)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
                          onPressed: () async {
                            await context.push('/coach/nutrition/${widget.adherentId}/${widget.programmeId}/repas/${r['id']}/modifier');
                            _charger();
                          }),
                        IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                          onPressed: () async { await DatabaseHelper.instance.supprimerRepas(r['id']); _charger(); }),
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
