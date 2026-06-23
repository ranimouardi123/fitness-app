import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class BilanCorporelScreen extends StatefulWidget {
  final int adherentId;
  const BilanCorporelScreen({super.key, required this.adherentId});
  @override
  State<BilanCorporelScreen> createState() => _BilanCorporelScreenState();
}

class _BilanCorporelScreenState extends State<BilanCorporelScreen> {
  List<Map<String, dynamic>> _bilans = [];
  Map<String, dynamic>? _adherent;

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final a = await DatabaseHelper.instance.getAdherentParId(widget.adherentId);
    final b = await DatabaseHelper.instance.getBilansCorporels(widget.adherentId);
    setState(() { _adherent = a; _bilans = b; });
  }

  Future<void> _afficherFormulaire({Map<String, dynamic>? bilan}) async {
    final result = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true,
      backgroundColor: AppTheme.blanc,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _FormBilanInBody(adherentId: widget.adherentId, bilan: bilan),
    );
    if (result == true) _charger();
  }

  @override
  Widget build(BuildContext context) {
    final nom = _adherent != null ? '${_adherent!['prenom']} ${_adherent!['nom']}' : '';
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: Text('Bilan InBody — $nom')),
      body: _bilans.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 72, height: 72,
                decoration: BoxDecoration(color: AppTheme.orange.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.monitor_weight_outlined, size: 36, color: AppTheme.orange)),
              const SizedBox(height: 16),
              const Text('Aucun bilan InBody', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _afficherFormulaire(),
                icon: const Icon(Icons.add, size: 18), label: const Text('Ajouter bilan'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(180, 46)),
              ),
            ]))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.noir, Color(0xFF3A1F10)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    Image.asset('assets/images/logo.png', height: 36, fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: AppTheme.orange, size: 30)),
                    const SizedBox(width: 12),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('BILAN COMPOSITION CORPORELLE', style: TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w800, fontSize: 13)),
                      Text('InBody 270', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      SizedBox(height: 2),
                      Text('Coach Ayoub — Coaching Sportif & Préparateur Physique',
                          style: TextStyle(color: AppTheme.orange, fontSize: 10, fontWeight: FontWeight.w600)),
                    ])),
                  ]),
                ),
                const SizedBox(height: 16),
                if (_bilans.length >= 1) ...[_TableauComparatif(bilans: _bilans), const SizedBox(height: 16)],
                if (_bilans.length >= 2) ...[_ResultatsSemaines(bilans: _bilans), const SizedBox(height: 16)],
                if (_bilans.isNotEmpty && _bilans.first['obj_poids'] != null) ...[
                  _ObjectifsCibles(bilan: _bilans.first), const SizedBox(height: 16)],
                if (_bilans.isNotEmpty && _bilans.first['synthese'] != null &&
                    (_bilans.first['synthese'] as String).isNotEmpty) ...[
                  _SyntheseCoach(synthese: _bilans.first['synthese']), const SizedBox(height: 16)],
                const Text('Bilans enregistrés',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.grisTexte, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                ..._bilans.map((b) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: AppTheme.blanc, borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEEEEEE))),
                  child: Row(children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppTheme.orange),
                    const SizedBox(width: 8),
                    Text(b['date'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (b['poids'] != null) ...[
                      const SizedBox(width: 12),
                      Text('${b['poids']} kg', style: const TextStyle(color: AppTheme.grisTexte, fontSize: 13)),
                    ],
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
                        onPressed: () => _afficherFormulaire(bilan: b),
                        padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                    const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.danger),
                        onPressed: () async {
                          await DatabaseHelper.instance.supprimerBilanCorporel(b['id']);
                          _charger();
                        },
                        padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                  ]),
                )),
                const SizedBox(height: 80),
              ]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _afficherFormulaire(),
        icon: const Icon(Icons.add), label: const Text('Nouveau bilan'),
        backgroundColor: AppTheme.orange, foregroundColor: AppTheme.blanc,
      ),
    );
  }
}

