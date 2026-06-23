import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';
import 'exercice_selector.dart';
import 'exercices_data.dart';

class ProgMusculationScreen extends StatefulWidget {
  final int adherentId;
  const ProgMusculationScreen({super.key, required this.adherentId});
  @override State<ProgMusculationScreen> createState() => _ProgMusculationScreenState();
}

class _ProgMusculationScreenState extends State<ProgMusculationScreen> {
  List<Map<String, dynamic>> _progs = [];
  Map<String, dynamic>? _adherent;

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final a = await DatabaseHelper.instance.getAdherentParId(widget.adherentId);
    final p = await DatabaseHelper.instance.getProgsMusculation(widget.adherentId);
    setState(() { _adherent = a; _progs = p; });
  }

  Future<void> _afficherFormulaire({Map<String, dynamic>? prog}) async {
    final result = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true,
      backgroundColor: AppTheme.blanc,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _FormProgMusculation(adherentId: widget.adherentId, prog: prog),
    );
    if (result == true) _charger();
  }

  @override
  Widget build(BuildContext context) {
    final nom = _adherent != null ? '${_adherent!['prenom']} ${_adherent!['nom']}' : '';
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: Text('Programme Musculation — $nom')),
      body: _progs.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 72, height: 72,
                decoration: BoxDecoration(color: AppTheme.orange.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.fitness_center, size: 36, color: AppTheme.orange)),
              const SizedBox(height: 16),
              const Text('Aucun programme musculation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _afficherFormulaire(),
                icon: const Icon(Icons.add, size: 18), label: const Text('Créer programme'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(200, 46)),
              ),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _progs.length,
              itemBuilder: (ctx, i) => _ProgCard(
                prog: _progs[i],
                onModifier: () => _afficherFormulaire(prog: _progs[i]),
                onSupprimer: () async {
                  await DatabaseHelper.instance.supprimerProgMusculation(_progs[i]['id']);
                  _charger();
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _afficherFormulaire(),
        icon: const Icon(Icons.add), label: const Text('Nouveau programme'),
        backgroundColor: AppTheme.orange, foregroundColor: AppTheme.blanc,
      ),
    );
  }
}

// ═══ CARD AFFICHAGE ═══
class _ProgCard extends StatefulWidget {
  final Map<String, dynamic> prog;
  final VoidCallback onModifier, onSupprimer;
  const _ProgCard({required this.prog, required this.onModifier, required this.onSupprimer});
  @override State<_ProgCard> createState() => _ProgCardState();
}

class _ProgCardState extends State<_ProgCard> {
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
  Widget build(BuildContext context) {
    final p = widget.prog;
    final actif = p['actif'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppTheme.blanc, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: actif ? AppTheme.orange.withOpacity(0.3) : const Color(0xFFEEEEEE))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.noir, Color(0xFF3A1F10)]),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Image.asset('assets/images/logo.png', height: 26, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: AppTheme.orange, size: 20)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p['titre'] ?? '', style: const TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w800, fontSize: 14)),
                if (p['objectif'] != null && (p['objectif'] as String).isNotEmpty)
                  Text(p['objectif'], style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
              ])),
              if (actif) Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppTheme.orange, borderRadius: BorderRadius.circular(20)),
                child: const Text('ACTIF', style: TextStyle(color: AppTheme.blanc, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.blanc),
                  onPressed: widget.onModifier, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              const SizedBox(width: 4),
              IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white54),
                  onPressed: widget.onSupprimer, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            ]),
            const SizedBox(height: 6),
            Wrap(spacing: 6, children: [
              if (p['nb_jours'] != null) _Pill('💪 ${p['nb_jours']} jours/sem'),
              if (p['duree_seance'] != null) _Pill('⏱ ${p['duree_seance']} min'),
              if (p['niveau'] != null) _Pill('📊 ${p['niveau']}'),
            ]),
          ]),
        ),

        // Paramètres
        if (p['parametres'] != null && (p['parametres'] as String).isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _SectionBanner('⚙️ PARAMÈTRES D\'ENTRAÎNEMENT', const Color(0xFF37474F)),
              const SizedBox(height: 6),
              Text(p['parametres'], style: const TextStyle(fontSize: 12, height: 1.6, color: AppTheme.noir)),
            ]),
          ),

        // Jours accordéon
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SectionBanner('💪 PROGRAMME — Détail des Séances', AppTheme.orange),
            const SizedBox(height: 8),
            ..._joursKeys.asMap().entries.where((e) {
              final c = p[e.value['contenu']];
              return c != null && (c as String).isNotEmpty;
            }).map((e) {
              final i = e.key;
              final couleur = _jourColors[i % _jourColors.length];
              final titre = p[e.value['titre']] ?? 'Jour ${i + 1}';
              final contenu = p[e.value['contenu']] as String;
              final isOpen = _jourOuvert == i;

              return Column(children: [
                GestureDetector(
                  onTap: () => setState(() => _jourOuvert = isOpen ? null : i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isOpen ? couleur : couleur.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      Text(titre, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                          color: isOpen ? AppTheme.blanc : couleur)),
                      const Spacer(),
                      Icon(isOpen ? Icons.expand_less : Icons.expand_more,
                          color: isOpen ? AppTheme.blanc : couleur, size: 18),
                    ]),
                  ),
                ),
                if (isOpen) _ExercicesTable(contenu: contenu, couleur: couleur),
              ]);
            }),
          ]),
        ),

        // Cardio
        if (p['cardio_antiretion'] != null && (p['cardio_antiretion'] as String).isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _SectionBanner('🏃 CARDIO ANTI-RÉTENTION', const Color(0xFF1565C0)),
              const SizedBox(height: 6),
              _CardioTable(contenu: p['cardio_antiretion'] as String),
            ]),
          ),
      ]),
    );
  }
}

