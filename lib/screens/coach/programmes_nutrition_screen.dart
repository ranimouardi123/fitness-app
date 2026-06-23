import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class ProgrammesNutritionScreen extends StatefulWidget {
  final int adherentId;
  const ProgrammesNutritionScreen({super.key, required this.adherentId});
  @override
  State<ProgrammesNutritionScreen> createState() =>
      _ProgrammesNutritionScreenState();
}

class _ProgrammesNutritionScreenState
    extends State<ProgrammesNutritionScreen> {
  List<Map<String, dynamic>> _programmes = [];
  Map<String, dynamic>? _adherent;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final a = await DatabaseHelper.instance.getAdherentParId(widget.adherentId);
    final p = await DatabaseHelper.instance
        .getProgrammesNutritionAdherent(widget.adherentId);
    setState(() {
      _adherent  = a;
      _programmes = p;
    });
  }

  Future<void> _supprimer(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le programme'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseHelper.instance.supprimerProgrammeNutrition(id);
      _charger();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nomAdherent = _adherent != null
        ? '${_adherent!['prenom']} ${_adherent!['nom']}'
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrition — $nomAdherent'),
      ),
      body: RefreshIndicator(
        onRefresh: _charger,
        child: _programmes.isEmpty
            ? const Center(
                child: Text('Aucun programme nutrition.\nAjoutez-en un !',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _programmes.length,
                itemBuilder: (ctx, i) {
                  final p = _programmes[i];
                  final actif = p['actif'] == 1;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(p['titre'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ),
                              if (actif)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Actif',
                                      style: TextStyle(
                                          color: AppTheme.secondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ),
                            ],
                          ),
                          if (p['description'] != null && p['description'].isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(p['description'],
                                style: const TextStyle(
                                    color: AppTheme.textSecondary, fontSize: 14)),
                          ],
                          if (p['calories_jour'] != null) ...[
                            const SizedBox(height: 6),
                            Text('${p['calories_jour']} kcal/jour',
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w500)),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.push(
                                      '/coach/nutrition/${widget.adherentId}/${p['id']}/modifier'),
                                  icon: const Icon(Icons.edit_outlined, size: 16),
                                  label: const Text('Modifier'),
                                  style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(0, 36)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _supprimer(p['id']),
                                  icon: const Icon(Icons.delete_outline, size: 16),
                                  label: const Text('Supprimer'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 36),
                                    foregroundColor: AppTheme.danger,
                                    side: BorderSide(
                                        color: AppTheme.danger.withOpacity(0.4)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(
              '/coach/nutrition/${widget.adherentId}/ajouter');
          _charger();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau programme'),
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
