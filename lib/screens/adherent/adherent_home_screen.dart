import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class AdherentHomeScreen extends StatefulWidget {
  const AdherentHomeScreen({super.key});
  @override
  State<AdherentHomeScreen> createState() => _AdherentHomeScreenState();
}

class _AdherentHomeScreenState extends State<AdherentHomeScreen> {
  String _nom = '';
  int? _userId;
  Map<String, dynamic>? _progAlimentaire;
  Map<String, dynamic>? _progMusculation;
  Map<String, dynamic>? _progCardio;
  Map<String, dynamic>? _dernierTracking;
  int _nbTrackings = 0;

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final auth = AuthService();
    final id   = await auth.getUserId();
    final nom  = await auth.getNomComplet();
    final db   = DatabaseHelper.instance;
    final pa = id != null ? await db.getProgAlimentaireActif(id) : null;
    final pm = id != null ? await db.getProgMusculationActif(id) : null;
    final pc = id != null ? await db.getProgCardioActif(id) : null;
    final tr = id != null ? await db.getTrackings(id) : <Map<String, dynamic>>[];
    setState(() {
      _userId = id; _nom = nom;
      _progAlimentaire = pa; _progMusculation = pm; _progCardio = pc;
      _dernierTracking = tr.isNotEmpty ? tr.first : null;
      _nbTrackings = tr.length;
    });
  }

  Future<void> _ajouterTracking() async {
    final result = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true,
      backgroundColor: AppTheme.blanc,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _FormTrackingAdherent(adherentId: _userId!),
    );
    if (result == true) _charger();
  }

  @override
  Widget build(BuildContext context) {
    final initiales = _nom.isNotEmpty
        ? _nom.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: RefreshIndicator(
        color: AppTheme.orange,
        onRefresh: _charger,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: AppTheme.noir,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: AppTheme.blanc),
                  onPressed: () async { await AuthService().deconnexion(); if (mounted) context.go('/login'); },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.noir, Color(0xFF3A1F10)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                        Row(children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppTheme.orange, AppTheme.orangeDark]),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(child: Text(initiales,
                                style: const TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.bold, fontSize: 18))),
                          ),
                          const SizedBox(width: 14),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Bienvenue,', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                            Text(_nom, style: const TextStyle(color: AppTheme.blanc, fontSize: 18, fontWeight: FontWeight.bold)),
                          ]),
                        ]),
                        const SizedBox(height: 16),
                        // Mini stats tracking
                        Row(children: [
                          _MiniStat(valeur: '$_nbTrackings', label: 'Entrées suivi'),
                          const SizedBox(width: 10),
                          if (_dernierTracking?['poids'] != null)
                            _MiniStat(valeur: '${_dernierTracking!['poids']} kg', label: 'Dernier poids'),
                        ]),
                      ]),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // Tracking rapide
                  if (_userId != null) ...[
                    _SectionLabel(label: 'MON SUIVI'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.blanc,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(children: [
                        Row(children: [
                          Container(width: 40, height: 40,
                            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.show_chart, color: Color(0xFF8B5CF6), size: 20)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('$_nbTrackings entrée${_nbTrackings > 1 ? 's' : ''} enregistrées',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.noir)),
                            if (_dernierTracking != null)
                              Text('Dernière entrée : ${_dernierTracking!['date']}',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.grisTexte)),
                          ])),
                          TextButton(
                            onPressed: () => context.push('/adherent/tracking/$_userId'),
                            child: const Text('Historique', style: TextStyle(color: AppTheme.orange, fontSize: 12)),
                          ),
                        ]),
                        if (_dernierTracking != null) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Wrap(spacing: 8, runSpacing: 6, children: [
                            if (_dernierTracking!['poids'] != null)
                              _MiniTag(Icons.monitor_weight_outlined, '${_dernierTracking!['poids']} kg', const Color(0xFF8B5CF6)),
                            if (_dernierTracking!['energie'] != null)
                              _MiniTag(Icons.bolt, '${_dernierTracking!['energie']}/10', Colors.orange),
                            if (_dernierTracking!['sommeil'] != null)
                              _MiniTag(Icons.bedtime_outlined, '${_dernierTracking!['sommeil']}h', Colors.indigo),
                            if (_dernierTracking!['seance_faite'] == true)
                              _MiniTag(Icons.check_circle_outline, 'Séance faite', Colors.green),
                          ]),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _ajouterTracking,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text("Ajouter suivi d'aujourd'hui"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6),
                              minimumSize: const Size(0, 44),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Programmes
                  _SectionLabel(label: 'MES PROGRAMMES'),
                  const SizedBox(height: 10),
                  _ProgCard(
                    titre: 'Programme alimentaire', prog: _progAlimentaire,
                    icon: Icons.restaurant_outlined, couleur: const Color(0xFF4CAF50),
                    onTap: _progAlimentaire != null
                        ? () => context.push('/adherent/prog-alimentaire/${_progAlimentaire!['id']}') : null,
                  ),
                  const SizedBox(height: 10),
                  _ProgCard(
                    titre: 'Programme musculation', prog: _progMusculation,
                    icon: Icons.fitness_center, couleur: AppTheme.orange,
                    onTap: _progMusculation != null
                        ? () => context.push('/adherent/prog-musculation/${_progMusculation!['id']}') : null,
                  ),
                  const SizedBox(height: 10),
                  _ProgCard(
                    titre: 'Programme cardio', prog: _progCardio,
                    icon: Icons.directions_run, couleur: const Color(0xFFFFC107),
                    onTap: _progCardio != null
                        ? () => context.push('/adherent/prog-cardio/${_progCardio!['id']}') : null,
                  ),
                  const SizedBox(height: 10),