Widget _Pill(String t) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
  child: Text(t, style: const TextStyle(fontSize: 11, color: Colors.white70)),
);

Widget _SectionBanner(String t, Color c) => Container(
  width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)),
  child: Text(t, style: const TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w700, fontSize: 11)),
);

class _ExercicesTable extends StatelessWidget {
  final String contenu; final Color couleur;
  const _ExercicesTable({required this.contenu, required this.couleur});
  @override
  Widget build(BuildContext context) {
    final lignes = contenu.trim().split('\n').where((l) => l.trim().isNotEmpty).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.02),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        border: Border.all(color: couleur.withOpacity(0.12)),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: couleur.withOpacity(0.07)),
          child: Row(children: const [
            Expanded(flex: 3, child: Text('Exercice', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.grisTexte))),
            Expanded(flex: 4, child: Text('Description', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.grisTexte))),
            Expanded(flex: 2, child: Text('Séries×Reps', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.grisTexte), textAlign: TextAlign.center)),
            Expanded(flex: 1, child: Text('Repos', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.grisTexte), textAlign: TextAlign.center)),
            Expanded(flex: 2, child: Text('Intensité', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.grisTexte), textAlign: TextAlign.center)),
          ]),
        ),
        ...lignes.asMap().entries.map((e) {
          final parts = e.value.split('|').map((s) => s.trim()).toList();
          return Container(
            decoration: BoxDecoration(
              color: e.key % 2 == 0 ? Colors.transparent : couleur.withOpacity(0.02),
              border: Border(bottom: BorderSide(color: couleur.withOpacity(0.06))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 3, child: Text(parts.isNotEmpty ? parts[0] : '',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.noir))),
              Expanded(flex: 4, child: Text(parts.length > 1 ? parts[1] : '',
                  style: const TextStyle(fontSize: 10, color: AppTheme.grisTexte))),
              Expanded(flex: 2, child: Text(parts.length > 2 ? parts[2] : '',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: couleur), textAlign: TextAlign.center)),
              Expanded(flex: 1, child: Text(parts.length > 3 ? parts[3] : '',
                  style: const TextStyle(fontSize: 9, color: AppTheme.grisTexte), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text(parts.length > 4 ? parts[4] : '',
                  style: const TextStyle(fontSize: 9, color: AppTheme.grisTexte), textAlign: TextAlign.center)),
            ]),
          );
        }),
      ]),
    );
  }
}

