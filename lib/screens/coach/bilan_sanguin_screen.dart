import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

// Tous les marqueurs du bilan sanguin
const List<Map<String, dynamic>> _marqueurs = [
  // Numération Formule Sanguine
  {'key': 'globules_rouges',  'label': 'Globules rouges',  'unite': 'M/µL',  'normal': '4.2–5.4',  'section': 'NFS'},
  {'key': 'hemoglobine',      'label': 'Hémoglobine',      'unite': 'g/dL',  'normal': '12–16',    'section': 'NFS'},
  {'key': 'hematocrite',      'label': 'Hématocrite',      'unite': '%',     'normal': '37–47',    'section': 'NFS'},
  {'key': 'vgm',              'label': 'VGM',              'unite': 'fL',    'normal': '80–100',   'section': 'NFS'},
  {'key': 'ccmh',             'label': 'CCMH',             'unite': 'g/dL',  'normal': '32–36',    'section': 'NFS'},
  {'key': 'tgmh',             'label': 'TGMH',             'unite': 'pg',    'normal': '27–33',    'section': 'NFS'},
  {'key': 'globules_blancs',  'label': 'Globules blancs',  'unite': 'K/µL',  'normal': '4–10',     'section': 'NFS'},
  {'key': 'neutrophiles',     'label': 'Neutrophiles',     'unite': '%',     'normal': '50–70',    'section': 'NFS'},
  {'key': 'lymphocytes',      'label': 'Lymphocytes',      'unite': '%',     'normal': '20–40',    'section': 'NFS'},
  {'key': 'eosinophiles',     'label': 'Éosinophiles',     'unite': '%',     'normal': '1–4',      'section': 'NFS'},
  {'key': 'monocytes',        'label': 'Monocytes',        'unite': '%',     'normal': '2–8',      'section': 'NFS'},
  {'key': 'plaquettes',       'label': 'Plaquettes',       'unite': 'K/µL',  'normal': '150–400',  'section': 'NFS'},
  {'key': 'vs_1h',            'label': 'VS 1ère heure',    'unite': 'mm',    'normal': '<20',      'section': 'NFS'},
  {'key': 'vs_2h',            'label': 'VS 2ème heure',    'unite': 'mm',    'normal': '<40',      'section': 'NFS'},
  // Biochimie
  {'key': 'calcium',          'label': 'Calcium',          'unite': 'mg/L',  'normal': '85–105',   'section': 'Biochimie'},
  {'key': 'phosphore',        'label': 'Phosphore',        'unite': 'mg/L',  'normal': '25–45',    'section': 'Biochimie'},
  {'key': 'magnesium',        'label': 'Magnésium',        'unite': 'mg/L',  'normal': '18–25',    'section': 'Biochimie'},
  {'key': 'sodium',           'label': 'Sodium',           'unite': 'mEq/L', 'normal': '135–145',  'section': 'Biochimie'},
  {'key': 'potassium',        'label': 'Potassium',        'unite': 'mEq/L', 'normal': '3.5–5',    'section': 'Biochimie'},
  {'key': 'glycemie',         'label': 'Glycémie',         'unite': 'g/L',   'normal': '0.7–1.1',  'section': 'Biochimie'},
  {'key': 'uree',             'label': 'Urée',             'unite': 'g/L',   'normal': '0.15–0.45','section': 'Biochimie'},
  {'key': 'creatinine',       'label': 'Créatinine',       'unite': 'mg/L',  'normal': '6–13',     'section': 'Biochimie'},
  // Lipides
  {'key': 'cholesterol_total','label': 'Cholestérol total','unite': 'g/L',   'normal': '<2',       'section': 'Lipides'},
  {'key': 'hdl',              'label': 'HDL',              'unite': 'g/L',   'normal': '>0.45',    'section': 'Lipides'},
  {'key': 'ldl',              'label': 'LDL',              'unite': 'g/L',   'normal': '<1.6',     'section': 'Lipides'},
  {'key': 'triglycerides',    'label': 'Triglycérides',    'unite': 'g/L',   'normal': '<1.5',     'section': 'Lipides'},
  // Fer & Vitamines
  {'key': 'fer',              'label': 'Fer sérique',      'unite': 'µg/dL', 'normal': '50–170',   'section': 'Fer & Vitamines'},
  {'key': 'ferritine',        'label': 'Ferritine',        'unite': 'ng/mL', 'normal': '10–200',   'section': 'Fer & Vitamines'},
  {'key': 'transferrine',     'label': 'Transferrine',     'unite': 'g/L',   'normal': '2–3.6',    'section': 'Fer & Vitamines'},
  {'key': 'vitamine_d',       'label': 'Vitamine D',       'unite': 'ng/mL', 'normal': '30–100',   'section': 'Fer & Vitamines'},
  {'key': 'vitamine_b12',     'label': 'Vitamine B12',     'unite': 'pg/mL', 'normal': '200–900',  'section': 'Fer & Vitamines'},
  {'key': 'acide_folique',    'label': 'Acide folique',    'unite': 'ng/mL', 'normal': '>3',       'section': 'Fer & Vitamines'},
  // Hormones
  {'key': 'tsh',              'label': 'TSH',              'unite': 'mUI/L', 'normal': '0.4–4',    'section': 'Hormones'},
  {'key': 't3',               'label': 'T3 libre',         'unite': 'pg/mL', 'normal': '2.3–4.2',  'section': 'Hormones'},
  {'key': 't4',               'label': 'T4 libre',         'unite': 'ng/dL', 'normal': '0.8–1.8',  'section': 'Hormones'},
  {'key': 'cortisol',         'label': 'Cortisol',         'unite': 'µg/dL', 'normal': '5–25',     'section': 'Hormones'},
  {'key': 'insuline',         'label': 'Insuline',         'unite': 'µUI/mL','normal': '2–25',     'section': 'Hormones'},
  // Foie
  {'key': 'got',              'label': 'GOT (ASAT)',        'unite': 'UI/L',  'normal': '<40',      'section': 'Foie'},
  {'key': 'gpt',              'label': 'GPT (ALAT)',        'unite': 'UI/L',  'normal': '<40',      'section': 'Foie'},
  {'key': 'ggt',              'label': 'GGT',              'unite': 'UI/L',  'normal': '<50',      'section': 'Foie'},
  {'key': 'prot_totales',     'label': 'Protéines totales', 'unite': 'g/L',  'normal': '60–80',    'section': 'Foie'},
  // Inflammation
  {'key': 'crp',              'label': 'CRP',              'unite': 'mg/L',  'normal': '<6',       'section': 'Inflammation'},
  {'key': 'acide_urique',     'label': 'Acide urique',     'unite': 'mg/L',  'normal': '25–70',    'section': 'Inflammation'},
];

