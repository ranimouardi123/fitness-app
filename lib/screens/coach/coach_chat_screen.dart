import 'dart:async';
import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../services/chat_service.dart';

class CoachChatScreen extends StatefulWidget {
  final int adherentId;
  final String nomAdherent;
  const CoachChatScreen({super.key, required this.adherentId, required this.nomAdherent});
  @override
  State<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends State<CoachChatScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    ChatService.instance.marquerLus(widget.adherentId, 'coach');
    _sub = ChatService.instance.messagesStream(widget.adherentId).listen((msgs) {
      setState(() => _messages = msgs);
      _scrollBas();
    });
  }

  @override
  void dispose() { _sub?.cancel(); _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  void _scrollBas() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Future<void> _envoyer() async {
    final texte = _ctrl.text.trim();
    if (texte.isEmpty) return;
    _ctrl.clear();
    await ChatService.instance.envoyerMessage(
      adherentId: widget.adherentId,
      expediteur: 'coach',
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
        title: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.orange.withOpacity(0.2),
            child: Text(
              widget.nomAdherent.isNotEmpty ? widget.nomAdherent[0].toUpperCase() : '?',
              style: const TextStyle(color: AppTheme.orange, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.nomAdherent,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const Text('En ligne', style: TextStyle(fontSize: 11, color: Colors.green)),
          ]),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: _messages.isEmpty
              ? const Center(
                  child: Text('Aucun message\nCommencez la conversation !',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.grisTexte)))
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (ctx, i) => _BubbleMsg(
                    msg: _messages[i],
                    isCoach: _messages[i]['expediteur'] == 'coach'),
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
                    hintText: 'Message...',
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
  final bool isCoach;
  const _BubbleMsg({required this.msg, required this.isCoach});
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
      alignment: isCoach ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isCoach ? AppTheme.orange : AppTheme.blanc,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isCoach ? 16 : 4),
            bottomRight: Radius.circular(isCoach ? 4 : 16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
              blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: isCoach ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(texte, style: TextStyle(fontSize: 14,
                color: isCoach ? AppTheme.blanc : AppTheme.noir)),
            const SizedBox(height: 3),
            Text(heure, style: TextStyle(fontSize: 10,
                color: isCoach ? Colors.white60 : AppTheme.grisTexte)),
          ],
        ),
      ),
    );
  }
}
