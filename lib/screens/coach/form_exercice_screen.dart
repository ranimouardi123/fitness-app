import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class FormExerciceScreen extends StatefulWidget {
  final int seanceId;
  final int? exerciceId;
  const FormExerciceScreen({super.key, required this.seanceId, this.exerciceId});
  @override
  State<FormExerciceScreen> createState() => _FormExerciceScreenState();
}

class _FormExerciceScreenState extends State<FormExerciceScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nomCtrl    = TextEditingController();
  final _seriesCtrl = TextEditingController();
  final _repsCtrl   = TextEditingController();
  final _poidsCtrl  = TextEditingController();
  final _reposCtrl  = TextEditingController();
  final _notesCtrl  = TextEditingController();
  bool _loading     = false;
  bool get _enModif => widget.exerciceId != null;

  @override
  void initState() {
    super.initState();
    if (_enModif) _charger();
  }

  Future<void> _charger() async {
    final ex = await DatabaseHelper.instance.getAdherentParId(widget.exerciceId!);
    if (ex == null) return;
    setState(() {
      _nomCtrl.text    = ex['nom'] as String? ?? '';
      _seriesCtrl.text = ex['series'] != null ? '${ex['series']}' : '';
      _repsCtrl.text   = ex['repetitions'] as String? ?? '';
      _poidsCtrl.text  = ex['poids'] as String? ?? '';
      _reposCtrl.text  = ex['repos_sec'] != null ? '${ex['repos_sec']}' : '';
      _notesCtrl.text  = ex['notes'] as String? ?? '';
    });
  }

  @override
  void dispose() {
    _nomCtrl.dispose(); _seriesCtrl.dispose(); _repsCtrl.dispose();
    _poidsCtrl.dispose(); _reposCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _sauvegarder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final data = {
      'seance_id':   widget.seanceId,
      'nom':         _nomCtrl.text.trim(),
      'repetitions': _repsCtrl.text.trim(),
      'poids':       _poidsCtrl.text.trim(),
      'notes':       _notesCtrl.text.trim(),
      if (_seriesCtrl.text.isNotEmpty)
        'series':   int.tryParse(_seriesCtrl.text),
      if (_reposCtrl.text.isNotEmpty)
        'repos_sec': int.tryParse(_reposCtrl.text),
    };

    if (_enModif) {
      await DatabaseHelper.instance.modifierExercice(widget.exerciceId!, data);
    } else {
      final count = await DatabaseHelper.instance.countExercicesParSeance(widget.seanceId);
      data['ordre'] = count + 1;
      await DatabaseHelper.instance.ajouterExercice(data);
    }

    setState(() => _loading = false);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_enModif ? 'Modifier exercice' : 'Nouvel exercice')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextFormField(
                controller: _nomCtrl,
                decoration: const InputDecoration(
                  labelText: "Nom de l'exercice *",
                  hintText: 'Ex : Développé couché, Squat...',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _seriesCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Séries'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _repsCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Répétitions', hintText: '10 ou 8-12'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _poidsCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Charge / Poids',
                          hintText: '20kg ou Poids du corps'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _reposCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Repos (sec)', hintText: '60'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes / Instructions',
                  hintText: "Technique, points d'attention...",
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _sauvegarder,
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(_enModif ? 'Enregistrer' : "Ajouter l'exercice"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