const Map<String, Color> _sectionColors = {
  'NFS':            Color(0xFF1565C0),
  'Biochimie':      Color(0xFF2E7D32),
  'Lipides':        Color(0xFFE65100),
  'Fer & Vitamines':Color(0xFF6A1B9A),
  'Hormones':       Color(0xFFC62828),
  'Foie':           Color(0xFF4E342E),
  'Inflammation':   Color(0xFF00695C),
};

class BilanSanguinScreen extends StatefulWidget {
  final int adherentId;
  const BilanSanguinScreen({super.key, required this.adherentId});
  @override State<BilanSanguinScreen> createState() => _BilanSanguinScreenState();
}

class _BilanSanguinScreenState extends State<BilanSanguinScreen> {
  List<Map<String, dynamic>> _bilans = [];
  Map<String, dynamic>? _adherent;

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final a = await DatabaseHelper.instance.getAdherentParId(widget.adherentId);
    final b = await DatabaseHelper.instance.getBilansSanguins(widget.adherentId);
    setState(() { _adherent = a; _bilans = b; });
  }

  Future<void> _afficherFormulaire({Map<String, dynamic>? bilan}) async {
    final result = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true,
      backgroundColor: AppTheme.blanc,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _FormBilanSanguin(adherentId: widget.adherentId, bilan: bilan),
    );
    if (result == true) _charger();
  }

  @override
  Widget build(BuildContext context) {
    final nom = _adherent != null ? '${_adherent!['prenom']} ${_adherent!['nom']}' : '';
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: Text('Bilan Sanguin — $nom')),
      body: _bilans.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 72, height: 72,
                decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.bloodtype_outlined, size: 36, color: AppTheme.danger)),
              const SizedBox(height: 16),
              const Text('Aucun bilan sanguin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text('Optionnel — à renseigner si nécessaire',
                  style: TextStyle(color: AppTheme.grisTexte, fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _afficherFormulaire(),
                icon: const Icon(Icons.add, size: 18), label: const Text('Ajouter bilan'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger, minimumSize: const Size(200, 46)),
              ),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bilans.length,
              itemBuilder: (ctx, i) => _BilanSanguinCard(
                bilan: _bilans[i],
                onModifier: () => _afficherFormulaire(bilan: _bilans[i]),
                onSupprimer: () async {
                  await DatabaseHelper.instance.supprimerBilanSanguin(_bilans[i]['id']);
                  _charger();
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _afficherFormulaire(),
        icon: const Icon(Icons.add), label: const Text('Nouveau bilan'),
        backgroundColor: AppTheme.danger, foregroundColor: AppTheme.blanc,
      ),
    );
  }
}

