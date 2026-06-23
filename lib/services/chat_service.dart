import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notif_service.dart';

class ChatService {
  static final ChatService instance = ChatService._();
  ChatService._();

  static const _supabaseUrl  = 'https://grcawxwlnvadsbnlqenf.supabase.co';
  static const _supabaseAnon = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdyY2F3eHdsbnZhZHNibmxxZW5mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2MjI1NTEsImV4cCI6MjA5NzE5ODU1MX0.Fahq3KatRPLZXiZx3wgJ2-LKPyband2aJzzMRfvrozc';

  static Future<void> initSupabase() async {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnon);
  }

  SupabaseClient get _db => Supabase.instance.client;

  Future<void> initNotifications() async {
    await NotifService.init();
  }

  Future<void> afficherNotificationExterne({required String titre, required String corps}) async {
    await NotifService.show(titre, corps);
  }

  Future<void> envoyerMessage({
    required int adherentId,
    required String expediteur,
    required String texte,
  }) async {
    await _db.from('messages').insert({
      'adherent_id': adherentId,
      'expediteur':  expediteur,
      'texte':       texte,
      'lu':          false,
    });
  }

  Stream<List<Map<String, dynamic>>> messagesStream(int adherentId) {
    return _db
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('adherent_id', adherentId)
        .order('timestamp', ascending: true)
        .map((data) => data.cast<Map<String, dynamic>>());
  }

  Future<List<Map<String, dynamic>>> getMessages(int adherentId) async {
    final data = await _db
        .from('messages')
        .select()
        .eq('adherent_id', adherentId)
        .order('timestamp', ascending: true);
    return data.cast<Map<String, dynamic>>();
  }

  Future<int> getNonLus(int adherentId, String lecteur) async {
    final data = await _db
        .from('messages')
        .select()
        .eq('adherent_id', adherentId)
        .eq('lu', false)
        .neq('expediteur', lecteur);
    return data.length;
  }

  Future<void> marquerLus(int adherentId, String lecteur) async {
    await _db
        .from('messages')
        .update({'lu': true})
        .eq('adherent_id', adherentId)
        .eq('lu', false)
        .neq('expediteur', lecteur);
  }
}
