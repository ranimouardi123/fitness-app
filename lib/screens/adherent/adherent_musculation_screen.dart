import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';
import '../coach/exercice_selector.dart' show fetchGif;

// ═══════════════════════════════════════════════════════════════
//  ÉCRAN PRINCIPAL
// ═══════════════════════════════════════════════════════════════

class AdherentMusculationScreen extends StatefulWidget {
  final int programmeId;
  const AdherentMusculationScreen({super.key, required this.programmeId});
  @override
  State<AdherentMusculationScreen> createState() => _AdherentMusculationScreenState();
}

class _AdherentMusculationScreenState extends State<AdherentMusculationScreen> {
  Map<String, dynamic>? _prog;
  int? _jourOuvert;

  static const _joursKeys = [
    {'titre': 'jour1_titre', 'contenu': 'jour1_contenu'},
    {'titre': 'jour2_titre', 'contenu': 'jour2_contenu'},
    {'titre': 'jour3_titre', 'contenu': 'jour3_contenu'},
    {'titre': 'jour4_titre', 'contenu': 'jour4_contenu'},
    {'titre': 'jour5_titre', 'contenu': 'jour5_contenu'},
  ];

  static const _jourColors = [
    Color(0xFF1565C0), Color(0xFF2E7D32), Color(0xFF6A1B9A),
    Color(0xFFBF360C), Color(0xFFE65100),
  ];

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final p = await DatabaseHelper.instance.getProgMusculationParId(widget.programmeId);
    setState(() => _prog = p);
  }

  @override
  Widget build(BuildContext context) {
    final prog = _prog;
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        title: const Text('Mon programme musculation'),
        backgroundColor: AppTheme.noir,
        foregroundColor: AppTheme.blanc,
      ),
      body: prog == null
          ? const Center(child: CircularProgressIndicator(color: AppTheme.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.noir, Color(0xFF3A1F10)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Image.asset('assets/images/logo.png', height: 30, fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: AppTheme.orange, size: 24)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(prog['titre'] ?? '',
                            style: const TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w800, fontSize: 16)),
                        if (prog['objectif'] != null && (prog['objectif'] as String).isNotEmpty)
                          Text(prog['objectif'],
                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                      ])),
                    ]),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, children: [
                      if (prog['nb_jours'] != null) _Pill('💪 ${prog['nb_jours']} jours/sem'),
                      if (prog['duree_seance'] != null) _Pill('⏱ ${prog['duree_seance']} min'),
                      if (prog['niveau'] != null) _Pill('📊 ${prog['niveau']}'),
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),

                // Paramètres
                if (prog['parametres'] != null && (prog['parametres'] as String).isNotEmpty) ...[
                  _SectionBanner('⚙️ PARAMÈTRES', const Color(0xFF37474F)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.blanc,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Text(prog['parametres'],
                        style: const TextStyle(fontSize: 13, height: 1.7, color: AppTheme.noir)),
                  ),
                  const SizedBox(height: 16),
                ],

                // Jours
                _SectionBanner('💪 PROGRAMME — Détail des séances', AppTheme.orange),
                const SizedBox(height: 10),

                ..._joursKeys.asMap().entries.where((e) {
                  final c = prog[e.value['contenu']];
                  return c != null && (c as String).isNotEmpty;
                }).map((e) {
                  final i = e.key;
                  final couleur = _jourColors[i % _jourColors.length];
                  final titre = prog[e.value['titre']] ?? 'Jour ${i + 1}';
                  final contenu = prog[e.value['contenu']] as String;
                  final isOpen = _jourOuvert == i;

                  return Column(children: [
                    GestureDetector(
                      onTap: () => setState(() => _jourOuvert = isOpen ? null : i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isOpen ? couleur : couleur.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(children: [
                          Text(titre, style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14,
                              color: isOpen ? AppTheme.blanc : couleur)),
                          const Spacer(),
                          Icon(isOpen ? Icons.expand_less : Icons.expand_more,
                              color: isOpen ? AppTheme.blanc : couleur, size: 20),
                        ]),
                      ),
                    ),
                    if (isOpen) _ExercicesDetail(contenu: contenu, couleur: couleur),
                    const SizedBox(height: 6),
                  ]);
                }),

                // Cardio
                if (prog['cardio_antiretion'] != null && (prog['cardio_antiretion'] as String).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _SectionBanner('🏃 CARDIO ANTI-RÉTENTION', const Color(0xFF1565C0)),
                  const SizedBox(height: 8),
                  _CardioTable(contenu: prog['cardio_antiretion'] as String),
                ],

                const SizedBox(height: 32),
              ]),
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  DÉTAIL EXERCICES avec GIFs
// ═══════════════════════════════════════════════════════════════

