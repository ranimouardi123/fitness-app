import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class ProgrammesEntrainementScreen extends StatefulWidget {
  final int adherentId;
  const ProgrammesEntrainementScreen({super.key, required this.adherentId});
  @override
  State<ProgrammesEntrainementScreen> createState() =>
      _ProgrammesEntrainementScreenState();
}

class _ProgrammesEntrainementScreenState
    extends State<ProgrammesEntrainementScreen> {
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
        .getProgrammesEntrainementAdherent(widget.adherentId);
    setState(() {
      _adherent   = a;
      _programmes = p;
    });
  }

  Future<void> _supprimer(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le programme'),
        content: const Text('Toutes les séances et exercices seront supprimés.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseHelper.instance.supprimerProgrammeEntrainement(id);
      _charger();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nom = _adherent != null
        ? '${_adherent!['prenom']} ${_adherent!['nom']}'
        : '';
    return Scaffold(
      appBar: AppBar(title: Text('Entraînement — $nom')),
      body: RefreshIndicator(
        onRefresh: _charger,
        child: _programmes.isEmpty
            ? const Center(
                child: Text('Aucun programme entraînement.',
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
                                    color: AppTheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Actif',
                                      style: TextStyle(
                                          color: AppTheme.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ),
                            ],
                          ),
                          if (p['niveau'] != null) ...[
                            const SizedBox(height: 4),
                            Text('Niveau : ${p['niveau']}',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13)),
                          ],
                          if (p['duree_semaines'] != null) ...[
                            Text('Durée : ${p['duree_semaines']} semaines',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13)),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    await context.push(
                                        '/coach/entrainement/${widget.adherentId}/${p['id']}/modifier');
                                    _charger();
                                  },
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
              '/coach/entrainement/${widget.adherentId}/ajouter');
          _charger();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau programme'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
