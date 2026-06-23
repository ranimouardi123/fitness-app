import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class TrackerScreen extends StatefulWidget {
  final int adherentId;
  const TrackerScreen({super.key, required this.adherentId});
  @override State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  Map<String, dynamic>? _adherent;
  List<Map<String, dynamic>> _trackings = [];

  // Valeurs de départ
  final _poidsDepart  = TextEditingController();
  final _mgDepart     = TextEditingController();
  final _gvDepart     = TextEditingController();
  final _scoreDepart  = TextEditingController();
  final _objPoids     = TextEditingController();
  final _objMg        = TextEditingController();

  // Objectifs progressifs par semaine
  final List<Map<String, TextEditingController>> _objSemaines = List.generate(12, (_) => {
    'calories':    TextEditingController(),
    'cardio':      TextEditingController(),
    'muscu':       TextEditingController(),
  });

  // Données hebdomadaires
  final List<Map<String, TextEditingController>> _semaines = List.generate(12, (_) => {
    'poids':       TextEditingController(),
    'tour_taille': TextEditingController(),
    'seances':     TextEditingController(),
    'eau':         TextEditingController(),
    'energie':     TextEditingController(),
  });

  bool _loading = false;
  bool _editMode = false;
  int _nbSemaines = 6;

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final a = await DatabaseHelper.instance.getAdherentParId(widget.adherentId);
    final t = await DatabaseHelper.instance.getTrackings(widget.adherentId);
    setState(() { _adherent = a; _trackings = t; });
    _remplirDepuisTrackings();
  }

  void _remplirDepuisTrackings() {
    // Chercher l'entrée "Départ" créée automatiquement depuis le bilan InBody
    final depart = _trackings.where((t) => t['semaine_label'] == 'Départ').toList();
    if (depart.isNotEmpty) {
      final d = depart.first;
      if (d['poids_depart'] != null && _poidsDepart.text.isEmpty)
        _poidsDepart.text = '${d['poids_depart']}';
      if (d['mg_depart'] != null && _mgDepart.text.isEmpty)
        _mgDepart.text = '${d['mg_depart']}';
      if (d['gv_depart'] != null && _gvDepart.text.isEmpty)
        _gvDepart.text = '${d['gv_depart']}';
      if (d['score_depart'] != null && _scoreDepart.text.isEmpty)
        _scoreDepart.text = '${d['score_depart']}';
      if (d['obj_poids'] != null && _objPoids.text.isEmpty)
        _objPoids.text = '${d['obj_poids']}';
      if (d['obj_mg'] != null && _objMg.text.isEmpty)
        _objMg.text = '${d['obj_mg']}';
    }
    // Remplir semaines depuis trackings existants
    _chargerDansControllers();
  }

  double? _d(TextEditingController c) => c.text.isNotEmpty ? double.tryParse(c.text) : null;

  Future<void> _sauvegarder() async {
    setState(() => _loading = true);
    for (int i = 0; i < _nbSemaines; i++) {
      final s = _semaines[i];
      final hasDonnees = s.values.any((c) => c.text.isNotEmpty);
      if (!hasDonnees) continue;
      final label = 'Semaine ${i + 1}';
      final existing = _trackings.where((t) => t['semaine_label'] == label).toList();
      final data = {
        'adherent_id':   widget.adherentId,
        'semaine_label': label,
        'date':          DateTime.now().toIso8601String().substring(0, 10),
        'notes':         label,
        if (s['poids']!.text.isNotEmpty)       'poids':        double.tryParse(s['poids']!.text),
        if (s['tour_taille']!.text.isNotEmpty) 'tour_taille':  double.tryParse(s['tour_taille']!.text),
        if (s['seances']!.text.isNotEmpty)     'seances_faites': int.tryParse(s['seances']!.text),
        if (s['eau']!.text.isNotEmpty)         'eau_jour':     double.tryParse(s['eau']!.text),
        if (s['energie']!.text.isNotEmpty)     'energie':      int.tryParse(s['energie']!.text),
        'poids_depart':  _d(_poidsDepart),
        'mg_depart':     _d(_mgDepart),
        'gv_depart':     _d(_gvDepart),
        'obj_poids':     _d(_objPoids),
        'obj_mg':        _d(_objMg),
        if (_objSemaines[i]['calories']!.text.isNotEmpty) 'calories_obj': _objSemaines[i]['calories']!.text,
        if (_objSemaines[i]['cardio']!.text.isNotEmpty)   'cardio_obj':   _objSemaines[i]['cardio']!.text,
        if (_objSemaines[i]['muscu']!.text.isNotEmpty)    'muscu_obj':    _objSemaines[i]['muscu']!.text,
      };
      if (existing.isNotEmpty) {
        await DatabaseHelper.instance.modifierTracking(existing.first['id'], data);
      } else {
        await DatabaseHelper.instance.ajouterTracking(data);
      }
    }
    setState(() { _loading = false; _editMode = false; });
    _charger();
  }

  void _chargerDansControllers() {
    for (int i = 0; i < _nbSemaines; i++) {
      final label = 'Semaine ${i + 1}';
      final existing = _trackings.where((t) => t['semaine_label'] == label).toList();
      if (existing.isNotEmpty) {
        final t = existing.first;
        if (t['poids'] != null)         _semaines[i]['poids']!.text       = '${t['poids']}';
        if (t['tour_taille'] != null)   _semaines[i]['tour_taille']!.text = '${t['tour_taille']}';
        if (t['seances_faites'] != null)_semaines[i]['seances']!.text     = '${t['seances_faites']}';
        if (t['eau_jour'] != null)      _semaines[i]['eau']!.text         = '${t['eau_jour']}';
        if (t['energie'] != null)       _semaines[i]['energie']!.text     = '${t['energie']}';
        if (t['calories_obj'] != null)  _objSemaines[i]['calories']!.text = '${t['calories_obj']}';
        if (t['cardio_obj'] != null)    _objSemaines[i]['cardio']!.text   = '${t['cardio_obj']}';
        if (t['muscu_obj'] != null)     _objSemaines[i]['muscu']!.text    = '${t['muscu_obj']}';
      }
    }
  }

  // Calculs automatiques
  double? get _poidsMin {
    final vals = _semaines.map((s) => double.tryParse(s['poids']!.text)).whereType<double>().toList();
    return vals.isNotEmpty ? vals.reduce((a, b) => a < b ? a : b) : null;
  }
  double? get _poidsMax {
    final vals = _semaines.map((s) => double.tryParse(s['poids']!.text)).whereType<double>().toList();
    return vals.isNotEmpty ? vals.reduce((a, b) => a > b ? a : b) : null;
  }
  double? get _variationTotale {
    final depart = double.tryParse(_poidsDepart.text);
    final dernierPoids = _semaines.reversed.map((s) => double.tryParse(s['poids']!.text)).whereType<double>().firstOrNull;
    if (depart == null || dernierPoids == null) return null;
    return dernierPoids - depart;
  }
  int get _seancesTotales =>
      _semaines.map((s) => int.tryParse(s['seances']!.text) ?? 0).fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final nom = _adherent != null ? '${_adherent!['prenom']} ${_adherent!['nom']}' : '';
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        title: Text('Tracker Hebdomadaire — $nom'),
        actions: [
          if (!_editMode)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () { _chargerDansControllers(); setState(() => _editMode = true); },
            )
          else
            TextButton(
              onPressed: _loading ? null : _sauvegarder,
              child: _loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.orange))
                  : const Text('Enregistrer', style: TextStyle(color: AppTheme.orange, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Header
          Container(
            width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.noir, Color(0xFF3A1F10)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Image.asset('assets/images/logo.png', height: 28, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: AppTheme.orange, size: 24)),
                const SizedBox(width: 10),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('TRACKER HEBDOMADAIRE', style: TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w800, fontSize: 13)),
                  Text('Remplir chaque matin à jeun · Semaine par semaine',
                      style: TextStyle(color: Colors.white54, fontSize: 10)),
                ])),
              ]),
              const SizedBox(height: 6),
              Text('Coach Ayoub — Coaching Sportif & Préparateur Physique',
                  style: TextStyle(color: AppTheme.orange.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(height: 16),

          // Nombre de semaines
          if (_editMode) ...[
            Row(children: [
              const Text('Nombre de semaines :', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              ...([4, 6, 8, 12].map((n) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('$n'),
                  selected: _nbSemaines == n,
                  selectedColor: AppTheme.orange,
                  labelStyle: TextStyle(color: _nbSemaines == n ? AppTheme.blanc : AppTheme.noir, fontWeight: FontWeight.w600),
                  onSelected: (_) => setState(() => _nbSemaines = n),
                ),
              ))),
            ]),
            const SizedBox(height: 16),
          ],

          // Valeurs de départ
          _SectionHeader(title: 'VALEURS DE DÉPART', couleur: AppTheme.orange),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: AppTheme.blanc, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE))),
            child: Column(children: [
              _ValRow('Poids', _poidsDepart, 'kg', editMode: _editMode),
              _Divider(),
              _ValRow('Masse Grasse', _mgDepart, 'kg', editMode: _editMode),
              _Divider(),
              _ValRow('Graisse Viscérale', _gvDepart, 'niveau', editMode: _editMode),
              _Divider(),
              _ValRow('Score InBody', _scoreDepart, '/100', editMode: _editMode),
              _Divider(),
              _ValRow('Objectif Poids', _objPoids, 'kg', editMode: _editMode, couleur: AppTheme.orange),
              _Divider(),
              _ValRow('Objectif MG', _objMg, 'kg', editMode: _editMode, couleur: AppTheme.orange),
            ]),
          ),
          const SizedBox(height: 16),

          // Suivi hebdomadaire
          _SectionHeader(title: 'SUIVI HEBDOMADAIRE — $_nbSemaines SEMAINES', couleur: const Color(0xFF1565C0)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: AppTheme.blanc, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE))),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(color: Color(0xFF1565C0),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                child: Row(children: const [
                  Expanded(flex: 2, child: Text('SEMAINE', style: TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w700, fontSize: 11))),
                  Expanded(flex: 2, child: Text('POIDS\n(kg)', style: TextStyle(color: AppTheme.blanc, fontSize: 10), textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text('TOUR\nTAILLE', style: TextStyle(color: AppTheme.blanc, fontSize: 10), textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text('SÉANCES\nFaites', style: TextStyle(color: AppTheme.blanc, fontSize: 10), textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text('EAU\n(L/j)', style: TextStyle(color: AppTheme.blanc, fontSize: 10), textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text('ÉNERGIE\n(1-10)', style: TextStyle(color: AppTheme.blanc, fontSize: 10), textAlign: TextAlign.center)),
                ]),
              ),
              ...List.generate(_nbSemaines, (i) {
                final isOrange = i % 2 == 0;
                return Container(
                  decoration: BoxDecoration(
                    color: isOrange ? AppTheme.orange.withOpacity(0.04) : AppTheme.blanc,
                    border: Border(bottom: BorderSide(color: const Color(0xFFEEEEEE))),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(children: [
                    Expanded(flex: 2, child: Text('S${i + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.orange, fontSize: 12))),
                    ...[_semaines[i]['poids']!, _semaines[i]['tour_taille']!, _semaines[i]['seances']!, _semaines[i]['eau']!, _semaines[i]['energie']!]
                        .map((ctrl) => Expanded(flex: 2, child: _editMode
                          ? TextFormField(controller: ctrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                border: OutlineInputBorder(), filled: true, fillColor: Colors.white,
                              ))
                          : Text(ctrl.text.isNotEmpty ? ctrl.text : '—',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: ctrl.text.isNotEmpty ? AppTheme.noir : AppTheme.grisTexte)))),
                  ]),
                );
              }),
            ]),
          ),
          const SizedBox(height: 16),

          // Objectifs progressifs
          _SectionHeader(title: 'OBJECTIFS PROGRESSIFS', couleur: const Color(0xFF2E7D32)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: AppTheme.blanc, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE))),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(color: Color(0xFF2E7D32),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                child: Row(children: const [
                  Expanded(flex: 1, child: Text('S.', style: TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w700, fontSize: 11))),
                  Expanded(flex: 3, child: Text('CALORIES/J', style: TextStyle(color: AppTheme.blanc, fontSize: 10))),
                  Expanded(flex: 3, child: Text('CARDIO', style: TextStyle(color: AppTheme.blanc, fontSize: 10))),
                  Expanded(flex: 3, child: Text('MUSCULATION', style: TextStyle(color: AppTheme.blanc, fontSize: 10))),
                ]),
              ),
              ...List.generate(_nbSemaines, (i) => Container(
                decoration: BoxDecoration(
                  color: i % 2 == 0 ? const Color(0xFF2E7D32).withOpacity(0.03) : AppTheme.blanc,
                  border: Border(bottom: BorderSide(color: const Color(0xFFEEEEEE))),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(children: [
                  Expanded(flex: 1, child: Text('S${i + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2E7D32), fontSize: 12))),
                  ...[_objSemaines[i]['calories']!, _objSemaines[i]['cardio']!, _objSemaines[i]['muscu']!]
                      .map((ctrl) => Expanded(flex: 3, child: _editMode
                        ? TextFormField(controller: ctrl,
                            keyboardType: TextInputType.text,
                            style: const TextStyle(fontSize: 11),
                            decoration: const InputDecoration(
                              isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                              border: OutlineInputBorder(), filled: true, fillColor: Colors.white,
                            ))
                        : Text(ctrl.text.isNotEmpty ? ctrl.text : '—',
                            style: TextStyle(fontSize: 11, color: ctrl.text.isNotEmpty ? AppTheme.noir : AppTheme.grisTexte)))),
                ]),
              )),
            ]),
          ),
          const SizedBox(height: 16),

          // Résumé automatique
          _SectionHeader(title: 'RÉSUMÉ AUTOMATIQUE', couleur: const Color(0xFF6A1B9A)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: AppTheme.blanc, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6A1B9A).withOpacity(0.2))),
            child: Column(children: [
              _ResumeRow('Poids min mesuré', _poidsMin != null ? '$_poidsMin kg' : '—', const Color(0xFF6A1B9A)),
              _Divider(),
              _ResumeRow('Poids max mesuré', _poidsMax != null ? '$_poidsMax kg' : '—', const Color(0xFF6A1B9A)),
              _Divider(),
              _ResumeRow('Variation totale',
                _variationTotale != null
                    ? '${_variationTotale! >= 0 ? '+' : ''}${_variationTotale!.toStringAsFixed(1)} kg'
                    : '—',
                _variationTotale != null && _variationTotale! < 0 ? Colors.green : Colors.red),
              _Divider(),
              _ResumeRow('Séances totales faites', '$_seancesTotales', AppTheme.orange),
            ]),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title; final Color couleur;
  const _SectionHeader({required this.title, required this.couleur});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(8)),
    child: Text(title, style: const TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5)),
  );
}

class _ValRow extends StatelessWidget {
  final String label; final TextEditingController ctrl; final String unite;
  final bool editMode; final Color? couleur;
  const _ValRow(this.label, this.ctrl, this.unite, {required this.editMode, this.couleur});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
      if (editMode)
        SizedBox(width: 100, child: TextFormField(controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          decoration: InputDecoration(suffixText: unite, isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
        ))
      else
        Text(ctrl.text.isNotEmpty ? '${ctrl.text} $unite' : '—',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: couleur ?? (ctrl.text.isNotEmpty ? AppTheme.orange : AppTheme.grisTexte))),
    ]),
  );
}

class _ResumeRow extends StatelessWidget {
  final String label, value; final Color couleur;
  const _ResumeRow(this.label, this.value, this.couleur);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: couleur)),
    ]),
  );
}

Widget _Divider() => const Divider(height: 1, indent: 14, endIndent: 14);