class _ExercicesDetail extends StatelessWidget {
  final String contenu;
  final Color couleur;
  const _ExercicesDetail({required this.contenu, required this.couleur});

  @override
  Widget build(BuildContext context) {
    final lignes = contenu.trim().split('\n').where((l) => l.trim().isNotEmpty).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.02),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
        border: Border.all(color: couleur.withOpacity(0.15)),
      ),
      child: Column(
        children: lignes.asMap().entries.map((e) {
          final parts = e.value.split('|').map((s) => s.trim()).toList();
          final nomExercice = parts.isNotEmpty ? parts[0] : '';
          final description = parts.length > 1 ? parts[1] : '';
          final seriesReps  = parts.length > 2 ? parts[2] : '';
          final repos       = parts.length > 3 ? parts[3] : '';
          final intensite   = parts.length > 4 ? parts[4] : '';

          return Container(
            decoration: BoxDecoration(
              color: e.key % 2 == 0 ? Colors.transparent : couleur.withOpacity(0.02),
              border: Border(bottom: BorderSide(color: couleur.withOpacity(0.08))),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              childrenPadding: EdgeInsets.zero,
              leading: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: couleur.withOpacity(0.12), shape: BoxShape.circle),
                child: Center(child: Text('${e.key + 1}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: couleur))),
              ),
              title: Text(nomExercice,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: couleur)),
              subtitle: seriesReps.isNotEmpty
                  ? Text('$seriesReps${repos.isNotEmpty ? ' • $repos' : ''}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.grisTexte))
                  : null,
              children: [
                _ExerciceDetail(
                  nom: nomExercice,
                  description: description,
                  seriesReps: seriesReps,
                  repos: repos,
                  intensite: intensite,
                  couleur: couleur,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ExerciceDetail extends StatefulWidget {
  final String nom, description, seriesReps, repos, intensite;
  final Color couleur;
  const _ExerciceDetail({
    required this.nom, required this.description, required this.seriesReps,
    required this.repos, required this.intensite, required this.couleur,
  });
  @override
  State<_ExerciceDetail> createState() => _ExerciceDetailState();
}

class _ExerciceDetailState extends State<_ExerciceDetail> {
  String? _gifUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGif();
  }

  Future<void> _loadGif() async {
    final url = await fetchGif(widget.nom);
    if (mounted) setState(() { _gifUrl = url; _loading = false; });
  }

  void _showFullscreen() {
    if (_gifUrl == null) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(children: [
          InteractiveViewer(
            child: Center(
              child: Image.network(_gifUrl!,
                fit: BoxFit.contain,
                headers: const {'User-Agent': 'Mozilla/5.0'}),
            ),
          ),
          Positioned(top: 12, right: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            )),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // GIF cliquable
        GestureDetector(
          onTap: _showFullscreen,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _loading
                ? Container(
                    height: 220, width: double.infinity,
                    color: widget.couleur.withOpacity(0.08),
                    child: Center(child: CircularProgressIndicator(
                        strokeWidth: 2, color: widget.couleur)))
                : _gifUrl != null
                    ? Stack(children: [
                        Image.network(_gifUrl!,
                          height: 220, width: double.infinity, fit: BoxFit.cover,
                          headers: const {'User-Agent': 'Mozilla/5.0'},
                          errorBuilder: (_, __, ___) => _GifPlaceholder(couleur: widget.couleur)),
                        Positioned(bottom: 8, right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6)),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.fullscreen, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('Agrandir', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ]),
                          )),
                      ])
                    : _GifPlaceholder(couleur: widget.couleur),
          ),
        ),
        const SizedBox(height: 10),
        // Description
        if (widget.description.isNotEmpty) ...[
          Text(widget.description,
              style: const TextStyle(fontSize: 12, color: AppTheme.grisTexte, height: 1.5)),
          const SizedBox(height: 8),
        ],
        // Chips
        Wrap(spacing: 8, runSpacing: 6, children: [
          if (widget.seriesReps.isNotEmpty)
            _InfoChip(Icons.repeat, widget.seriesReps, widget.couleur),
          if (widget.repos.isNotEmpty)
            _InfoChip(Icons.timer_outlined, widget.repos, const Color(0xFF1565C0)),
          if (widget.intensite.isNotEmpty)
            _InfoChip(Icons.bolt, widget.intensite, Colors.orange),
        ]),
      ]),
    );
  }
}

