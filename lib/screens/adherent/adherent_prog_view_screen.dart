// Écran lecture seule programme alimentaire / musculation / cardio pour adhérent
import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';
import '../coach/prog_simple_screen.dart';

class AdherentProgViewScreen extends StatefulWidget {
  final int programmeId;
  final TypeProg type;
  const AdherentProgViewScreen({super.key, required this.programmeId, required this.type});
  @override
  State<AdherentProgViewScreen> createState() => _AdherentProgViewScreenState();
}

class _AdherentProgViewScreenState extends State<AdherentProgViewScreen> {
  Map<String, dynamic>? _prog;

  String get _titre => switch (widget.type) {
    TypeProg.alimentaire => 'Mon programme alimentaire',
    TypeProg.musculation => 'Mon programme musculation',
    TypeProg.cardio      => 'Mon programme cardio',
  };

  Color get _couleur => switch (widget.type) {
    TypeProg.alimentaire => AppTheme.secondary,
    TypeProg.musculation => AppTheme.primary,
    TypeProg.cardio      => const Color(0xFFF59E0B),
  };

  IconData get _icon => switch (widget.type) {
    TypeProg.alimentaire => Icons.restaurant_outlined,
    TypeProg.musculation => Icons.fitness_center,
    TypeProg.cardio      => Icons.directions_run,
  };

  Future<Map<String, dynamic>?> _getProg() => switch (widget.type) {
    TypeProg.alimentaire => DatabaseHelper.instance.getProgAlimentaireParId(widget.programmeId),
    TypeProg.musculation => DatabaseHelper.instance.getProgMusculationParId(widget.programmeId),
    TypeProg.cardio      => DatabaseHelper.instance.getProgCardioParId(widget.programmeId),
  };

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final p = await _getProg();
    setState(() => _prog = p);
  }

  @override
  Widget build(BuildContext context) {
    final prog = _prog;
    return Scaffold(
      appBar: AppBar(title: Text(_titre)),
      body: prog == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Titre programme
                Row(children: [
                  Container(width: 48, height: 48,
                    decoration: BoxDecoration(color: _couleur.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(_icon, color: _couleur, size: 24)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(prog['titre'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (prog['description'] != null && (prog['description'] as String).isNotEmpty)
                      Text(prog['description'], style: TextStyle(fontSize: 13, color: _couleur)),
                  ])),
                ]),
                const SizedBox(height: 20),

                // Contenu
                if (prog['contenu'] != null && (prog['contenu'] as String).isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _couleur.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _couleur.withOpacity(0.15)),
                    ),
                    child: Text(prog['contenu'],
                        style: const TextStyle(fontSize: 15, height: 1.8, color: AppTheme.textPrimary)),
                  ),
                ] else ...[
                  Center(child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(children: [
                      Icon(_icon, size: 48, color: AppTheme.textSecondary.withOpacity(0.4)),
                      const SizedBox(height: 12),
                      const Text('Contenu en cours de préparation',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    ]),
                  )),
                ],
              ]),
            ),
    );
  }
}