class _BilanSanguinCard extends StatefulWidget {
  final Map<String, dynamic> bilan;
  final VoidCallback onModifier, onSupprimer;
  const _BilanSanguinCard({required this.bilan, required this.onModifier, required this.onSupprimer});
  @override State<_BilanSanguinCard> createState() => _BilanSanguinCardState();
}

class _BilanSanguinCardState extends State<_BilanSanguinCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final b = widget.bilan;
    // Grouper par section
    final sections = <String, List<Map<String, dynamic>>>{};
    for (final m in _marqueurs) {
      final val = b[m['key']];
      if (val != null) {
        sections.putIfAbsent(m['section'], () => []).add({...m, 'valeur': val});
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppTheme.blanc, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFC62828), Color(0xFF7B1FA2)]),
              borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(16),
                  bottom: _expanded ? Radius.zero : const Radius.circular(16)),
            ),
            child: Row(children: [
              const Icon(Icons.bloodtype_outlined, color: AppTheme.blanc, size: 18),
              const SizedBox(width: 8),
              Text('Bilan Sanguin — ${b['date'] ?? ''}',
                  style: const TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.bold, fontSize: 15)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.blanc),
                  onPressed: widget.onModifier, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              const SizedBox(width: 6),
              IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white70),
                  onPressed: widget.onSupprimer, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              const SizedBox(width: 6),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppTheme.blanc, size: 20),
            ]),
          ),
        ),

        if (_expanded)
          Padding(
            padding: const EdgeInsets.all(14),
            child: sections.isEmpty
                ? const Text('Aucune valeur renseignée', style: TextStyle(color: AppTheme.grisTexte))
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: sections.entries.map((entry) {
                    final couleur = _sectionColors[entry.key] ?? AppTheme.grisTexte;
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(6)),
                        child: Text(entry.key, style: const TextStyle(color: AppTheme.blanc,
                            fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                      ...entry.value.map((m) => _MarqueurRow(marqueur: m)),
                      const SizedBox(height: 10),
                    ]);
                  }).toList()),
          ),

        if (_expanded && b['notes'] != null && (b['notes'] as String).isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.bgPage, borderRadius: BorderRadius.circular(8)),
            child: Text(b['notes'], style: const TextStyle(fontSize: 13, color: AppTheme.grisTexte, fontStyle: FontStyle.italic)),
          ),
      ]),
    );
  }
}

class _MarqueurRow extends StatelessWidget {
  final Map<String, dynamic> marqueur;
  const _MarqueurRow({required this.marqueur});
  @override
  Widget build(BuildContext context) {
    final couleur = _sectionColors[marqueur['section']] ?? AppTheme.grisTexte;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(flex: 3, child: Text(marqueur['label'],
            style: const TextStyle(fontSize: 13, color: AppTheme.noir))),
        Expanded(flex: 2, child: Text(marqueur['normal'] ?? '',
            style: const TextStyle(fontSize: 11, color: AppTheme.grisTexte))),
        Expanded(flex: 2, child: Text('${marqueur['valeur']} ${marqueur['unite']}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: couleur))),
      ]),
    );
  }
}