class _CardioTable extends StatelessWidget {
  final String contenu;
  const _CardioTable({required this.contenu});
  @override
  Widget build(BuildContext context) {
    final lignes = contenu.trim().split('\n').where((l) => l.trim().isNotEmpty).toList();
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.02),
          borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.12))),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.07)),
          child: Row(children: const [
            Expanded(flex: 2, child: Text('Jour', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.grisTexte))),
            Expanded(flex: 3, child: Text('Type Cardio', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.grisTexte))),
            Expanded(flex: 2, child: Text('Durée', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.grisTexte), textAlign: TextAlign.center)),
            Expanded(flex: 2, child: Text('Intensité', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.grisTexte), textAlign: TextAlign.center)),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(children: [
              Expanded(flex: 2, child: Text(parts.isNotEmpty ? parts[0] : '',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1565C0)))),
              Expanded(flex: 3, child: Text(parts.length > 1 ? parts[1] : '',
                  style: const TextStyle(fontSize: 11, color: AppTheme.noir))),
              Expanded(flex: 2, child: Text(parts.length > 2 ? parts[2] : '',
                  style: const TextStyle(fontSize: 10, color: AppTheme.grisTexte), textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text(parts.length > 3 ? parts[3] : '',
                  style: const TextStyle(fontSize: 10, color: AppTheme.grisTexte), textAlign: TextAlign.center)),
              Expanded(flex: 3, child: Text(parts.length > 4 ? parts[4] : '',
                  style: const TextStyle(fontSize: 10, color: AppTheme.grisTexte), textAlign: TextAlign.center)),
            ]),
          );
        }),
      ]),
    );
  }
}

// ═══ FORMULAIRE AVEC SÉLECTEUR ═══
class _FormProgMusculation extends StatefulWidget {
  final int adherentId; final Map<String, dynamic>? prog;
  const _FormProgMusculation({required this.adherentId, this.prog});
  @override State<_FormProgMusculation> createState() => _FormProgMusculationState();
}