class _TableauComparatif extends StatelessWidget {
  final List<Map<String, dynamic>> bilans;
  const _TableauComparatif({required this.bilans});
  static const _indicateurs = [
    {'key': 'poids',             'label': 'Poids (kg)'},
    {'key': 'imc',               'label': 'IMC (kg/m²)'},
    {'key': 'tgc',               'label': 'Graisse corporelle (%)'},
    {'key': 'masse_grasse_kg',   'label': 'Graisse corporelle (kg)'},
    {'key': 'graisse_viscerale', 'label': 'Graisse viscérale (Niv)'},
    {'key': 'mms',               'label': 'Masse musculaire (kg)'},
    {'key': 'mms_pct',           'label': 'Masse musculaire (%)'},
    {'key': 'masse_maigre',      'label': 'Masse maigre (kg)'},
    {'key': 'masse_osseuse',     'label': 'Masse osseuse (kg)'},
    {'key': 'hydratation',       'label': 'Taux d\'hydratation (%)'},
    {'key': 'metabolisme_base',  'label': 'Métabolisme de base (kcal)'},
    {'key': 'age_metabolique',   'label': 'Âge métabolique'},
  ];
  @override
  Widget build(BuildContext context) {
    final displayed = bilans.take(4).toList();
    return Container(
      decoration: BoxDecoration(color: AppTheme.blanc, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE))),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFF6A1B9A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
              children: [
                _HeaderCell('INDICATEUR', flex: true),
                ...displayed.map((b) => _HeaderCell(b['date'] ?? '')),
              ],
            ),
            ..._indicateurs.map((ind) {
              final vals = displayed.map((b) => b[ind['key']]).toList();
              if (!vals.any((v) => v != null)) return const TableRow(children: []);
              return TableRow(
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: const Color(0xFFEEEEEE)))),
                children: [
                  _LabelCell(ind['label']!),
                  ...vals.asMap().entries.map((e) {
                    final val = e.value;
                    final prev = e.key + 1 < vals.length ? vals[e.key + 1] : null;
                    Color? delta; String deltaStr = '';
                    if (val != null && prev != null) {
                      final d = (double.tryParse('$val') ?? 0) - (double.tryParse('$prev') ?? 0);
                      final musKeys = ['mms', 'mms_pct', 'masse_maigre', 'masse_osseuse', 'hydratation', 'metabolisme_base', 'score_inbody'];
                      final bon = musKeys.contains(ind['key']) ? d > 0 : d < 0;
                      delta = d == 0 ? AppTheme.grisTexte : (bon ? Colors.green : Colors.red);
                      deltaStr = '${d >= 0 ? '▲' : '▼'} ${d.abs().toStringAsFixed(1)}';
                    }
                    return _ValCell(val != null ? '$val' : '—', delta, deltaStr);
                  }),
                ],
              );
            }).where((row) => row.children.isNotEmpty).toList(),
          ],
        ),
      ),
    );
  }
}

Widget _HeaderCell(String text, {bool flex = false}) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  child: Text(text, style: const TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w700, fontSize: 12),
      textAlign: flex ? TextAlign.left : TextAlign.center),
);
Widget _LabelCell(String text) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.noir)),
);
Widget _ValCell(String val, Color? deltaColor, String deltaStr) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  child: Column(mainAxisSize: MainAxisSize.min, children: [
    Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.noir), textAlign: TextAlign.center),
    if (deltaColor != null && deltaStr.isNotEmpty)
      Text(deltaStr, style: TextStyle(fontSize: 10, color: deltaColor, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
  ]),
);