class _GifPlaceholder extends StatelessWidget {
  final Color couleur;
  const _GifPlaceholder({required this.couleur});
  @override
  Widget build(BuildContext context) => Container(
    height: 160, width: double.infinity,
    color: couleur.withOpacity(0.08),
    child: Center(child: Icon(Icons.fitness_center, size: 48, color: couleur.withOpacity(0.3))),
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon; final String label; final Color couleur;
  const _InfoChip(this.icon, this.label, this.couleur);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: couleur.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: couleur),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: couleur, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════
//  CARDIO TABLE
// ═══════════════════════════════════════════════════════════════

class _CardioTable extends StatelessWidget {
  final String contenu;
  const _CardioTable({required this.contenu});
  @override
  Widget build(BuildContext context) {
    final lignes = contenu.trim().split('\n').where((l) => l.trim().isNotEmpty).toList();
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withOpacity(0.02),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.15)),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.07)),
          child: const Row(children: [
            Expanded(flex: 2, child: Text('Jour', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.grisTexte))),
            Expanded(flex: 3, child: Text('Type', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.grisTexte))),
            Expanded(flex: 2, child: Text('Durée', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.grisTexte), textAlign: TextAlign.center)),
            Expanded(flex: 3, child: Text('Objectif', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.grisTexte), textAlign: TextAlign.center)),
          ]),
        ),
        ...lignes.asMap().entries.map((e) {
          final parts = e.value.split('|').map((s) => s.trim()).toList();
          return Container(
            decoration: BoxDecoration(
              color: e.key % 2 == 0 ? Colors.transparent : const Color(0xFF1565C0).withOpacity(0.02),
              border: Border(bottom: BorderSide(color: const Color(0xFF1565C0).withOpacity(0.06))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(children: [
              Expanded(flex: 2, child: Text(parts.isNotEmpty ? parts[0] : '',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1565C0)))),
              Expanded(flex: 3, child: Text(parts.length > 1 ? parts[1] : '',
                  style: const TextStyle(fontSize: 11, color: AppTheme.noir))),
              Expanded(flex: 2, child: Text(parts.length > 2 ? parts[2] : '',
                  style: const TextStyle(fontSize: 10, color: AppTheme.grisTexte), textAlign: TextAlign.center)),
              Expanded(flex: 3, child: Text(parts.length > 4 ? parts[4] : (parts.length > 3 ? parts[3] : ''),
                  style: const TextStyle(fontSize: 10, color: AppTheme.grisTexte), textAlign: TextAlign.center)),
            ]),
          );
        }),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  WIDGETS UTILITAIRES
// ═══════════════════════════════════════════════════════════════

Widget _Pill(String t) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
  child: Text(t, style: const TextStyle(fontSize: 11, color: Colors.white70)),
);

Widget _SectionBanner(String t, Color c) => Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
  decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8)),
  child: Text(t, style: const TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w700, fontSize: 12)),
);
