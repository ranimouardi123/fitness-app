import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../app_theme.dart';
import '../../services/database_helper.dart';

class CoachAIScreen extends StatefulWidget {
  const CoachAIScreen({super.key});
  @override
  State<CoachAIScreen> createState() => _CoachAIScreenState();
}

class _CoachAIScreenState extends State<CoachAIScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  // Mode génération programme
  String? _modeGeneration; // 'musculation' ou 'nutrition'
  int? _adherentIdSelectionne;
  String? _nomAdherentSelectionne;
  List<Map<String, dynamic>> _adherents = [];

  static const _groqKey = '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';

  static const _systemPrompt = '''Tu es un assistant expert en coaching sportif et nutrition pour Coach Ayoub - AM Coaching Sportif & Préparateur Physique.

Tu aides le coach à :
- Créer des programmes de musculation personnalisés
- Élaborer des programmes alimentaires adaptés (calories, macros, planning)
- Analyser les bilans InBody et sanguin
- Donner des conseils sur la perte de poids, prise de masse, sèche
- Répondre aux questions sur les exercices, séries, répétitions, repos
- Proposer des stratégies anti-rétention d\'eau
- Conseiller sur les suppléments et la récupération

Réponds toujours en français, de manière professionnelle et concise.
Utilise des emojis pour rendre les réponses plus lisibles.
Structure tes réponses avec des sections claires.''';

  static const _systemMusculationJSON = '''Tu es un expert en musculation. Tu dois générer un programme de musculation en JSON UNIQUEMENT.
Réponds UNIQUEMENT avec ce JSON, sans texte avant ou après :
{
  "titre": "Programme Musculation [objectif]",
  "objectif": "[objectif détaillé]",
  "nb_jours": 5,
  "duree_seance": 60,
  "niveau": "Intermédiaire",
  "parametres": "Repos inter-séries: 45-60 sec\\nProgression: +5% charge/semaine",
  "jour1_titre": "LUNDI — Pectoraux + Triceps",
  "jour1_contenu": "Développé couché | 4 séries | 4×10 | 60 sec | 70% 1RM\\nÉcarté poulie | Isolement pectoraux | 3×12 | 45 sec | Modérée",
  "jour2_titre": "MARDI — Dos + Biceps",
  "jour2_contenu": "Tractions | 4 séries | 4×8 | 90 sec | Lourd\\nTirage horizontal | Dos large | 3×12 | 60 sec | Modérée",
  "jour3_titre": "MERCREDI — Épaules + Abdos",
  "jour3_contenu": "Développé militaire | 4×10 | 60 sec | Modéré\\nElevations latérales | Deltoïdes | 3×15 | 45 sec | Légère",
  "jour4_titre": "JEUDI — Jambes",
  "jour4_contenu": "Squat | 4×10 | 90 sec | 75% 1RM\\nPresse à cuisses | Quadriceps | 3×12 | 60 sec | Modérée",
  "jour5_titre": "VENDREDI — Full Body",
  "jour5_contenu": "Soulevé de terre | 4×6 | 120 sec | Lourd\\nGainage | 3×60 sec | 30 sec | Modérée",
  "cardio_antiretion": "Lundi | Vélo elliptique | 20 min | 55-65% FC | Zone lipides\\nMercredi | Marche rapide | 25 min | 50-60% FC | Drainage",
  "actif": true
}''';

  static const _systemNutritionJSON = '''Tu es un expert en nutrition sportive. Tu dois générer un programme alimentaire en JSON UNIQUEMENT.
Réponds UNIQUEMENT avec ce JSON, sans texte avant ou après :
{
  "titre": "Programme Alimentaire [objectif]",
  "objectif": "[objectif détaillé]",
  "calories": 1800,
  "proteines": 150,
  "glucides": 180,
  "lipides": 60,
  "nb_repas": 5,
  "principes": "Principes anti-rétention et conseils généraux",
  "planning": {
    "Lundi": "Petit-déjeuner: Flocons d\'avoine 80g + blanc d\'oeuf 3\\nDéjeuner: Poulet 150g + riz 80g + légumes\\nDîner: Poisson 150g + légumes vapeur"
  },
  "aliments_privilegier": "Protéines maigres, légumes verts, céréales complètes",
  "aliments_eviter": "Sucres raffinés, alcool, aliments transformés",
  "conseils": "Boire 2L d\'eau par jour, manger toutes les 3h",
  "actif": true
}''';

  @override
  void initState() {
    super.initState();
    _chargerAdherents();
  }

  Future<void> _chargerAdherents() async {
    final list = await DatabaseHelper.instance.getTousAdherents();
    setState(() => _adherents = list);
  }

  Future<String> _appelerGroq(String systemPrompt, String userMessage) async {
    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_groqKey',
      },
      body: jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'max_tokens': 2048,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userMessage},
        ],
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    }
    throw Exception('Erreur API: ${response.statusCode}');
  }

  Future<void> _genererProgrammeMusculation(int adherentId, String description) async {
    setState(() => _loading = true);
    try {
      final jsonStr = await _appelerGroq(_systemMusculationJSON, description);
      // Nettoyer le JSON
      final clean = jsonStr.replaceAll('```json', '').replaceAll('```', '').trim();
      final data = jsonDecode(clean) as Map<String, dynamic>;
      data['adherent_id'] = adherentId;
      data['date_creation'] = DateTime.now().toIso8601String();
      await DatabaseHelper.instance.ajouterProgMusculation(data);
      setState(() => _messages.add({
        'role': 'assistant',
        'content': '✅ Programme musculation créé et sauvegardé pour $_nomAdherentSelectionne !\n\n**${data['titre']}**\n\n💪 ${data['nb_jours']} jours/semaine\n⏱ ${data['duree_seance']} min/séance\n📊 Niveau: ${data['niveau']}\n\nTu peux le retrouver dans la fiche de l\'adhérent.',
      }));
    } catch (e) {
      setState(() => _messages.add({
        'role': 'assistant',
        'content': '❌ Erreur lors de la génération: $e',
      }));
    }
    setState(() { _loading = false; _modeGeneration = null; });
    _scrollBas();
  }

  Future<void> _genererProgrammeNutrition(int adherentId, String description) async {
    setState(() => _loading = true);
    try {
      final jsonStr = await _appelerGroq(_systemNutritionJSON, description);
      final clean = jsonStr.replaceAll('```json', '').replaceAll('```', '').trim();
      final data = jsonDecode(clean) as Map<String, dynamic>;
      data['adherent_id'] = adherentId;
      data['date_creation'] = DateTime.now().toIso8601String();
      // Convertir planning en JSONB
      if (data['planning'] is Map) {
        // déjà ok
      }
      await DatabaseHelper.instance.ajouterProgAlimentaire(data);
      setState(() => _messages.add({
        'role': 'assistant',
        'content': '✅ Programme alimentaire créé et sauvegardé pour $_nomAdherentSelectionne !\n\n**${data['titre']}**\n\n🔥 ${data['calories']} kcal/jour\n💪 Protéines: ${data['proteines']}g\n🍚 Glucides: ${data['glucides']}g\n🥑 Lipides: ${data['lipides']}g\n\nTu peux le retrouver dans la fiche de l\'adhérent.',
      }));
    } catch (e) {
      setState(() => _messages.add({
        'role': 'assistant',
        'content': '❌ Erreur lors de la génération: $e',
      }));
    }
    setState(() { _loading = false; _modeGeneration = null; });
    _scrollBas();
  }

  Future<void> _envoyer() async {
    final texte = _ctrl.text.trim();
    if (texte.isEmpty || _loading) return;
    _ctrl.clear();

    setState(() {
      _messages.add({'role': 'user', 'content': texte});
      _loading = true;
    });
    _scrollBas();

    try {
      // Mode génération programme
      if (_modeGeneration == 'musculation' && _adherentIdSelectionne != null) {
        await _genererProgrammeMusculation(_adherentIdSelectionne!, texte);
        return;
      }
      if (_modeGeneration == 'nutrition' && _adherentIdSelectionne != null) {
        await _genererProgrammeNutrition(_adherentIdSelectionne!, texte);
        return;
      }

      // Chat normal
      final messages = _messages.map((m) => {'role': m['role'], 'content': m['content']}).toList();
      final reply = await _appelerGroq(_systemPrompt, _messages.last['content']!);
      setState(() => _messages.add({'role': 'assistant', 'content': reply}));
    } catch (e) {
      setState(() => _messages.add({'role': 'assistant', 'content': '❌ Erreur : $e'}));
    }

    setState(() => _loading = false);
    _scrollBas();
  }

  void _scrollBas() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _demarrerGeneration(String mode) {
    if (_adherents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun adhérent disponible')));
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(mode == 'musculation' ? '💪 Programme Musculation' : '🥗 Programme Nutrition'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Sélectionner l\'adhérent :'),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            hint: const Text('Choisir un adhérent'),
            items: _adherents.map((a) => DropdownMenuItem(
              value: a['id'] as int,
              child: Text('${a['prenom']} ${a['nom']}'),
            )).toList(),
            onChanged: (v) {
              _adherentIdSelectionne = v;
              final a = _adherents.firstWhere((a) => a['id'] == v);
              _nomAdherentSelectionne = '${a['prenom']} ${a['nom']}';
            },
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.orange),
            onPressed: () {
              if (_adherentIdSelectionne == null) return;
              Navigator.pop(ctx);
              setState(() {
                _modeGeneration = mode;
                _messages.add({
                  'role': 'assistant',
                  'content': mode == 'musculation'
                      ? '💪 Parfait ! Décris le programme pour **$_nomAdherentSelectionne** :\n\n- Objectif (perte de poids, prise de masse, sèche...)\n- Niveau (débutant, intermédiaire, avancé)\n- Nombre de jours/semaine\n- Groupes musculaires prioritaires\n- Équipement disponible\n- Durée des séances'
                      : '🥗 Parfait ! Décris le programme pour **$_nomAdherentSelectionne** :\n\n- Objectif (perte de poids, prise de masse, sèche...)\n- Calories souhaitées\n- Régime particulier (sans gluten, végétarien...)\n- Nombre de repas/jour\n- Aliments préférés ou à éviter\n- Niveau d\'activité physique',
                });
              });
              _scrollBas();
            },
            child: const Text('Continuer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        backgroundColor: AppTheme.noir,
        foregroundColor: AppTheme.blanc,
        title: const Row(children: [
          Icon(Icons.psychology, color: AppTheme.orange, size: 22),
          SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Assistant IA', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            Text('Coaching & Nutrition', style: TextStyle(fontSize: 11, color: AppTheme.orange)),
          ]),
        ]),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.orange),
            onSelected: _demarrerGeneration,
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'musculation',
                  child: Row(children: [
                    Icon(Icons.fitness_center, color: AppTheme.orange, size: 18),
                    SizedBox(width: 8),
                    Text('Générer programme musculation'),
                  ])),
              const PopupMenuItem(value: 'nutrition',
                  child: Row(children: [
                    Icon(Icons.restaurant, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text('Générer programme nutrition'),
                  ])),
            ],
          ),
        ],
      ),
      body: Column(children: [
        if (_modeGeneration != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: AppTheme.orange.withOpacity(0.1),
            child: Row(children: [
              Icon(_modeGeneration == 'musculation' ? Icons.fitness_center : Icons.restaurant,
                  color: AppTheme.orange, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(
                'Mode génération ${_modeGeneration} pour $_nomAdherentSelectionne',
                style: const TextStyle(fontSize: 12, color: AppTheme.orange, fontWeight: FontWeight.w600),
              )),
              GestureDetector(
                onTap: () => setState(() => _modeGeneration = null),
                child: const Icon(Icons.close, size: 16, color: AppTheme.orange),
              ),
            ]),
          ),
        Expanded(
          child: _messages.isEmpty
              ? _WelcomeScreen(
                  onSuggestion: (s) { _ctrl.text = s; _envoyer(); },
                  onGenerer: _demarrerGeneration,
                )
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_loading ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (i == _messages.length) return const _TypingIndicator();
                    final msg = _messages[i];
                    final isUser = msg['role'] == 'user';
                    return _BubbleMsg(texte: msg['content']!, isUser: isUser);
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: AppTheme.blanc,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
                blurRadius: 8, offset: const Offset(0, -2))],
          ),
          child: SafeArea(
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: _modeGeneration != null
                        ? 'Décrivez le programme...'
                        : 'Posez votre question...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppTheme.orange)),
                  ),
                  onSubmitted: (_) => _envoyer(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _envoyer,
                child: Container(
                  width: 44, height: 44,
                  decoration: const BoxDecoration(color: AppTheme.orange, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, color: AppTheme.blanc, size: 20),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _WelcomeScreen extends StatelessWidget {
  final Function(String) onSuggestion;
  final Function(String) onGenerer;
  const _WelcomeScreen({required this.onSuggestion, required this.onGenerer});

  static const _suggestions = [
    '📊 Analyse ce bilan InBody : poids 70kg, MG 30%',
    '🏃 Cardio anti-rétention d\'eau efficace',
    '💊 Quels suppléments pour la récupération ?',
    '📈 Comment progresser en musculation ?',
    '🥗 Conseils nutrition pour prise de masse',
    '💧 Stratégies anti-rétention d\'eau',
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(children: [
      const SizedBox(height: 16),
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(color: AppTheme.orange.withOpacity(0.1), shape: BoxShape.circle),
        child: const Icon(Icons.psychology, size: 40, color: AppTheme.orange),
      ),
      const SizedBox(height: 16),
      const Text('Assistant IA Coach Ayoub',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Générez des programmes ou posez vos questions.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.grisTexte, height: 1.5)),
      const SizedBox(height: 20),

      // Boutons génération
      Row(children: [
        Expanded(child: GestureDetector(
          onTap: () => onGenerer('musculation'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.orange, borderRadius: BorderRadius.circular(12)),
            child: const Column(children: [
              Icon(Icons.fitness_center, color: Colors.white, size: 28),
              SizedBox(height: 6),
              Text('Générer\nMusculation', textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
            ]),
          ),
        )),
        const SizedBox(width: 12),
        Expanded(child: GestureDetector(
          onTap: () => onGenerer('nutrition'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.shade600, borderRadius: BorderRadius.circular(12)),
            child: const Column(children: [
              Icon(Icons.restaurant, color: Colors.white, size: 28),
              SizedBox(height: 6),
              Text('Générer\nNutrition', textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
            ]),
          ),
        )),
      ]),
      const SizedBox(height: 20),

      const Align(alignment: Alignment.centerLeft,
          child: Text('Questions fréquentes :',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
      const SizedBox(height: 10),
      ..._suggestions.map((s) => GestureDetector(
        onTap: () => onSuggestion(s),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.blanc, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Text(s, style: const TextStyle(fontSize: 13, color: AppTheme.noir)),
        ),
      )),
    ]),
  );
}

class _BubbleMsg extends StatelessWidget {
  final String texte;
  final bool isUser;
  const _BubbleMsg({required this.texte, required this.isUser});

  @override
  Widget build(BuildContext context) => Align(
    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
      decoration: BoxDecoration(
        color: isUser ? AppTheme.orange : AppTheme.blanc,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isUser ? 16 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 16),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)],
      ),
      child: Text(texte, style: TextStyle(fontSize: 14, height: 1.5,
          color: isUser ? AppTheme.blanc : AppTheme.noir)),
    ),
  );
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.blanc, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)],
      ),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: 4),
        _Dot(delay: 0), SizedBox(width: 4),
        _Dot(delay: 200), SizedBox(width: 4),
        _Dot(delay: 400), SizedBox(width: 4),
      ]),
    ),
  );
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(width: 8, height: 8,
        decoration: const BoxDecoration(color: AppTheme.orange, shape: BoxShape.circle)),
  );
}