class _ResultatsSemaines extends StatelessWidget {
  final List<Map<String, dynamic>> bilans;
  const _ResultatsSemaines({required this.bilans});
  String _diff(Map<String, dynamic> a, Map<String, dynamic> b, String key, {String suffix = ''}) {
    final va = double.tryParse('${a[key]}'); final vb = double.tryParse('${b[key]}');
    if (va == null || vb == null) return '—';
    final d = va - vb;
    return '${d >= 0 ? '+' : ''}${d.toStringAsFixed(1)}$suffix';
  }
  @override
  Widget build(BuildContext context) {
    final dernier = bilans.first; final premier = bilans.last;
    final d1 = DateTime.tryParse(premier['date'] ?? ''); final d2 = DateTime.tryParse(dernier['date'] ?? '');
    String duree = '';
    if (d1 != null && d2 != null) {
      final jours = d2.difference(d1).inDays;
      duree = jours >= 7 ? 'EN ${(jours / 7).round()} SEMAINES' : 'EN $jours JOURS';
    }
    final resultats = [
      {'label': 'Poids perdu', 'key': 'poids', 'suffix': ' kg'},
      {'label': 'Graisse éliminée', 'key': 'masse_grasse_kg', 'suffix': ' kg'},
      {'label': 'Graisse viscérale', 'key': 'graisse_viscerale', 'suffix': ' niveaux'},
      {'label': 'IMC amélioré', 'key': 'imc', 'suffix': ' pts'},
      {'label': 'TGC réduit', 'key': 'tgc', 'suffix': '%'},
      {'label': 'Masse musculaire', 'key': 'mms', 'suffix': ' kg'},
    ];
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF00897B), borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🏆', style: TextStyle(fontSize: 20)), const SizedBox(width: 8),
          Text('RÉSULTATS $duree', style: const TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w800, fontSize: 14)),
        ]),
        const SizedBox(height: 4),
        Text('${premier['date']} → ${dernier['date']}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
        const SizedBox(height: 14),
        ...resultats.map((r) {
          final diff = _diff(dernier, premier, r['key'] as String, suffix: r['suffix'] as String? ?? '');
          if (diff == '—') return const SizedBox.shrink();
          return Padding(padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(child: Text(r['label'] as String, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13))),
              Text(diff, style: const TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.bold, fontSize: 18)),
            ]));
        }),
      ]),
    );
  }
}

class _ObjectifsCibles extends StatelessWidget {
  final Map<String, dynamic> bilan;
  const _ObjectifsCibles({required this.bilan});
  @override
  Widget build(BuildContext context) {
    final items = [
      {'label': 'Poids', 'key': 'obj_poids', 'actuel': 'poids', 'unite': 'kg'},
      {'label': 'Masse Grasse', 'key': 'obj_masse_grasse', 'actuel': 'masse_grasse_kg', 'unite': 'kg'},
      {'label': 'TGC', 'key': 'obj_tgc', 'actuel': 'tgc', 'unite': '%'},
      {'label': 'Graisse Viscérale', 'key': 'obj_graisse_viscerale', 'actuel': 'graisse_viscerale', 'unite': ''},
      {'label': 'IMC', 'key': 'obj_imc', 'actuel': 'imc', 'unite': ''},
    ];
    return Container(
      decoration: BoxDecoration(color: AppTheme.blanc, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(color: Color(0xFF2E7D32), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
          child: const Text('🎯 OBJECTIFS CIBLES — Coach Ayoub',
              style: TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w800, fontSize: 13))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(children: [
            const Expanded(flex: 3, child: Text('Indicateur', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.grisTexte))),
            const Expanded(flex: 2, child: Text('Actuel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.grisTexte), textAlign: TextAlign.center)),
            Expanded(flex: 2, child: Text('Cible', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green.shade700), textAlign: TextAlign.center)),
            const Expanded(flex: 2, child: Text('Écart', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.grisTexte), textAlign: TextAlign.center)),
          ])),
        const Divider(height: 1),
        ...items.where((item) => bilan[item['key']] != null).map((item) {
          final actuel = double.tryParse('${bilan[item['actuel']]}');
          final cible  = double.tryParse('${bilan[item['key']]}');
          String diff = '—'; Color diffColor = AppTheme.grisTexte;
          if (actuel != null && cible != null) {
            final d = cible - actuel;
            diff = '${d >= 0 ? '+' : ''}${d.toStringAsFixed(1)} ${item['unite']}';
            diffColor = d < 0 ? Colors.green : Colors.red;
          }
          return Column(children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(children: [
                Expanded(flex: 3, child: Text(item['label'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                Expanded(flex: 2, child: Text(actuel != null ? '$actuel ${item['unite']}' : '—',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text(cible != null ? '$cible ${item['unite']}' : '—',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.green.shade700), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text(diff,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: diffColor), textAlign: TextAlign.center)),
              ])),
            const Divider(height: 1),
          ]);
        }),
      ]),
    );
  }
}

