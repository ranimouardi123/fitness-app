import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class AdherentTrackingScreen extends StatefulWidget {
  final int adherentId;
  const AdherentTrackingScreen({super.key, required this.adherentId});
  @override
  State<AdherentTrackingScreen> createState() => _AdherentTrackingScreenState();
}

class _AdherentTrackingScreenState extends State<AdherentTrackingScreen> {
  List<Map<String, dynamic>> _trackings = [];

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final t = await DatabaseHelper.instance.getTrackings(widget.adherentId);
    setState(() => _trackings = t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon historique de suivi')),
      body: _trackings.isEmpty
          ? const Center(child: Text('Aucune entrée de suivi.', style: TextStyle(color: AppTheme.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _trackings.length,
              itemBuilder: (ctx, i) {
                final t = _trackings[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Icon(Icons.calendar_today, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text(t['date'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        if (t['seance_faite'] == true) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: const Text('Séance faite ✓', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 6, children: [
                        if (t['poids'] != null)
                          _Tag(Icons.monitor_weight_outlined, '${t['poids']} kg', const Color(0xFF8B5CF6)),
                        if (t['tour_taille'] != null)
                          _Tag(Icons.straighten, '${t['tour_taille']} cm', Colors.purple),
                        if (t['energie'] != null)
                          _Tag(Icons.bolt, '${t['energie']}/10', Colors.orange),
                        if (t['sommeil'] != null)
                          _Tag(Icons.bedtime_outlined, '${t['sommeil']}h', Colors.indigo),
                        if (t['calories_mangees'] != null)
                          _Tag(Icons.local_fire_department_outlined, '${t['calories_mangees']} kcal', AppTheme.secondary),
                      ]),
                      if (t['notes'] != null && (t['notes'] as String).isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(t['notes'], style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontStyle: FontStyle.italic)),
                      ],
                    ]),
                  ),
                );
              },
            ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon; final String value; final Color couleur;
  const _Tag(this.icon, this.value, this.couleur);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(color: couleur.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: couleur),
      const SizedBox(width: 4),
      Text(value, style: TextStyle(fontSize: 12, color: couleur, fontWeight: FontWeight.w500)),
    ]),
  );
}
