import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class AdherentsScreen extends StatefulWidget {
  const AdherentsScreen({super.key});
  @override
  State<AdherentsScreen> createState() => _AdherentsScreenState();
}

class _AdherentsScreenState extends State<AdherentsScreen> {
  List<Map<String, dynamic>> _adherents = [];

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final list = await DatabaseHelper.instance.getTousAdherents();
    setState(() => _adherents = list);
  }

  Future<void> _supprimer(int id, String nom) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'adhérent'),
        content: Text('Voulez-vous vraiment supprimer $nom ?\nTous ses programmes seront supprimés.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
              child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirme == true) {
      await DatabaseHelper.instance.supprimerAdherent(id);
      _charger();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes adhérents')),
      body: RefreshIndicator(
        onRefresh: _charger,
        child: _adherents.isEmpty
            ? const Center(child: Text('Aucun adhérent'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _adherents.length,
                itemBuilder: (ctx, i) {
                  final a = _adherents[i];
                  final initiales =
                      '${(a['prenom'] as String? ?? 'A')[0]}${(a['nom'] as String? ?? 'A')[0]}'.toUpperCase();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.orange.withOpacity(0.15),
                        backgroundImage: a['photo'] != null
                            ? MemoryImage(base64Decode(a['photo'])) : null,
                        child: a['photo'] == null
                            ? Text(initiales, style: const TextStyle(
                                color: AppTheme.orange, fontWeight: FontWeight.bold))
                            : null,
                      ),
                      title: Text('${a['prenom']} ${a['nom']}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (a['code_acces'] != null)
                          Text('Code : ${a['code_acces']}',
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppTheme.orange)),
                        if (a['objectif'] != null)
                          Text('Objectif : ${a['objectif']}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.grisTexte)),
                      ]),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
                          onPressed: () async {
                            await context.push('/coach/adherents/${a['id']}/modifier');
                            _charger();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
                          onPressed: () => _supprimer(a['id'], '${a['prenom']} ${a['nom']}'),
                        ),
                      ]),
                      onTap: () => context.push('/coach/adherent/${a['id']}'),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/coach/adherents/ajouter');
          _charger();
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter'),
        backgroundColor: AppTheme.orange,
        foregroundColor: Colors.white,
      ),
    );
  }
}