class _FormProgMusculationState extends State<_FormProgMusculation> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _titreCtrl    = TextEditingController();
  final _objectifCtrl = TextEditingController();
  final _nbJoursCtrl  = TextEditingController();
  final _niveauCtrl   = TextEditingController();
  final _dureeCtrl    = TextEditingController();
  final _paramsCtrl   = TextEditingController();
  final _cardioCtrl   = TextEditingController();

  // Titres et contenu des 5 jours
  final List<TextEditingController> _jourTitres  = List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> _jourContenus = List.generate(5, (_) => TextEditingController());

  bool _actif = true;
  bool _loading = false;

  static const _jourNames = ['Jour 1', 'Jour 2', 'Jour 3', 'Jour 4', 'Jour 5'];
  static const _jourColors = [
    Color(0xFF1565C0), Color(0xFF2E7D32), Color(0xFF6A1B9A),
    Color(0xFFBF360C), Color(0xFFE65100),
  ];

  static const _hintCardio =
    'Lundi | Vélo elliptique | 20 min | 55-65% FC max | Zone lipides\n'
    'Mardi | Marche rapide 6-6.5 km/h | 25 min | 50-60% FC | Drainage\n'
    'Mercredi | REPOS ACTIF | Marche 30 min | 40-50% FC | Anti-inflam.\n'
    'Jeudi | Elliptique | 30 min | 55-65% FC | Cardio abdomen\n'
    'Vendredi | Vélo doux | 20 min | 50-60% FC | Jambes + rétention\n'
    'Samedi | HIIT circuit | 20 min | 65-75% FC | Brûlage calorique\n'
    'Dimanche | REPOS COMPLET | Stretching + yoga | — | Récupération';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    final p = widget.prog;
    if (p != null) {
      _titreCtrl.text    = p['titre'] ?? '';
      _objectifCtrl.text = p['objectif'] ?? '';
      _nbJoursCtrl.text  = p['nb_jours'] != null ? '${p['nb_jours']}' : '';
      _niveauCtrl.text   = p['niveau'] ?? '';
      _dureeCtrl.text    = p['duree_seance'] != null ? '${p['duree_seance']}' : '';
      _paramsCtrl.text   = p['parametres'] ?? '';
      _cardioCtrl.text   = p['cardio_antiretion'] ?? '';
      _actif             = p['actif'] as bool? ?? true;
      for (int i = 0; i < 5; i++) {
        _jourTitres[i].text   = p['jour${i+1}_titre'] ?? '';
        _jourContenus[i].text = p['jour${i+1}_contenu'] ?? '';
      }
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _titreCtrl.dispose(); _objectifCtrl.dispose(); _nbJoursCtrl.dispose();
    _niveauCtrl.dispose(); _dureeCtrl.dispose(); _paramsCtrl.dispose(); _cardioCtrl.dispose();
    for (final c in [..._jourTitres, ..._jourContenus]) c.dispose();
    super.dispose();
  }

  // Ouvrir sélecteur d'exercices pour un jour
  Future<void> _ouvrirSelecteur(int jourIndex) async {
    // Extraire les exercices déjà dans ce jour
    final contenuActuel = _jourContenus[jourIndex].text;
    final existants = contenuActuel.split('\n')
        .where((l) => l.contains('|'))
        .map((l) => l.split('|')[0].trim())
        .toList();

    final selection = await showModalBottomSheet<List<String>>(
      context: context, isScrollControlled: true,
      backgroundColor: AppTheme.blanc,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => ExerciceSelectorSheet(selection: existants),
    );

    if (selection == null || selection.isEmpty) return;

    // Construire le contenu formaté
    final lignes = <String>[];
    // Garder le contenu existant non-sélectionné (manuel)
    for (final ligne in contenuActuel.split('\n')) {
      if (ligne.trim().isNotEmpty && !ligne.contains('|')) {
        lignes.add(ligne); // Lignes manuelles sans format
      }
    }

    // Ajouter les exercices sélectionnés
    for (final nom in selection) {
  lignes.add('$nom |  | 4×12 | 45 sec | Modérée');
}

    setState(() => _jourContenus[jourIndex].text = lignes.join('\n'));
  }

  Future<void> _sauvegarder() async {
    if (_titreCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final data = {
      'adherent_id': widget.adherentId,
      'titre': _titreCtrl.text.trim(),
      'objectif': _objectifCtrl.text.trim(),
      'niveau': _niveauCtrl.text.trim(),
      'parametres': _paramsCtrl.text.trim(),
      'actif': _actif,
      'cardio_antiretion': _cardioCtrl.text.trim(),
      for (int i = 0; i < 5; i++) ...{
        'jour${i+1}_titre': _jourTitres[i].text.trim(),
        'jour${i+1}_contenu': _jourContenus[i].text.trim(),
      },
      if (_nbJoursCtrl.text.isNotEmpty) 'nb_jours': int.tryParse(_nbJoursCtrl.text),
      if (_dureeCtrl.text.isNotEmpty) 'duree_seance': int.tryParse(_dureeCtrl.text),
      if (widget.prog == null) 'date_creation': DateTime.now().toIso8601String(),
    };
    if (widget.prog != null) {
      await DatabaseHelper.instance.modifierProgMusculation(widget.prog!['id'], data);
    } else {
      await DatabaseHelper.instance.ajouterProgMusculation(data);
    }
    setState(() => _loading = false);
    if (mounted) Navigator.pop(context, true);
  }

  Widget _f(TextEditingController c, String label, {int maxLines = 1, String? hint}) =>
    TextFormField(controller: c, maxLines: maxLines,
      keyboardType: maxLines > 1 ? TextInputType.multiline : TextInputType.text,
      decoration: InputDecoration(labelText: label, hintText: hint,
          alignLabelWithHint: maxLines > 1, hintStyle: const TextStyle(fontSize: 11)));

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.93,
      child: Column(children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.grisClair, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            const Text('Programme Musculation', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _sauvegarder,
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 38)),
              child: _loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Enregistrer'),
            ),
          ]),
        ),
        const SizedBox(height: 6),
        TabBar(
          controller: _tabCtrl, isScrollable: true,
          labelColor: AppTheme.orange, unselectedLabelColor: AppTheme.grisTexte,
          indicatorColor: AppTheme.orange, tabAlignment: TabAlignment.start,
          tabs: const [Tab(text: 'Général'), Tab(text: 'J1 + J2'), Tab(text: 'J3 + J4 + J5'), Tab(text: 'Cardio')],
        ),
        Expanded(
          child: TabBarView(controller: _tabCtrl, children: [
            // Tab Général
            SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
              _f(_titreCtrl, 'Titre *'),
              const SizedBox(height: 8),
              _f(_objectifCtrl, 'Objectif', maxLines: 2),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextFormField(controller: _nbJoursCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Jours/semaine'))),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: _dureeCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Durée séance (min)'))),
              ]),
              const SizedBox(height: 8),
              _f(_niveauCtrl, 'Niveau'),
              const SizedBox(height: 8),
              _f(_paramsCtrl, 'Paramètres généraux', maxLines: 5,
                  hint: 'Repos inter-séries: 45-60 sec\nProgression: +5% charge/semaine\nCardio anti-rétention: AVANT musculation...'),
              const SizedBox(height: 8),
              SwitchListTile(value: _actif, onChanged: (v) => setState(() => _actif = v),
                  title: const Text('Programme actif'), contentPadding: EdgeInsets.zero, activeColor: AppTheme.orange),
            ])),

            // Tab J1 + J2
            SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
              _JourBlock(index: 0, couleur: _jourColors[0], titreCtrl: _jourTitres[0],
                  contenuCtrl: _jourContenus[0], onSelecter: () => _ouvrirSelecteur(0)),
              _JourBlock(index: 1, couleur: _jourColors[1], titreCtrl: _jourTitres[1],
                  contenuCtrl: _jourContenus[1], onSelecter: () => _ouvrirSelecteur(1)),
            ])),

            // Tab J3 + J4 + J5
            SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
              _JourBlock(index: 2, couleur: _jourColors[2], titreCtrl: _jourTitres[2],
                  contenuCtrl: _jourContenus[2], onSelecter: () => _ouvrirSelecteur(2)),
              _JourBlock(index: 3, couleur: _jourColors[3], titreCtrl: _jourTitres[3],
                  contenuCtrl: _jourContenus[3], onSelecter: () => _ouvrirSelecteur(3)),
              _JourBlock(index: 4, couleur: _jourColors[4], titreCtrl: _jourTitres[4],
                  contenuCtrl: _jourContenus[4], onSelecter: () => _ouvrirSelecteur(4)),
            ])),

            // Tab Cardio
            SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
              Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF1565C0), borderRadius: BorderRadius.circular(8)),
                child: const Text('🏃 CARDIO ANTI-RÉTENTION — Programme Semaine Type',
                    style: TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w800, fontSize: 12)),
              ),
              const SizedBox(height: 8),
              TextFormField(controller: _cardioCtrl, maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Cardio (un jour par ligne)',
                  alignLabelWithHint: true,
                  hintText: 'Format: Jour | Type | Durée | Intensité FC | Zone/Objectif',
                  hintStyle: TextStyle(fontSize: 11),
                )),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF1565C0).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(_hintCardio,
                    style: const TextStyle(fontSize: 10, color: AppTheme.grisTexte, height: 1.6)),
              ),
            ])),
          ]),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}

