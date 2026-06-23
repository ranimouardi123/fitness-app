import 'dart:async';
import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';

class AdherentChatScreen extends StatefulWidget {
  const AdherentChatScreen({super.key});
  @override
  State<AdherentChatScreen> createState() => _AdherentChatScreenState();
}

class _AdherentChatScreenState extends State<AdherentChatScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  int? _adherentId;
  StreamSubscription? _sub;

  @override
  void initState() { super.initState(); _charger(); }

  Future<void> _charger() async {
    final id = await AuthService().getUserId();
    if (id == null) return;
    setState(() => _adherentId = id);
    ChatService.instance.marquerLus(id, 'adherent');
    _sub = ChatService.instance.messagesStream(id).listen((msgs) {
      setState(() => _messages = msgs);
      _scrollBas();
    });
  }

  void _scrollBas() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  void dispose() { _sub?.cancel(); _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _envoyer() async {
    if (_adherentId == null) return;
    final texte = _ctrl.text.trim();
    if (texte.isEmpty) return;
    _ctrl.clear();
    await ChatService.instance.envoyerMessage(
      adherentId: _adherentId!,
      expediteur: 'adherent',
      texte: texte,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      appBar: AppBar(
        backgroundColor: AppTheme.noir,
        foregroundColor: AppTheme.blanc,
        automaticallyImplyLeading: false,
        title: Row(children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: AppTheme.orange.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.fitness_center, color: AppTheme.orange, size: 18)),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Coach Ayoub', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            Text('AM Coaching Sportif', style: TextStyle(fontSize: 11, color: AppTheme.orange)),
          ]),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: _messages.isEmpty
              ? const Center(
                  child: Text('Aucun message\nVotre coach vous répondra bientôt !',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.grisTexte)))
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (ctx, i) => _BubbleMsg(
                    msg: _messages[i],
                    isAdherent: _messages[i]['expediteur'] == 'adherent'),
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
                    hintText: 'Message pour le coach...',
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

class _BubbleMsg extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isAdherent;
  const _BubbleMsg({required this.msg, required this.isAdherent});
  @override
  Widget build(BuildContext context) {
    final texte = msg['texte'] as String? ?? '';
    final ts    = msg['timestamp'] as String? ?? '';
    String heure = '';
    if (ts.isNotEmpty) {
      try {
        final dt = DateTime.parse(ts).toLocal();
        heure = '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
      } catch (_) {}
    }
    return Align(
      alignment: isAdherent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isAdherent ? AppTheme.orange : AppTheme.blanc,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAdherent ? 16 : 4),
            bottomRight: Radius.circular(isAdherent ? 4 : 16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
              blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: isAdherent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isAdherent) ...[
              const Text('Coach Ayoub', style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w700, color: AppTheme.orange)),
              const SizedBox(height: 2),
            ],
            Text(texte, style: TextStyle(fontSize: 14,
                color: isAdherent ? AppTheme.blanc : AppTheme.noir)),
            const SizedBox(height: 3),
            Text(heure, style: TextStyle(fontSize: 10,
                color: isAdherent ? Colors.white60 : AppTheme.grisTexte)),
          ],
        ),
      ),
    );
  }
}
