import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class AdherentEntrainementScreen extends StatefulWidget {
  final int programmeId;
  const AdherentEntrainementScreen({super.key, required this.programmeId});
  @override
  State<AdherentEntrainementScreen> createState() => _AdherentEntrainementScreenState();
}

class _AdherentEntrainementScreenState extends State<AdherentEntrainementScreen> {
  Map<String, dynamic>? _programme;
  List<Map<String, dynamic>> _seances = [];
  final Map<int, List<Map<String, dynamic>>> _exercices = {};
  final Set<int> _seancesOuvertes = {};

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final db      = DatabaseHelper.instance;
    final prog    = await db.getProgrammeEntrainementParId(widget.programmeId);
    final seances = await db.getSeancesParProgramme(widget.programmeId);
    final Map<int, List<Map<String, dynamic>>> exMap = {};
    for (final s in seances) {
      exMap[s['id']] = await db.getExercicesParSeance(s['id']);
    }
    setState(() { _programme = prog; _seances = seances; _exercices.addAll(exMap); });
  }

  @override
  Widget build(BuildContext context) {
    final prog = _programme;
    return Scaffold(
      appBar: AppBar(title: Text(prog?['titre'] ?? 'Mon programme entraînement')),
      body: prog == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    if (prog['niveau'] != null) _Badge(label: prog['niveau'], couleur: AppTheme.primary),
                    if (prog['duree_semaines'] != null) ...[
                      const SizedBox(width: 8),
                      _Badge(label: '${prog['duree_semaines']} semaines', couleur: AppTheme.accent),
                    ],
                  ]),
                  if (prog['objectif'] != null && (prog['objectif'] as String).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Objectif : ${prog['objectif']}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  ],
                  const SizedBox(height: 24),
                  Text('${_seances.length} séance${_seances.length > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  if (_seances.isEmpty)
                    const Text('Aucune séance définie.', style: TextStyle(color: AppTheme.textSecondary))
                  else
                    ..._seances.map((s) => _SeanceCard(
                      seance: s, exercices: _exercices[s['id']] ?? [],
                      ouverte: _seancesOuvertes.contains(s['id']),
                      onToggle: () => setState(() {
                        if (_seancesOuvertes.contains(s['id'])) _seancesOuvertes.remove(s['id']);
                        else _seancesOuvertes.add(s['id']);
                      }),
                    )),
                ],
              ),
            ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label; final Color couleur;
  const _Badge({required this.label, required this.couleur});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(color: couleur.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(color: couleur, fontSize: 13, fontWeight: FontWeight.w600)),
  );
}

class _SeanceCard extends StatelessWidget {
  final Map<String, dynamic> seance;
  final List<Map<String, dynamic>> exercices;
  final bool ouverte;
  final VoidCallback onToggle;
  const _SeanceCard({required this.seance, required this.exercices, required this.ouverte, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(children: [
        InkWell(
          onTap: onToggle,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(width: 44, height: 44,
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.fitness_center, color: AppTheme.primary, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(seance['titre'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Text([
                  if (seance['jour_semaine'] != null) seance['jour_semaine'],
                  if (seance['duree_minutes'] != null) '${seance['duree_minutes']} min',
                  if (seance['type_seance'] != null) seance['type_seance'],
                ].join(' • '), style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ])),
              Text('${exercices.length} ex.', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(width: 8),
              Icon(ouverte ? Icons.expand_less : Icons.expand_more, color: AppTheme.textSecondary),
            ]),
          ),
        ),
        if (ouverte) ...[
          const Divider(height: 1),
          if (seance['notes'] != null && (seance['notes'] as String).isNotEmpty)
            Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(seance['notes'], style: const TextStyle(color: AppTheme.textSecondary, fontStyle: FontStyle.italic, fontSize: 13))),
          if (exercices.isEmpty)
            const Padding(padding: EdgeInsets.all(16),
              child: Text('Aucun exercice.', style: TextStyle(color: AppTheme.textSecondary)))
          else
            ...exercices.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(radius: 12, backgroundColor: AppTheme.primary.withOpacity(0.12),
                  child: Text('${e.key + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.value['nom'], style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text([
                    if (e.value['series'] != null) '${e.value['series']} séries',
                    if (e.value['repetitions'] != null) '× ${e.value['repetitions']}',
                    if (e.value['poids'] != null) e.value['poids'],
                    if (e.value['repos_sec'] != null) 'Repos ${e.value['repos_sec']}s',
                  ].join('  '), style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  if (e.value['notes'] != null && (e.value['notes'] as String).isNotEmpty)
                    Text(e.value['notes'], style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontStyle: FontStyle.italic)),
                ])),
              ]),
            )),
          const SizedBox(height: 8),
        ],
      ]),
    );
  }
}