_ProgCard(
  titre: 'Messagerie', prog: const {'titre': 'Coach Ayoub'},
  icon: Icons.chat_bubble_outline, couleur: const Color(0xFF00897B),
  onTap: () => context.push('/adherent/chat'),
),
const SizedBox(height: 10),

                  if (_progAlimentaire == null && _progMusculation == null && _progCardio == null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.orange.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.orange.withOpacity(0.15)),
                      ),
                      child: const Row(children: [
                        Icon(Icons.hourglass_empty, color: AppTheme.orange, size: 28),
                        SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Programmes en préparation', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.noir)),
                          SizedBox(height: 2),
                          Text('Votre coach vous assignera bientôt vos programmes.',
                              style: TextStyle(fontSize: 12, color: AppTheme.grisTexte)),
                        ])),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.grisTexte, letterSpacing: 1.5));
}

class _MiniStat extends StatelessWidget {
  final String valeur, label;
  const _MiniStat({required this.valeur, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(valeur, style: const TextStyle(color: AppTheme.orange, fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11)),
    ]),
  );
}

class _MiniTag extends StatelessWidget {
  final IconData icon; final String value; final Color couleur;
  const _MiniTag(this.icon, this.value, this.couleur);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(color: couleur.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: couleur),
      const SizedBox(width: 4),
      Text(value, style: TextStyle(fontSize: 11, color: couleur, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _ProgCard extends StatelessWidget {
  final String titre;
  final Map<String, dynamic>? prog;
  final IconData icon;
  final Color couleur;
  final VoidCallback? onTap;
  const _ProgCard({required this.titre, required this.icon, required this.couleur, this.prog, this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasProg = prog != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.blanc,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: hasProg ? couleur.withOpacity(0.2) : const Color(0xFFEEEEEE)),
        ),
        child: Row(children: [
          Container(width: 46, height: 46,
            decoration: BoxDecoration(color: couleur.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: couleur, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titre, style: const TextStyle(fontSize: 11, color: AppTheme.grisTexte)),
            const SizedBox(height: 2),
            Text(hasProg ? prog!['titre'] : 'Pas encore assigné',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: hasProg ? AppTheme.noir : AppTheme.grisTexte)),
            if (hasProg && prog!['description'] != null && (prog!['description'] as String).isNotEmpty)
              Text(prog!['description'], style: TextStyle(fontSize: 11, color: couleur),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          if (hasProg)
            Container(padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: couleur.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.arrow_forward_ios, size: 12, color: couleur)),
        ]),
      ),
    );
  }
}

class _FormTrackingAdherent extends StatefulWidget {
  final int adherentId;
  const _FormTrackingAdherent({required this.adherentId});
  @override State<_FormTrackingAdherent> createState() => _FormTrackingAdherentState();
}
class _FormTrackingAdherentState extends State<_FormTrackingAdherent> {
  final _poidsCtrl   = TextEditingController();
  final _tailleCtrl  = TextEditingController();
  final _energieCtrl = TextEditingController();
  final _sommeilCtrl = TextEditingController();
  final _calCtrl     = TextEditingController();
  final _notesCtrl   = TextEditingController();
  bool _seanceFaite  = false;
  bool _loading      = false;

  Future<void> _sauvegarder() async {
    setState(() => _loading = true);
    await DatabaseHelper.instance.ajouterTracking({
      'adherent_id': widget.adherentId,
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'seance_faite': _seanceFaite, 'notes': _notesCtrl.text.trim(),
      if (_poidsCtrl.text.isNotEmpty)   'poids':           double.tryParse(_poidsCtrl.text),
      if (_tailleCtrl.text.isNotEmpty)  'tour_taille':     double.tryParse(_tailleCtrl.text),
      if (_energieCtrl.text.isNotEmpty) 'energie':         int.tryParse(_energieCtrl.text),
      if (_sommeilCtrl.text.isNotEmpty) 'sommeil':         double.tryParse(_sommeilCtrl.text),
      if (_calCtrl.text.isNotEmpty)     'calories_mangees': int.tryParse(_calCtrl.text),
    });
    setState(() => _loading = false);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 24),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
          decoration: BoxDecoration(color: AppTheme.grisClair, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Row(children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.show_chart, color: Color(0xFF8B5CF6), size: 18)),
          const SizedBox(width: 10),
          const Text("Suivi d'aujourd'hui", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.noir)),
          const Spacer(),
          Text(DateTime.now().toIso8601String().substring(0, 10),
              style: const TextStyle(color: AppTheme.grisTexte, fontSize: 12)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: TextFormField(controller: _poidsCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Poids (kg)'))),
          const SizedBox(width: 8),
          Expanded(child: TextFormField(controller: _tailleCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Tour taille (cm)'))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextFormField(controller: _energieCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Énergie (1-10)'))),
          const SizedBox(width: 8),
          Expanded(child: TextFormField(controller: _sommeilCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Sommeil (h)'))),
        ]),
        const SizedBox(height: 8),
        TextFormField(controller: _calCtrl, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Calories mangées')),
        const SizedBox(height: 4),
        SwitchListTile(value: _seanceFaite, onChanged: (v) => setState(() => _seanceFaite = v),
            title: const Text("Séance réalisée aujourd'hui"), contentPadding: EdgeInsets.zero,
            activeColor: Colors.green),
        TextFormField(controller: _notesCtrl, decoration: const InputDecoration(labelText: 'Notes / Ressenti')),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loading ? null : _sauvegarder,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
          child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : const Text('Enregistrer mon suivi'),
        ),
        const SizedBox(height: 16),
      ])),
    );
  }
}