class _JourBlock extends StatelessWidget {
  final int index;
  final Color couleur;
  final TextEditingController titreCtrl, contenuCtrl;
  final VoidCallback onSelecter;
  const _JourBlock({required this.index, required this.couleur,
      required this.titreCtrl, required this.contenuCtrl, required this.onSelecter});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(8)),
        child: Text('JOUR ${index + 1}',
            style: const TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w800, fontSize: 12)),
      ),
      const SizedBox(height: 6),
      TextFormField(controller: titreCtrl,
          decoration: const InputDecoration(labelText: 'Focus (ex: LUNDI — Fessiers + Quadriceps)')),
      const SizedBox(height: 6),

      // Bouton sélecteur bibliothèque
      OutlinedButton.icon(
        onPressed: onSelecter,
        icon: Icon(Icons.library_books_outlined, size: 16, color: couleur),
        label: Text('Choisir depuis la bibliothèque', style: TextStyle(color: couleur, fontSize: 13)),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 40),
          side: BorderSide(color: couleur.withOpacity(0.5)),
        ),
      ),
      const SizedBox(height: 6),

      // Zone texte manuelle
      TextFormField(
        controller: contenuCtrl,
        maxLines: 6,
        decoration: InputDecoration(
          labelText: 'Exercices (auto-rempli ou manuel)',
          alignLabelWithHint: true,
          hintText: 'Exercice | Description | Séries×Reps | Repos | Intensité',
          hintStyle: const TextStyle(fontSize: 11),
          suffixIcon: contenuCtrl.text.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear, size: 16),
                  onPressed: () => contenuCtrl.clear())
              : null,
        ),
      ),
      const SizedBox(height: 14),
    ]);
  }
}
