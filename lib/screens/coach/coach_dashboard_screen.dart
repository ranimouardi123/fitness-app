import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});
  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  List<Map<String, dynamic>> _adherents = [];
  String _nomCoach = '';

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final nom       = await AuthService().getNomComplet();
    final adherents = await DatabaseHelper.instance.getTousAdherents();
    setState(() { _nomCoach = nom; _adherents = adherents; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        backgroundColor: AppTheme.blanc,
        title: Image.asset('assets/images/logo.png', height: 36, fit: BoxFit.contain),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline, color: AppTheme.noir),
            onPressed: () async { await context.push('/coach/adherents'); _charger(); },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.noir),
            onPressed: () async { await AuthService().deconnexion(); if (mounted) context.go('/login'); },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.orange,
        onRefresh: _charger,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Header banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                decoration: const BoxDecoration(
                  color: AppTheme.noir,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Bonjour,', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(_nomCoach, style: const TextStyle(color: AppTheme.blanc, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(children: [
                    _StatBox(valeur: '${_adherents.length}', label: 'Adhérents'),
                    const SizedBox(width: 12),
                    _StatBox(valeur: '${_adherents.length}', label: 'Actifs'),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () async { await context.push('/coach/adherents/ajouter'); _charger(); },
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Ajouter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.orange,
                        foregroundColor: AppTheme.blanc,
                        minimumSize: const Size(0, 42),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ]),
                ]),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mes adhérents',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.noir)),
                      if (_adherents.isNotEmpty)
                        TextButton(
                          onPressed: () async { await context.push('/coach/adherents'); _charger(); },
                          child: const Text('Voir tous', style: TextStyle(color: AppTheme.orange, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_adherents.isEmpty)
                    _EmptyState(onAjouter: () async { await context.push('/coach/adherents/ajouter'); _charger(); })
                  else
                    ..._adherents.map((a) => _AdherentCard(
                      adherent: a,
                      onTap: () async { await context.push('/coach/adherent/${a['id']}'); _charger(); },
                    )),

                  const SizedBox(height: 80),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String valeur, label;
  const _StatBox({required this.valeur, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(children: [
      Text(valeur, style: const TextStyle(color: AppTheme.orange, fontSize: 22, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
    ]),
  );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAjouter;
  const _EmptyState({required this.onAjouter});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(children: [
        Container(width: 72, height: 72,
          decoration: BoxDecoration(color: AppTheme.orange.withOpacity(0.08), shape: BoxShape.circle),
          child: const Icon(Icons.people_outline, size: 36, color: AppTheme.orange)),
        const SizedBox(height: 16),
        const Text('Aucun adhérent', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.noir)),
        const SizedBox(height: 6),
        const Text('Ajoutez votre premier adhérent', style: TextStyle(color: AppTheme.grisTexte, fontSize: 13)),
        const SizedBox(height: 20),
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            onPressed: onAjouter,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Ajouter'),
          ),
        ),
      ]),
    ),
  );
}

class _AdherentCard extends StatelessWidget {
  final Map<String, dynamic> adherent;
  final VoidCallback onTap;
  const _AdherentCard({required this.adherent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initiales = '${(adherent['prenom'] as String? ?? 'A')[0]}${(adherent['nom'] as String? ?? 'A')[0]}'.toUpperCase();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.blanc,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.orange, AppTheme.orangeDark],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(child: Text(initiales,
                style: const TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.bold, fontSize: 16))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${adherent['prenom']} ${adherent['nom']}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppTheme.noir)),
            const SizedBox(height: 2),
            Row(children: [
              if (adherent['code_acces'] != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.orange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(adherent['code_acces'],
                      style: const TextStyle(fontSize: 11, color: AppTheme.orange, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 6),
              ],
              if (adherent['objectif'] != null)
                Expanded(child: Text(adherent['objectif'],
                    style: const TextStyle(fontSize: 12, color: AppTheme.grisTexte),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ])),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_forward_ios, size: 13, color: AppTheme.orange),
          ),
        ]),
      ),
    );
  }
}
