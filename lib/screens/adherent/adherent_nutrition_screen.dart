import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class AdherentNutritionScreen extends StatefulWidget {
  final int programmeId;
  const AdherentNutritionScreen({super.key, required this.programmeId});
  @override
  State<AdherentNutritionScreen> createState() => _AdherentNutritionScreenState();
}

class _AdherentNutritionScreenState extends State<AdherentNutritionScreen> {
  Map<String, dynamic>? _programme;
  bool _loading = true;

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final prog = await DatabaseHelper.instance.getProgAlimentaireParId(widget.programmeId);
    setState(() { _programme = prog; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final prog = _programme;
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        backgroundColor: AppTheme.noir,
        foregroundColor: AppTheme.blanc,
        title: Text(prog?['titre'] ?? 'Mon programme nutrition'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.orange))
          : prog == null
              ? const Center(child: Text('Programme introuvable'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Macros
                    if (prog['calories'] != null || prog['proteines'] != null)
                      _MacrosCard(prog: prog),
                    const SizedBox(height: 16),
                    // Objectif
                    if (prog['objectif'] != null && prog['objectif'].toString().isNotEmpty) ...[
                      _Section(titre: '🎯 Objectif', contenu: prog['objectif']),
                      const SizedBox(height: 16),
                    ],
                    // Principes
                    if (prog['principes'] != null && prog['principes'].toString().isNotEmpty) ...[
                      _Section(titre: '📋 Principes', contenu: prog['principes']),
                      const SizedBox(height: 16),
                    ],
                    // Planning 7 jours
                    if (prog['planning'] != null) ...[
                      _PlanningCard(planning: prog['planning']),
                      const SizedBox(height: 16),
                    ],
                    // Aliments à privilégier
                    if (prog['aliments_privilegier'] != null && prog['aliments_privilegier'].toString().isNotEmpty) ...[
                      _Section(titre: '✅ Aliments à privilégier', contenu: prog['aliments_privilegier'], couleur: Colors.green),
                      const SizedBox(height: 16),
                    ],
                    // Aliments à éviter
                    if (prog['aliments_eviter'] != null && prog['aliments_eviter'].toString().isNotEmpty) ...[
                      _Section(titre: '❌ Aliments à éviter', contenu: prog['aliments_eviter'], couleur: Colors.red),
                      const SizedBox(height: 16),
                    ],
                    // Conseils
                    if (prog['conseils'] != null && prog['conseils'].toString().isNotEmpty) ...[
                      _Section(titre: '💡 Conseils', contenu: prog['conseils']),
                      const SizedBox(height: 16),
                    ],
                  ]),
                ),
    );
  }
}

class _MacrosCard extends StatelessWidget {
  final Map<String, dynamic> prog;
  const _MacrosCard({required this.prog});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.orange,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        if (prog['calories'] != null)
          Text('${prog['calories']} kcal/jour',
              style: const TextStyle(color: AppTheme.blanc, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          if (prog['proteines'] != null)
            _MacroItem(label: 'Protéines', value: '${prog['proteines']}g'),
          if (prog['glucides'] != null)
            _MacroItem(label: 'Glucides', value: '${prog['glucides']}g'),
          if (prog['lipides'] != null)
            _MacroItem(label: 'Lipides', value: '${prog['lipides']}g'),
        ]),
      ]),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label, value;
  const _MacroItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(color: AppTheme.blanc, fontSize: 18, fontWeight: FontWeight.bold)),
    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
  ]);
}

class _Section extends StatelessWidget {
  final String titre, contenu;
  final Color? couleur;
  const _Section({required this.titre, required this.contenu, this.couleur});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.blanc,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titre, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
          color: couleur ?? AppTheme.noir)),
      const SizedBox(height: 8),
      Text(contenu, style: const TextStyle(fontSize: 14, height: 1.6, color: AppTheme.noir)),
    ]),
  );
}

class _PlanningCard extends StatelessWidget {
  final dynamic planning;
  const _PlanningCard({required this.planning});

  static const _jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> map = {};
    if (planning is Map) map = Map<String, dynamic>.from(planning);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.blanc,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('📅 Planning semaine',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.noir)),
        const SizedBox(height: 12),
        ..._jours.map((jour) {
          final contenu = map[jour]?.toString() ?? '';
          if (contenu.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(jour, style: const TextStyle(fontWeight: FontWeight.w600,
                  color: AppTheme.orange, fontSize: 13)),
              const SizedBox(height: 4),
              Text(contenu, style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.noir)),
              const Divider(),
            ]),
          );
        }),
      ]),
    );
  }
}