// ═══ FORMULAIRE BILAN SANGUIN COMPLET ═══
class _FormBilanSanguin extends StatefulWidget {
  final int adherentId; final Map<String, dynamic>? bilan;
  const _FormBilanSanguin({required this.adherentId, this.bilan});
  @override State<_FormBilanSanguin> createState() => _FormBilanSanguinState();
}

class _FormBilanSanguinState extends State<_FormBilanSanguin> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _dateCtrl  = TextEditingController();
  final _notesCtrl = TextEditingController();
  final Map<String, TextEditingController> _controllers = {};
  bool _loading = false;

  final List<String> _sections = ['NFS', 'Biochimie', 'Lipides', 'Fer & Vitamines', 'Hormones', 'Foie', 'Inflammation'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _sections.length, vsync: this);
    for (final m in _marqueurs) {
      _controllers[m['key']] = TextEditingController();
    }
    final b = widget.bilan;
    if (b != null) {
      _dateCtrl.text  = b['date'] ?? '';
      _notesCtrl.text = b['notes'] ?? '';
      for (final m in _marqueurs) {
        final val = b[m['key']];
        if (val != null) _controllers[m['key']]!.text = '$val';
      }
    } else {
      _dateCtrl.text = DateTime.now().toIso8601String().substring(0, 10);
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _dateCtrl.dispose(); _notesCtrl.dispose();
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _sauvegarder() async {
    setState(() => _loading = true);
    final data = <String, dynamic>{
      'adherent_id': widget.adherentId,
      'date': _dateCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
    };
    for (final m in _marqueurs) {
      final text = _controllers[m['key']]!.text.trim();
      if (text.isNotEmpty) data[m['key']] = double.tryParse(text) ?? text;
    }
    if (widget.bilan != null) {
      await DatabaseHelper.instance.modifierBilanSanguin(widget.bilan!['id'], data);
    } else {
      await DatabaseHelper.instance.ajouterBilanSanguin(data);
    }
    setState(() => _loading = false);
    if (mounted) Navigator.pop(context, true);
  }

  List<Map<String, dynamic>> _getSection(String section) =>
      _marqueurs.where((m) => m['section'] == section).toList();

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
            const Text('Bilan Sanguin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _sauvegarder,
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 38), backgroundColor: AppTheme.danger),
              child: _loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Enregistrer'),
            ),
          ]),
        ),
        const SizedBox(height: 6),
        // Date + Notes dans le premier tab
        TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelColor: AppTheme.danger,
          unselectedLabelColor: AppTheme.grisTexte,
          indicatorColor: AppTheme.danger,
          tabAlignment: TabAlignment.start,
          tabs: _sections.map((s) => Tab(text: s)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: _sections.map((section) {
              final marqueurs = _getSection(section);
              final couleur = _sectionColors[section] ?? AppTheme.danger;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (section == _sections[0]) ...[
                    TextFormField(controller: _dateCtrl,
                        decoration: const InputDecoration(labelText: 'Date *', prefixIcon: Icon(Icons.calendar_today))),
                    const SizedBox(height: 14),
                  ],
                  Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(8)),
                    child: Text(section, style: const TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 10),
                  ...marqueurs.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Expanded(flex: 3,
                        child: TextFormField(
                          controller: _controllers[m['key']],
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: m['label'],
                            suffixText: m['unite'],
                            helperText: 'Norme: ${m['normal']}',
                            helperStyle: const TextStyle(fontSize: 10, color: AppTheme.grisTexte),
                          ),
                        ),
                      ),
                    ]),
                  )),
                  if (section == _sections.last) ...[
                    const SizedBox(height: 10),
                    TextFormField(controller: _notesCtrl, maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Notes / Médecin / Commentaires')),
                  ],
                ]),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}
