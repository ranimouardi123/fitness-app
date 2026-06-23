import 'package:flutter/material.dart';
import '../../services/database_helper.dart';
import '../../app_theme.dart';

class SuiviMensuelScreen extends StatefulWidget {
  final int adherentId;
  const SuiviMensuelScreen({super.key, required this.adherentId});
  @override State<SuiviMensuelScreen> createState() => _SuiviMensuelScreenState();
}

class _SuiviMensuelScreenState extends State<SuiviMensuelScreen> {
  List<Map<String, dynamic>> _bilans = [];
  Map<String, dynamic>? _adherent;

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final a = await DatabaseHelper.instance.getAdherentParId(widget.adherentId);
    final b = await DatabaseHelper.instance.getBilansCorporels(widget.adherentId);
    setState(() { _adherent = a; _bilans = b; });
  }

  @override
  Widget build(BuildContext context) {
    final nom = _adherent != null ? '${_adherent!['prenom']} ${_adherent!['nom']}' : '';
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(title: Text('Suivi Mensuel — $nom')),
      body: _bilans.length < 2
          ? Center(child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 72, height: 72,
                  decoration: BoxDecoration(color: AppTheme.orange.withOpacity(0.08), shape: BoxShape.circle),
                  child: const Icon(Icons.trending_up, size: 36, color: AppTheme.orange)),
                const SizedBox(height: 16),
                const Text('Minimum 2 bilans requis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('Le tableau comparatif apparaîtra dès que vous aurez enregistré au moins 2 bilans InBody.',
                    textAlign: TextAlign.center, style: TextStyle(color: AppTheme.grisTexte, fontSize: 13)),
              ]),
            ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Tableau de bord évolution
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.noir, Color(0xFF3A1F10)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Image.asset('assets/images/logo.png', height: 28, fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: AppTheme.orange)),
                      const SizedBox(width: 10),
                      const Expanded(child: Text('TABLEAU DE SUIVI MENSUEL',
                          style: TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5))),
                    ]),
                    const SizedBox(height: 4),
                    Text('Objectifs & Progression', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  ]),
                ),
                const SizedBox(height: 16),

                // Tableau comparatif
                Container(
                  decoration: BoxDecoration(color: AppTheme.blanc, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEEEEE))),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppTheme.noir),
                      columns: [
                        const DataColumn(label: Text('Indicateur', style: TextStyle(color: AppTheme.blanc, fontWeight: FontWeight.w700))),
                        ..._bilans.take(6).map((b) => DataColumn(
                          label: Text(b['date'] ?? '', style: const TextStyle(color: AppTheme.orange, fontWeight: FontWeight.w600, fontSize: 12)),
                        )),
                      ],
                      rows: _buildRows(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Graphique évolution poids
                if (_bilans.any((b) => b['poids'] != null)) ...[
                  const Text('Évolution du poids', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Container(
                    height: 160,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppTheme.blanc, borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEEEEEE))),
                    child: _PoidsChart(bilans: _bilans.reversed.toList()),
                  ),
                  const SizedBox(height: 16),
                ],

                // Résumé progression
                _ResumeProg(bilans: _bilans),
              ]),
            ),
    );
  }

  List<DataRow> _buildRows() {
    final indicateurs = [
      ['Poids (kg)', 'poids'],
      ['Masse Grasse (kg)', 'masse_grasse_kg'],
      ['TGC (%)', 'tgc'],
      ['MMS Muscle (kg)', 'mms'],
      ['Graisse Viscérale', 'graisse_viscerale'],
      ['IMC', 'imc'],
      ['Score InBody', 'score_inbody'],
      ['Eau Corporelle (L)', 'eau_corporelle'],
    ];
    return indicateurs.map((ind) {
      final vals = _bilans.take(6).map((b) => b[ind[1]]).toList();
      return DataRow(cells: [
        DataCell(Text(ind[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        ...vals.asMap().entries.map((e) {
          final val = e.value;
          final prev = e.key + 1 < vals.length ? vals[e.key + 1] : null;
          Color? color;
          if (val != null && prev != null) {
            final diff = (double.tryParse('$val') ?? 0) - (double.tryParse('$prev') ?? 0);
            color = diff < 0 ? Colors.green : (diff > 0 ? Colors.red : null);
          }
          return DataCell(Text(val != null ? '$val' : '—',
              style: TextStyle(fontSize: 12, color: color, fontWeight: color != null ? FontWeight.bold : null)));
        }),
      ]);
    }).toList();
  }
}

class _PoidsChart extends StatelessWidget {
  final List<Map<String, dynamic>> bilans;
  const _PoidsChart({required this.bilans});

  @override
  Widget build(BuildContext context) {
    final data = bilans.where((b) => b['poids'] != null).toList();
    if (data.isEmpty) return const SizedBox.shrink();
    final poids = data.map((b) => double.tryParse('${b['poids']}') ?? 0).toList();
    final minP = poids.reduce((a, b) => a < b ? a : b) - 2;
    final maxP = poids.reduce((a, b) => a > b ? a : b) + 2;

    return CustomPaint(
      size: const Size(double.infinity, 128),
      painter: _LineChartPainter(values: poids, min: minP, max: maxP,
          labels: data.map((b) => (b['date'] as String? ?? '').substring(0, 5)).toList()),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final double min, max;
  final List<String> labels;
  const _LineChartPainter({required this.values, required this.min, required this.max, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final linePaint = Paint()..color = AppTheme.orange..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final dotPaint  = Paint()..color = AppTheme.orange..style = PaintingStyle.fill;
    final gridPaint = Paint()..color = const Color(0xFFEEEEEE)..strokeWidth = 1;

    // Grille
    for (int i = 0; i <= 4; i++) {
      final y = size.height * 0.85 * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    double x(int i) => i * (size.width / (values.length - 1));
    double y(double v) => size.height * 0.85 * (1 - (v - min) / (max - min));

    final path = Path()..moveTo(x(0), y(values[0]));
    for (int i = 1; i < values.length; i++) path.lineTo(x(i), y(values[i]));
    canvas.drawPath(path, linePaint);

    for (int i = 0; i < values.length; i++) {
      canvas.drawCircle(Offset(x(i), y(values[i])), 4, dotPaint);
      final tp = TextPainter(
        text: TextSpan(text: '${values[i]}', style: const TextStyle(fontSize: 10, color: AppTheme.noir, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x(i) - tp.width / 2, y(values[i]) - 16));
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

class _ResumeProg extends StatelessWidget {
  final List<Map<String, dynamic>> bilans;
  const _ResumeProg({required this.bilans});

  @override
  Widget build(BuildContext context) {
    if (bilans.length < 2) return const SizedBox.shrink();
    final dernier  = bilans[0];
    final premier  = bilans[bilans.length - 1];

    Widget diff(String label, String? key, {bool inverser = false}) {
      final a = double.tryParse('${dernier[key]}');
      final b = double.tryParse('${premier[key]}');
      if (a == null || b == null) return const SizedBox.shrink();
      final delta = a - b;
      final bon = inverser ? delta > 0 : delta < 0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Icon(bon ? Icons.arrow_downward : Icons.arrow_upward, size: 16,
              color: bon ? Colors.green : Colors.red),
          const SizedBox(width: 6),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text('${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: bon ? Colors.green : Colors.red)),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.orange.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.auto_awesome, size: 16, color: AppTheme.orange),
          SizedBox(width: 6),
          Text('PROGRESSION TOTALE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
              color: AppTheme.orange, letterSpacing: 1)),
        ]),
        Text('${premier['date']} → ${dernier['date']}',
            style: const TextStyle(fontSize: 11, color: AppTheme.grisTexte)),
        const SizedBox(height: 12),
        diff('Poids (kg)', 'poids'),
        diff('Masse Grasse (kg)', 'masse_grasse_kg'),
        diff('TGC (%)', 'tgc'),
        diff('MMS Muscle (kg)', 'mms', inverser: true),
        diff('Graisse Viscérale', 'graisse_viscerale'),
        diff('IMC', 'imc'),
        diff('Score InBody', 'score_inbody', inverser: true),
      ]),
    );
  }
}
