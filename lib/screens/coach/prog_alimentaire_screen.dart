import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';
import '../coach/prog_simple_screen.dart' show TypeProg;

class ProgAlimentaireScreen extends StatefulWidget {
  final int adherentId;
  const ProgAlimentaireScreen({super.key, required this.adherentId});
  @override State<ProgAlimentaireScreen> createState() => _ProgAlimentaireScreenState();
}

class _ProgAlimentaireScreenState extends State<ProgAlimentaireScreen> {
  List<Map<String, dynamic>> _progs = [];
  Map<String, dynamic>? _adherent;

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final a = await DatabaseHelper.instance.getAdherentParId(widget.adherentId);
    final p = await DatabaseHelper.instance.getProgsAlimentaires(widget.adherentId);
    setState(() { _adherent = a; _progs = p; });
  }

  Future<void> _afficherFormulaire({Map<String, dynamic>? prog}) async {
    final result = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true,
      backgroundColor: AppTheme.blanc,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _FormProgAlimentaire(adherentId: widget.adherentId, prog: prog),
    );
    if (result == true) _charger();
  }

  @override
  Widget build(BuildContext context) {
    final nom = _adherent != null ? '${_adherent!['prenom']} ${_adherent!['nom']}' : '';
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: Text('Programme Alimentaire — $nom')),
      body: _progs.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 72, height: 72,
                decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.restaurant_outlined, size: 36, color: Color(0xFF4CAF50))),
              const SizedBox(height: 16),
              const Text('Aucun programme alimentaire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _afficherFormulaire(),
                icon: const Icon(Icons.add, size: 18), label: const Text('Créer programme'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), minimumSize: const Size(200, 46)),
              ),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _progs.length,
              itemBuilder: (ctx, i) {
                final p = _progs[i];
                final actif = p['actif'] as bool? ?? false;
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: AppTheme.blanc, borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: actif ? const Color(0xFF4CAF50).withOpacity(0.3) : const Color(0xFFEEEEEE))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: actif ? const Color(0xFF4CAF50) : AppTheme.grisTexte,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.restaurant_outlined, color: AppTheme.blanc, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(p['titre'] ?? '', style: const TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.bold, fontSize: 15))),
                        if (actif) Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: const Text('ACTIF', style: TextStyle(color: AppTheme.blanc, fontSize: 11, fontWeight: FontWeight.w800)),
                        ),
                        IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.blanc),
                            onPressed: () => _afficherFormulaire(prog: p), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                        const SizedBox(width: 8),
                        IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white70),
                            onPressed: () async { await DatabaseHelper.instance.supprimerProgAlimentaire(p['id']); _charger(); },
                            padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Stats rapides
                        if (p['calories_jour'] != null || p['proteines_jour'] != null ||
                            p['glucides_jour'] != null || p['lipides_jour'] != null)
                          Wrap(spacing: 8, runSpacing: 6, children: [
                            if (p['calories_jour'] != null)
                              _StatChip('🔥 ${p['calories_jour']} kcal/jour', const Color(0xFF4CAF50)),
                            if (p['proteines_jour'] != null)
                              _StatChip('💪 ${p['proteines_jour']}g protéines', Colors.blue),
                            if (p['glucides_jour'] != null)
                              _StatChip('🍞 ${p['glucides_jour']}g glucides', Colors.brown),
                            if (p['lipides_jour'] != null)
                              _StatChip('🥑 ${p['lipides_jour']}g lipides', Colors.purple),
                            if (p['nb_repas'] != null)
                              _StatChip('🍽 ${p['nb_repas']} repas/jour', Colors.orange),
                          ]),

                        // Principes
                        if (p['principes'] != null && (p['principes'] as String).isNotEmpty) ...[
                          const SizedBox(height: 10),
                          const _MiniHeader('PRINCIPES'),
                          const SizedBox(height: 4),
                          Text(p['principes'], style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.noir)),
                        ],

                        // Planning semaine
                        if (p['planning_lundi'] != null || p['planning_mardi'] != null) ...[
                          const SizedBox(height: 12),
                          const _MiniHeader('PLANNING HEBDOMADAIRE'),
                          const SizedBox(height: 6),
                          _JourRow('Lundi', p['planning_lundi']),
                          _JourRow('Mardi', p['planning_mardi']),
                          _JourRow('Mercredi', p['planning_mercredi']),
                          _JourRow('Jeudi', p['planning_jeudi']),
                          _JourRow('Vendredi', p['planning_vendredi']),
                          _JourRow('Samedi', p['planning_samedi']),
                          _JourRow('Dimanche', p['planning_dimanche']),
                        ],

                        // Aliments à éviter / privilégier
                        if (p['aliments_eviter'] != null && (p['aliments_eviter'] as String).isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const _MiniHeader('❌ À ÉVITER'),
                              const SizedBox(height: 4),
                              Text(p['aliments_eviter'], style: const TextStyle(fontSize: 12, height: 1.5, color: Colors.red)),
                            ])),
                            const SizedBox(width: 12),
                            if (p['aliments_privilegier'] != null)
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                const _MiniHeader('✅ À PRIVILÉGIER'),
                                const SizedBox(height: 4),
                                Text(p['aliments_privilegier'], style: const TextStyle(fontSize: 12, height: 1.5, color: Colors.green)),
                              ])),
                          ]),
                        ],

                        // Conseils
                        if (p['conseils'] != null && (p['conseils'] as String).isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.2))),
                            child: Text(p['conseils'], style: const TextStyle(fontSize: 12, height: 1.5, color: AppTheme.noir)),
                          ),
                        ],
                      ]),
                    ),
                  ]),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _afficherFormulaire(),
        icon: const Icon(Icons.add), label: const Text('Nouveau programme'),
        backgroundColor: const Color(0xFF4CAF50), foregroundColor: AppTheme.blanc,
      ),
    );
  }
}