class _SyntheseCoach extends StatelessWidget {
  final String synthese;
  const _SyntheseCoach({required this.synthese});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppTheme.orange.withOpacity(0.05), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.orange.withOpacity(0.25))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.auto_awesome, size: 16, color: AppTheme.orange), SizedBox(width: 6),
        Text('SYNTHÈSE & ANALYSE COACH', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.orange)),
      ]),
      const SizedBox(height: 10),
      Text(synthese, style: const TextStyle(fontSize: 13, height: 1.7, color: AppTheme.noir)),
    ]),
  );
}

class _FormBilanInBody extends StatefulWidget {
  final int adherentId;
  final Map<String, dynamic>? bilan;
  const _FormBilanInBody({required this.adherentId, this.bilan});
  @override State<_FormBilanInBody> createState() => _FormBilanInBodyState();
}

class _FormBilanInBodyState extends State<_FormBilanInBody> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _dateCtrl        = TextEditingController();
  final _tailleCtrl      = TextEditingController();
  final _ageCtrl         = TextEditingController();
  String _sexe           = 'Femme';
  final _poidsCtrl       = TextEditingController();
  final _mmsCtrl         = TextEditingController();
  final _mmsPctCtrl      = TextEditingController();
  final _masseMaigreCtrl = TextEditingController();
  final _masseOssCtrl    = TextEditingController();
  final _mgKgCtrl        = TextEditingController(); // Masse GRASSE kg
  final _eauCtrl         = TextEditingController();
  final _proteinesCtrl   = TextEditingController();
  final _minerauxCtrl    = TextEditingController();
  final _imcCtrl         = TextEditingController();
  final _tgcCtrl         = TextEditingController();
  final _hydraCtrl       = TextEditingController();
  final _rthCtrl         = TextEditingController();
  final _gvCtrl          = TextEditingController(); // Graisse viscérale
  final _scoreCtrl       = TextEditingController(); // Score InBody
  final _metaCtrl        = TextEditingController();
  final _ageMetaCtrl     = TextEditingController();
  final _gBrasDCtrl  = TextEditingController();
  final _gBrasGCtrl  = TextEditingController();
  final _gTroncCtrl  = TextEditingController();
  final _gJambeDCtrl = TextEditingController();
  final _gJambeGCtrl = TextEditingController();
  final _objPoidsCtrl = TextEditingController();
  final _objMgCtrl    = TextEditingController();
  final _objTgcCtrl   = TextEditingController();
  final _objGvCtrl    = TextEditingController();
  final _objImcCtrl   = TextEditingController();
  final _syntheseCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    final b = widget.bilan;
    if (b != null) {
      _dateCtrl.text        = b['date'] ?? '';
      _tailleCtrl.text      = b['taille'] != null ? '${b['taille']}' : '';
      _ageCtrl.text         = b['age'] != null ? '${b['age']}' : '';
      _sexe                 = b['sexe'] ?? 'Femme';
      _poidsCtrl.text       = b['poids'] != null ? '${b['poids']}' : '';
      _mmsCtrl.text         = b['mms'] != null ? '${b['mms']}' : '';
      _mmsPctCtrl.text      = b['mms_pct'] != null ? '${b['mms_pct']}' : '';
      _masseMaigreCtrl.text = b['masse_maigre'] != null ? '${b['masse_maigre']}' : '';
      _masseOssCtrl.text    = b['masse_osseuse'] != null ? '${b['masse_osseuse']}' : '';
      _mgKgCtrl.text        = b['masse_grasse_kg'] != null ? '${b['masse_grasse_kg']}' : '';
      _eauCtrl.text         = b['eau_corporelle'] != null ? '${b['eau_corporelle']}' : '';
      _proteinesCtrl.text   = b['proteines'] != null ? '${b['proteines']}' : '';
      _minerauxCtrl.text    = b['mineraux'] != null ? '${b['mineraux']}' : '';
      _imcCtrl.text         = b['imc'] != null ? '${b['imc']}' : '';
      _tgcCtrl.text         = b['tgc'] != null ? '${b['tgc']}' : '';
      _hydraCtrl.text       = b['hydratation'] != null ? '${b['hydratation']}' : '';
      _rthCtrl.text         = b['rapport_taille_hanche'] != null ? '${b['rapport_taille_hanche']}' : '';
      _gvCtrl.text          = b['graisse_viscerale'] != null ? '${b['graisse_viscerale']}' : '';
      _scoreCtrl.text       = b['score_inbody'] != null ? '${b['score_inbody']}' : '';
      _metaCtrl.text        = b['metabolisme_base'] != null ? '${b['metabolisme_base']}' : '';
      _ageMetaCtrl.text     = b['age_metabolique'] != null ? '${b['age_metabolique']}' : '';
      _gBrasDCtrl.text      = b['graisse_bras_d'] != null ? '${b['graisse_bras_d']}' : '';
      _gBrasGCtrl.text      = b['graisse_bras_g'] != null ? '${b['graisse_bras_g']}' : '';
      _gTroncCtrl.text      = b['graisse_tronc'] != null ? '${b['graisse_tronc']}' : '';
      _gJambeDCtrl.text     = b['graisse_jambe_d'] != null ? '${b['graisse_jambe_d']}' : '';
      _gJambeGCtrl.text     = b['graisse_jambe_g'] != null ? '${b['graisse_jambe_g']}' : '';
      _objPoidsCtrl.text    = b['obj_poids'] != null ? '${b['obj_poids']}' : '';
      _objMgCtrl.text       = b['obj_masse_grasse'] != null ? '${b['obj_masse_grasse']}' : '';
      _objTgcCtrl.text      = b['obj_tgc'] != null ? '${b['obj_tgc']}' : '';
      _objGvCtrl.text       = b['obj_graisse_viscerale'] != null ? '${b['obj_graisse_viscerale']}' : '';
      _objImcCtrl.text      = b['obj_imc'] != null ? '${b['obj_imc']}' : '';
      _syntheseCtrl.text    = b['synthese'] ?? '';
    } else {
      _dateCtrl.text = DateTime.now().toIso8601String().substring(0, 10);
    }
  }

  double? _d(TextEditingController c) => c.text.isNotEmpty ? double.tryParse(c.text) : null;
  int?    _i(TextEditingController c) => c.text.isNotEmpty ? int.tryParse(c.text) : null;

  Future<void> _sauvegarder() async {
    setState(() => _loading = true);
    final data = {
      'adherent_id': widget.adherentId,
      'date': _dateCtrl.text.trim(), 'sexe': _sexe,
      if (_tailleCtrl.text.isNotEmpty)      'taille':                _d(_tailleCtrl),
      if (_ageCtrl.text.isNotEmpty)         'age':                   _i(_ageCtrl),
      if (_poidsCtrl.text.isNotEmpty)       'poids':                 _d(_poidsCtrl),
      if (_mmsCtrl.text.isNotEmpty)         'mms':                   _d(_mmsCtrl),
      if (_mmsPctCtrl.text.isNotEmpty)      'mms_pct':               _d(_mmsPctCtrl),
      if (_masseMaigreCtrl.text.isNotEmpty) 'masse_maigre':          _d(_masseMaigreCtrl),
      if (_masseOssCtrl.text.isNotEmpty)    'masse_osseuse':         _d(_masseOssCtrl),
      if (_mgKgCtrl.text.isNotEmpty)        'masse_grasse_kg':       _d(_mgKgCtrl),
      if (_eauCtrl.text.isNotEmpty)         'eau_corporelle':        _d(_eauCtrl),
      if (_proteinesCtrl.text.isNotEmpty)   'proteines':             _d(_proteinesCtrl),
      if (_minerauxCtrl.text.isNotEmpty)    'mineraux':              _d(_minerauxCtrl),
      if (_imcCtrl.text.isNotEmpty)         'imc':                   _d(_imcCtrl),
      if (_tgcCtrl.text.isNotEmpty)         'tgc':                   _d(_tgcCtrl),
      if (_hydraCtrl.text.isNotEmpty)       'hydratation':           _d(_hydraCtrl),
      if (_rthCtrl.text.isNotEmpty)         'rapport_taille_hanche': _d(_rthCtrl),
      if (_gvCtrl.text.isNotEmpty)          'graisse_viscerale':     _d(_gvCtrl),
      if (_scoreCtrl.text.isNotEmpty)       'score_inbody':          _i(_scoreCtrl),
      if (_metaCtrl.text.isNotEmpty)        'metabolisme_base':      _i(_metaCtrl),
      if (_ageMetaCtrl.text.isNotEmpty)     'age_metabolique':       _i(_ageMetaCtrl),
      if (_gBrasDCtrl.text.isNotEmpty)      'graisse_bras_d':        _d(_gBrasDCtrl),
      if (_gBrasGCtrl.text.isNotEmpty)      'graisse_bras_g':        _d(_gBrasGCtrl),
      if (_gTroncCtrl.text.isNotEmpty)      'graisse_tronc':         _d(_gTroncCtrl),
      if (_gJambeDCtrl.text.isNotEmpty)     'graisse_jambe_d':       _d(_gJambeDCtrl),
      if (_gJambeGCtrl.text.isNotEmpty)     'graisse_jambe_g':       _d(_gJambeGCtrl),
      if (_objPoidsCtrl.text.isNotEmpty)    'obj_poids':             _d(_objPoidsCtrl),
      if (_objMgCtrl.text.isNotEmpty)       'obj_masse_grasse':      _d(_objMgCtrl),
      if (_objTgcCtrl.text.isNotEmpty)      'obj_tgc':               _d(_objTgcCtrl),
      if (_objGvCtrl.text.isNotEmpty)       'obj_graisse_viscerale': _d(_objGvCtrl),
      if (_objImcCtrl.text.isNotEmpty)      'obj_imc':               _d(_objImcCtrl),
      if (_syntheseCtrl.text.isNotEmpty)    'synthese':              _syntheseCtrl.text.trim(),
    };

    if (widget.bilan != null) {
      await DatabaseHelper.instance.modifierBilanCorporel(widget.bilan!['id'], data);
    } else {
      await DatabaseHelper.instance.ajouterBilanCorporel(data);
      // ── Tracking automatique depuis bilan InBody ──
      if (_poidsCtrl.text.isNotEmpty) {
        await DatabaseHelper.instance.ajouterTracking({
          'adherent_id':  widget.adherentId,
          'date':         _dateCtrl.text.trim(),
          'semaine_label':'Départ',
          'poids':        _d(_poidsCtrl),
          'poids_depart': _d(_poidsCtrl),
          'mg_depart':    _d(_mgKgCtrl),
          'gv_depart':    _d(_gvCtrl),
          'score_depart': _i(_scoreCtrl),
          'obj_poids':    _d(_objPoidsCtrl),
          'obj_mg':       _d(_objMgCtrl),
        });
      }
    }

    setState(() => _loading = false);
    if (mounted) Navigator.pop(context, true);
  }

  Widget _f(TextEditingController c, String label, {bool decimal = true, int maxLines = 1}) =>
    TextFormField(controller: c, maxLines: maxLines,
      keyboardType: maxLines > 1 ? TextInputType.multiline :
          (decimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number),
      decoration: InputDecoration(labelText: label));

  Widget _row2(Widget a, Widget b) => Row(children: [Expanded(child: a), const SizedBox(width: 8), Expanded(child: b)]);

  Widget _sectionTitle(String titre, Color couleur) => Container(
    width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(8)),
    child: Text(titre, style: const TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w700, fontSize: 13)),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.93,
      child: Column(children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.grisClair, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            const Text('Bilan InBody', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _sauvegarder,
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 38), backgroundColor: AppTheme.orange),
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
          tabs: const [Tab(text: 'Composition'), Tab(text: 'Morpho'), Tab(text: 'Objectifs'), Tab(text: 'Synthèse')],
        ),
        Expanded(
          child: TabBarView(controller: _tabCtrl, children: [
            // ── Tab 1 : Composition ──
            SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
              _f(_dateCtrl, 'Date *'),
              const SizedBox(height: 8),
              _row2(_f(_tailleCtrl, 'Taille (cm)'), _f(_ageCtrl, 'Âge', decimal: false)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(value: _sexe,
                items: ['Homme','Femme'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _sexe = v!),
                decoration: const InputDecoration(labelText: 'Sexe')),
              const SizedBox(height: 12),
              _sectionTitle('Composition corporelle', const Color(0xFF1565C0)),
              const SizedBox(height: 8),
              _row2(_f(_poidsCtrl, 'Poids (kg)'), _f(_mgKgCtrl, 'Masse grasse (kg)')),
              const SizedBox(height: 8),
              _row2(_f(_gvCtrl, 'Graisse viscérale (niveau)'), _f(_scoreCtrl, 'Score InBody (/100)', decimal: false)),
              const SizedBox(height: 8),
              _row2(_f(_mmsCtrl, 'Masse musculaire (kg)'), _f(_mmsPctCtrl, 'Masse musculaire (%)')),
              const SizedBox(height: 8),
              _row2(_f(_masseMaigreCtrl, 'Masse maigre (kg)'), _f(_masseOssCtrl, 'Masse osseuse (kg)')),
              const SizedBox(height: 8),
              _row2(_f(_eauCtrl, 'Eau corporelle (L)'), _f(_proteinesCtrl, 'Protéines (kg)')),
              const SizedBox(height: 8),
              _f(_minerauxCtrl, 'Minéraux (kg)'),
              const SizedBox(height: 12),
              _sectionTitle('🎯 Objectifs cibles', const Color(0xFF2E7D32)),
              const SizedBox(height: 8),
              _row2(_f(_objPoidsCtrl, 'Objectif poids (kg)'), _f(_objMgCtrl, 'Objectif MG (kg)')),
            ])),
            // ── Tab 2 : Morpho ──
            SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
              _sectionTitle('Bilan Morphologique', const Color(0xFF6A1B9A)),
              const SizedBox(height: 8),
              _row2(_f(_imcCtrl, 'IMC (kg/m²)'), _f(_tgcCtrl, 'Graisse corporelle (%)')),
              const SizedBox(height: 8),
              _row2(_f(_hydraCtrl, "Taux d'hydratation (%)"), _f(_metaCtrl, 'Métabolisme (kcal)', decimal: false)),
              const SizedBox(height: 8),
              _row2(_f(_rthCtrl, 'Rapport taille/hanche'), _f(_ageMetaCtrl, 'Âge métabolique', decimal: false)),
              const SizedBox(height: 12),
              _sectionTitle('Segments — Graisse (kg)', AppTheme.orange),
              const SizedBox(height: 8),
              _row2(_f(_gBrasDCtrl, 'Bras Droit'), _f(_gBrasGCtrl, 'Bras Gauche')),
              const SizedBox(height: 8),
              _f(_gTroncCtrl, 'Tronc'),
              const SizedBox(height: 8),
              _row2(_f(_gJambeDCtrl, 'Jambe Droite'), _f(_gJambeGCtrl, 'Jambe Gauche')),
            ])),
            // ── Tab 3 : Objectifs ──
            SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
              _sectionTitle('🎯 Objectifs Cibles — Coach Ayoub', const Color(0xFF2E7D32)),
              const SizedBox(height: 8),
              _row2(_f(_objPoidsCtrl, 'Poids cible (kg)'), _f(_objMgCtrl, 'Masse Grasse cible (kg)')),
              const SizedBox(height: 8),
              _row2(_f(_objTgcCtrl, 'TGC cible (%)'), _f(_objGvCtrl, 'Graisse Viscérale cible')),
              const SizedBox(height: 8),
              _f(_objImcCtrl, 'IMC cible'),
            ])),
            // ── Tab 4 : Synthèse ──
            SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
              _sectionTitle('📝 Synthèse & Analyse Coach', AppTheme.orange),
              const SizedBox(height: 8),
              TextFormField(controller: _syntheseCtrl, maxLines: 12,
                decoration: const InputDecoration(
                  labelText: 'Synthèse, analyse, priorités...',
                  alignLabelWithHint: true,
                  hintText: 'Ex:\n✅ Excellent progrès — Poids -3.8 kg | Masse Grasse -2.6 kg\n⚠️ Légère perte musculaire à compenser\n🔴 Priorité: Réduction graisse abdominale...',
                )),
            ])),
          ]),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}
