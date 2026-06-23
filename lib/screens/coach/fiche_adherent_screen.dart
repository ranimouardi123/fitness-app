import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class FicheAdherentScreen extends StatefulWidget {
  final int adherentId;
  const FicheAdherentScreen({super.key, required this.adherentId});
  @override
  State<FicheAdherentScreen> createState() => _FicheAdherentScreenState();
}

class _FicheAdherentScreenState extends State<FicheAdherentScreen> {
  Map<String, dynamic>? _adherent;
  Map<String, dynamic>? _dernierBilan;
  int _nbBilans = 0;

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final a      = await DatabaseHelper.instance.getAdherentParId(widget.adherentId);
    final bilans = await DatabaseHelper.instance.getBilansCorporels(widget.adherentId);
    setState(() {
      _adherent     = a;
      _dernierBilan = bilans.isNotEmpty ? bilans.first : null;
      _nbBilans     = bilans.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = _adherent;
    if (a == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.orange)));
    final nom       = '${a['prenom']} ${a['nom']}';
    final initiales = '${(a['prenom'] as String? ?? 'A')[0]}${(a['nom'] as String? ?? 'A')[0]}'.toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.noir,
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.blanc), onPressed: () => context.pop()),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppTheme.blanc),
                onPressed: () async { await context.push('/coach/adherents/${widget.adherentId}/modifier'); _charger(); },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.noir, Color(0xFF3A1F10)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        // ── Photo ou initiales ──
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                          clipBehavior: Clip.antiAlias,
                          child: a['photo'] != null
                              ? Image.memory(base64Decode(a['photo']), fit: BoxFit.cover)
                              : Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(colors: [AppTheme.orange, AppTheme.orangeDark]),
                                  ),
                                  child: Center(child: Text(initiales,
                                      style: const TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.bold, fontSize: 22))),
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(nom, style: const TextStyle(color: AppTheme.blanc, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          if (a['code_acces'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: AppTheme.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                              child: Text(a['code_acces'], style: const TextStyle(color: AppTheme.orange, fontFamily: 'monospace', fontWeight: FontWeight.w700, fontSize: 12))),
                          if (a['objectif'] != null) ...[
                            const SizedBox(height: 4),
                            Text(a['objectif'], style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                          ],
                        ])),
                      ]),
                      const SizedBox(height: 14),
                      Row(children: [
                        if (a['poids'] != null) _InfoPill('${a['poids']} kg', Icons.monitor_weight_outlined),
                        if (a['taille'] != null) ...[const SizedBox(width: 8), _InfoPill('${a['taille']} cm', Icons.height)],
                        const SizedBox(width: 8),
                        _InfoPill('$_nbBilans bilan${_nbBilans > 1 ? 's' : ''}', Icons.assignment_outlined),
                        if (_dernierBilan != null) ...[
                          const SizedBox(width: 8),
                          _InfoPill(_dernierBilan!['date'] ?? '', Icons.calendar_today),
                        ],
                      ]),
                    ]),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                if (_dernierBilan != null) ...[
                  _SectionLabel('DERNIER BILAN INBODY'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppTheme.blanc, borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEEEEEE))),
                    child: Wrap(spacing: 8, runSpacing: 8, children: [
                      if (_dernierBilan!['poids'] != null) _QuickStat('Poids', '${_dernierBilan!['poids']} kg', AppTheme.primary),
                      if (_dernierBilan!['masse_grasse_kg'] != null) _QuickStat('M. Grasse', '${_dernierBilan!['masse_grasse_kg']} kg', Colors.red),
                      if (_dernierBilan!['tgc'] != null) _QuickStat('TGC', '${_dernierBilan!['tgc']}%', Colors.orange),
                      if (_dernierBilan!['mms'] != null) _QuickStat('MMS', '${_dernierBilan!['mms']} kg', Colors.green),
                      if (_dernierBilan!['imc'] != null) _QuickStat('IMC', '${_dernierBilan!['imc']}', Colors.purple),
                      if (_dernierBilan!['score_inbody'] != null) _QuickStat('Score', '${_dernierBilan!['score_inbody']}/100', AppTheme.orange),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ],

                _SectionLabel('BILANS'),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _MenuCard(icon: Icons.monitor_weight_outlined, titre: 'Bilan InBody',
                      sousTitre: '$_nbBilans bilan${_nbBilans > 1 ? 's' : ''}', couleur: AppTheme.orange,
                      onTap: () => context.push('/coach/adherent/${widget.adherentId}/bilan-corporel'))),
                  const SizedBox(width: 10),
                  Expanded(child: _MenuCard(icon: Icons.trending_up, titre: 'Suivi Mensuel',
                      sousTitre: 'Tableau évolution', couleur: const Color(0xFF8B5CF6),
                      onTap: () => context.push('/coach/adherent/${widget.adherentId}/suivi-mensuel'))),
                ]),
                const SizedBox(height: 10),
                _MenuCard(icon: Icons.bloodtype_outlined, titre: 'Bilan Sanguin',
                    sousTitre: 'Glycémie, cholestérol, hémoglobine...', couleur: AppTheme.danger,
                    onTap: () => context.push('/coach/adherent/${widget.adherentId}/bilan-sanguin')),
                const SizedBox(height: 20),

                _SectionLabel('PROGRAMMES'),
                const SizedBox(height: 10),
                _MenuCard(icon: Icons.restaurant_outlined, titre: 'Programme Alimentaire',
                    sousTitre: 'Planning repas, kcal, macros, conseils', couleur: const Color(0xFF4CAF50),
                    onTap: () => context.push('/coach/adherent/${widget.adherentId}/prog-alimentaire')),
                const SizedBox(height: 10),
                _MenuCard(icon: Icons.fitness_center, titre: 'Programme Musculation',
                    sousTitre: 'Séances/semaine, exercices, séries × reps', couleur: AppTheme.orange,
                    onTap: () => context.push('/coach/adherent/${widget.adherentId}/prog-musculation')),
                const SizedBox(height: 10),
                _MenuCard(icon: Icons.directions_run, titre: 'Programme Cardio',
                    sousTitre: 'Type, durée, intensité, zone FC', couleur: const Color(0xFFFFC107),
                    onTap: () => context.push('/coach/adherent/${widget.adherentId}/prog-cardio')),
                const SizedBox(height: 20),

                _SectionLabel('SUIVI QUOTIDIEN'),
                const SizedBox(height: 10),
                _MenuCard(icon: Icons.show_chart, titre: 'Tracker Hebdomadaire',
                    sousTitre: 'Suivi semaine par semaine — à jeun', couleur: const Color(0xFF8B5CF6),
                    onTap: () => context.push('/coach/adherent/${widget.adherentId}/tracker')),
                const SizedBox(height: 10),
                _MenuCard(
                    icon: Icons.chat_bubble_outline,
                    titre: 'Messagerie',
                    sousTitre: 'Envoyer un message à l\'adhérent',
                    couleur: const Color(0xFF00897B),
                    onTap: () => context.push('/coach/adherent/${widget.adherentId}/chat?nom=${Uri.encodeComponent(nom)}')),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _InfoPill(String text, IconData icon) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
  child: Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: Colors.white70),
    const SizedBox(width: 4),
    Text(text, style: const TextStyle(color: AppTheme.blanc, fontSize: 11, fontWeight: FontWeight.w500)),
  ]),
);

Widget _QuickStat(String label, String val, Color couleur) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  decoration: BoxDecoration(color: couleur.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
  child: Column(children: [
    Text(val, style: TextStyle(fontWeight: FontWeight.bold, color: couleur, fontSize: 14)),
    Text(label, style: TextStyle(fontSize: 10, color: couleur.withOpacity(0.8))),
  ]),
);

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.grisTexte, letterSpacing: 1.5));
}

class _MenuCard extends StatelessWidget {
  final IconData icon; final String titre, sousTitre; final Color couleur; final VoidCallback onTap;
  const _MenuCard({required this.icon, required this.titre, required this.sousTitre, required this.couleur, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.blanc, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE))),
      child: Row(children: [
        Container(width: 42, height: 42,
          decoration: BoxDecoration(color: couleur.withOpacity(0.12), borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, color: couleur, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.noir)),
          Text(sousTitre, style: const TextStyle(fontSize: 11, color: AppTheme.grisTexte)),
        ])),
        Container(padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: couleur.withOpacity(0.08), borderRadius: BorderRadius.circular(7)),
          child: Icon(Icons.arrow_forward_ios, size: 11, color: couleur)),
      ]),
    ),
  );
}