Widget _StatChip(String text, Color couleur) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(color: couleur.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
  child: Text(text, style: TextStyle(fontSize: 12, color: couleur, fontWeight: FontWeight.w600)),
);

class _MiniHeader extends StatelessWidget {
  final String text;
  const _MiniHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.grisTexte, letterSpacing: 1));
}

Widget _JourRow(String jour, String? contenu) {
  if (contenu == null || contenu.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 72, child: Text(jour, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.orange))),
      Expanded(child: Text(contenu, style: const TextStyle(fontSize: 12, height: 1.5, color: AppTheme.noir))),
    ]),
  );
}

// ═══ FORMULAIRE ═══
class _FormProgAlimentaire extends StatefulWidget {
  final int adherentId; final Map<String, dynamic>? prog;
  const _FormProgAlimentaire({required this.adherentId, this.prog});
  @override State<_FormProgAlimentaire> createState() => _FormProgAlimentaireState();
}

class _FormProgAlimentaireState extends State<_FormProgAlimentaire> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _titreCtrl      = TextEditingController();
  final _descCtrl       = TextEditingController();
  final _calCtrl        = TextEditingController();
  final _protCtrl       = TextEditingController();
  final _glucCtrl       = TextEditingController();
  final _lipCtrl        = TextEditingController();
  final _nbRepasCtrl    = TextEditingController();
  final _principesCtrl  = TextEditingController();
  final _lundiCtrl      = TextEditingController();
  final _mardiCtrl      = TextEditingController();
  final _mercrediCtrl   = TextEditingController();
  final _jeudiCtrl      = TextEditingController();
  final _vendrediCtrl   = TextEditingController();
  final _samediCtrl     = TextEditingController();
  final _dimancheCtrl   = TextEditingController();
  final _eviterCtrl     = TextEditingController();
  final _privilegierCtrl= TextEditingController();
  final _conseilsCtrl   = TextEditingController();
  bool _actif   = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    final p = widget.prog;
    if (p != null) {
      _titreCtrl.text       = p['titre'] ?? '';
      _descCtrl.text        = p['description'] ?? '';
      _calCtrl.text         = p['calories_jour']  != null ? '${p['calories_jour']}'  : '';
      _protCtrl.text        = p['proteines_jour'] != null ? '${p['proteines_jour']}' : '';
      _glucCtrl.text        = p['glucides_jour']  != null ? '${p['glucides_jour']}'  : '';
      _lipCtrl.text         = p['lipides_jour']   != null ? '${p['lipides_jour']}'   : '';
      _nbRepasCtrl.text     = p['nb_repas']       != null ? '${p['nb_repas']}'       : '';
      _principesCtrl.text   = p['principes'] ?? '';
      _lundiCtrl.text       = p['planning_lundi'] ?? '';
      _mardiCtrl.text       = p['planning_mardi'] ?? '';
      _mercrediCtrl.text    = p['planning_mercredi'] ?? '';
      _jeudiCtrl.text       = p['planning_jeudi'] ?? '';
      _vendrediCtrl.text    = p['planning_vendredi'] ?? '';
      _samediCtrl.text      = p['planning_samedi'] ?? '';
      _dimancheCtrl.text    = p['planning_dimanche'] ?? '';
      _eviterCtrl.text      = p['aliments_eviter'] ?? '';
      _privilegierCtrl.text = p['aliments_privilegier'] ?? '';
      _conseilsCtrl.text    = p['conseils'] ?? '';
      _actif                = p['actif'] as bool? ?? true;
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _titreCtrl.dispose(); _descCtrl.dispose(); _calCtrl.dispose();
    _protCtrl.dispose(); _glucCtrl.dispose(); _lipCtrl.dispose();
    _nbRepasCtrl.dispose(); _principesCtrl.dispose();
    _lundiCtrl.dispose(); _mardiCtrl.dispose(); _mercrediCtrl.dispose();
    _jeudiCtrl.dispose(); _vendrediCtrl.dispose(); _samediCtrl.dispose();
    _dimancheCtrl.dispose(); _eviterCtrl.dispose();
    _privilegierCtrl.dispose(); _conseilsCtrl.dispose();
    super.dispose();
  }

  Future<void> _sauvegarder() async {
    if (_titreCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final data = {
      'adherent_id':       widget.adherentId,
      'titre':             _titreCtrl.text.trim(),
      'description':       _descCtrl.text.trim(),
      'actif':             _actif,
      'principes':         _principesCtrl.text.trim(),
      'planning_lundi':    _lundiCtrl.text.trim(),
      'planning_mardi':    _mardiCtrl.text.trim(),
      'planning_mercredi': _mercrediCtrl.text.trim(),
      'planning_jeudi':    _jeudiCtrl.text.trim(),
      'planning_vendredi': _vendrediCtrl.text.trim(),
      'planning_samedi':   _samediCtrl.text.trim(),
      'planning_dimanche': _dimancheCtrl.text.trim(),
      'aliments_eviter':   _eviterCtrl.text.trim(),
      'aliments_privilegier': _privilegierCtrl.text.trim(),
      'conseils':          _conseilsCtrl.text.trim(),
      if (_calCtrl.text.isNotEmpty)    'calories_jour':  int.tryParse(_calCtrl.text),
      if (_protCtrl.text.isNotEmpty)   'proteines_jour': int.tryParse(_protCtrl.text),
      if (_glucCtrl.text.isNotEmpty)   'glucides_jour':  int.tryParse(_glucCtrl.text),
      if (_lipCtrl.text.isNotEmpty)    'lipides_jour':   int.tryParse(_lipCtrl.text),
      if (_nbRepasCtrl.text.isNotEmpty)'nb_repas':       int.tryParse(_nbRepasCtrl.text),
      if (widget.prog == null) 'date_creation': DateTime.now().toIso8601String(),
    };
    if (widget.prog != null) {
      await DatabaseHelper.instance.modifierProgAlimentaire(widget.prog!['id'], data);
    } else {
      await DatabaseHelper.instance.ajouterProgAlimentaire(data);
    }
    setState(() => _loading = false);
    if (mounted) Navigator.pop(context, true);
  }

  Widget _f(TextEditingController c, String label, {int maxLines = 1, String? hint}) =>
    TextFormField(controller: c, maxLines: maxLines,
      keyboardType: maxLines > 1 ? TextInputType.multiline : TextInputType.text,
      decoration: InputDecoration(labelText: label, hintText: hint, alignLabelWithHint: maxLines > 1));

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.92,
      child: Column(children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.grisClair, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            const Text('Programme Alimentaire', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _sauvegarder,
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 38), backgroundColor: const Color(0xFF4CAF50)),
              child: _loading ? const SizedBox(height: 18, width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Enregistrer'),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        TabBar(
          controller: _tabCtrl,
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: AppTheme.grisTexte,
          indicatorColor: const Color(0xFF4CAF50),
          tabs: const [Tab(text: 'Général'), Tab(text: 'Planning semaine'), Tab(text: 'Aliments & Conseils')],
        ),
        Expanded(
          child: TabBarView(controller: _tabCtrl, children: [

            // Tab 1 — Général
            SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
              _f(_titreCtrl, 'Titre du programme *'),
              const SizedBox(height: 8),
              _f(_descCtrl, 'Objectif / Description', maxLines: 2),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextFormField(controller: _calCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Calories/jour (kcal)'))),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: _nbRepasCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Nb repas/jour'))),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextFormField(controller: _protCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Protéines/jour (g)'))),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: _glucCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Glucides/jour (g)'))),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextFormField(controller: _lipCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Lipides/jour (g)'))),
                const SizedBox(width: 8),
                Expanded(child: SwitchListTile(
                  value: _actif, onChanged: (v) => setState(() => _actif = v),
                  title: const Text('Actif', style: TextStyle(fontSize: 13)),
                  contentPadding: EdgeInsets.zero, activeColor: const Color(0xFF4CAF50),
                )),
              ]),
              const SizedBox(height: 8),
              _f(_principesCtrl, 'Principes anti-rétention / règles', maxLines: 5,
                  hint: 'Ex:\n🔵 Hydratation: 2.5-3L eau/jour\n🔴 Sel réduit: <5g/jour\n✅ Sucre raffiné: éliminer...'),
            ])),

            // Tab 2 — Planning semaine
            SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
              const Text('Détaillez les repas de chaque jour',
                  style: TextStyle(fontSize: 12, color: AppTheme.grisTexte)),
              const SizedBox(height: 10),
              ...['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche']
                  .asMap().entries.map((e) {
                final ctrlList = [_lundiCtrl, _mardiCtrl, _mercrediCtrl, _jeudiCtrl,
                    _vendrediCtrl, _samediCtrl, _dimancheCtrl];
                return Column(children: [
                  TextFormField(
                    controller: ctrlList[e.key], maxLines: 4,
                    decoration: InputDecoration(
                      labelText: e.value,
                      alignLabelWithHint: true,
                      hintText: 'Petit-déj: ...\nDéjeuner: ...\nDîner: ...',
                    ),
                  ),
                  const SizedBox(height: 8),
                ]);
              }),
            ])),

            // Tab 3 — Aliments & Conseils
            SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
              _f(_eviterCtrl, '❌ Aliments à ÉVITER', maxLines: 5,
                  hint: 'Ex:\nSel & condiments: harissa industrielle, conserves...\nGlucides: pain blanc, pâtes blanches...\nBoissons: sodas, jus sucrés...'),
              const SizedBox(height: 8),
              _f(_privilegierCtrl, '✅ Aliments à PRIVILÉGIER', maxLines: 5,
                  hint: 'Ex:\nGlucides: pain complet, flocons avoine, riz complet...\nGraisses: huile olive, sardines...\nLaitiers: labneh, yaourt 0%...'),
              const SizedBox(height: 8),
              _f(_conseilsCtrl, '💡 Conseils supplémentaires', maxLines: 5,
                  hint: 'Ex:\n🌙 Sommeil: 7-8h minimum\n💊 Suppléments: Magnésium 300mg...\n☀️ Soleil: 20 min marche/jour...'),
            ])),
          ]),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}
