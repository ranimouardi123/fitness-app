import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class FormSeanceScreen extends StatefulWidget {
  final int programmeId;
  final int? seanceId;
  const FormSeanceScreen({super.key, required this.programmeId, this.seanceId});
  @override
  State<FormSeanceScreen> createState() => _FormSeanceScreenState();
}

class _FormSeanceScreenState extends State<FormSeanceScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _titreCtrl = TextEditingController();
  final _dureeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _jourSemaine;
  String _typeSeance = 'Musculation';
  bool _loading      = false;
  bool get _enModif  => widget.seanceId != null;
  List<Map<String, dynamic>> _exercices = [];

  static const _jours = ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'];
  static const _types = ['Musculation','Cardio','HIIT','Stretching','Yoga','Mixte'];

  @override
  void initState() { super.initState(); if (_enModif) _charger(); }

  Future<void> _charger() async {
    final db  = DatabaseHelper.instance;
    final s   = await db.getSeanceParId(widget.seanceId!);
    if (s == null) return;
    final exercices = await db.getExercicesParSeance(widget.seanceId!);
    setState(() {
      _titreCtrl.text = s['titre'] as String? ?? '';
      _jourSemaine    = s['jour_semaine'] as String?;
      _dureeCtrl.text = s['duree_minutes'] != null ? '${s['duree_minutes']}' : '';
      _typeSeance     = s['type_seance'] as String? ?? _types[0];
      _notesCtrl.text = s['notes'] as String? ?? '';
      _exercices      = exercices;
    });
  }

  @override
  void dispose() { _titreCtrl.dispose(); _dureeCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'programme_entrainement_id': widget.programmeId,
      'titre': _titreCtrl.text.trim(), 'jour_semaine': _jourSemaine,
      'type_seance': _typeSeance, 'notes': _notesCtrl.text.trim(),
      if (_dureeCtrl.text.isNotEmpty) 'duree_minutes': int.tryParse(_dureeCtrl.text),
    };
    if (_enModif) {
      await DatabaseHelper.instance.modifierSeance(widget.seanceId!, data);
    } else {
      await DatabaseHelper.instance.ajouterSeance(data);
    }
    setState(() => _loading = false);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final uri      = GoRouterState.of(context).uri.toString();
    final parts    = uri.split('/');
    final adherentId = parts.length > 3 ? parts[3] : '0';
    final progId   = widget.programmeId;

    return Scaffold(
      appBar: AppBar(title: Text(_enModif ? 'Modifier séance' : 'Nouvelle séance')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(controller: _titreCtrl,
                  decoration: const InputDecoration(labelText: 'Titre de la séance *'),
                  validator: (v) => v == null || v.isEmpty ? 'Requis' : null),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: DropdownButtonFormField<String>(
                  value: _jourSemaine, hint: const Text('Jour'),
                  items: _jours.map((j) => DropdownMenuItem(value: j, child: Text(j))).toList(),
                  onChanged: (v) => setState(() => _jourSemaine = v),
                  decoration: const InputDecoration(labelText: 'Jour'),
                )),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: _dureeCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Durée (min)'))),
              ]),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _typeSeance,
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _typeSeance = v!),
                decoration: const InputDecoration(labelText: 'Type de séance'),
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _notesCtrl, maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Notes')),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _sauvegarder,
                child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_enModif ? 'Enregistrer' : 'Créer la séance'),
              ),
              if (_enModif) ...[
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Exercices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    TextButton.icon(
                      onPressed: () async {
                        await context.push('/coach/entrainement/$adherentId/$progId/seances/${widget.seanceId}/exercices/ajouter');
                        _charger();
                      },
                      icon: const Icon(Icons.add, size: 18), label: const Text('Ajouter'),
                    ),
                  ],
                ),
                if (_exercices.isEmpty)
                  const Text('Aucun exercice.', style: TextStyle(color: AppTheme.textSecondary))
                else
                  ..._exercices.asMap().entries.map((e) {
                    final idx = e.key + 1;
                    final ex  = e.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                          child: Text('$idx', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(ex['nom'], style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          '${ex['series'] ?? '-'} séries × ${ex['repetitions'] ?? '-'}${ex['poids'] != null ? ' • ${ex['poids']}' : ''}',
                          style: const TextStyle(fontSize: 12)),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
                            onPressed: () async {
                              await context.push('/coach/entrainement/$adherentId/$progId/seances/${widget.seanceId}/exercices/${ex['id']}/modifier');
                              _charger();
                            }),
                          IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                            onPressed: () async { await DatabaseHelper.instance.supprimerExercice(ex['id']); _charger(); }),
                        ]),
                      ),
                    );
                  }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
