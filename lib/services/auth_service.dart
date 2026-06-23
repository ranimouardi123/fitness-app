import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'database_helper.dart';

class AuthService {
  static const _keyUserId     = 'user_id';
  static const _keyUserRole   = 'user_role';
  static const _keyUserNom    = 'user_nom';
  static const _keyUserPrenom = 'user_prenom';
  static const _keyConnecte   = 'connecte';

  static String _hasherMotDePasse(String mdp) {
    final bytes = utf8.encode(mdp);
    return sha256.convert(bytes).toString();
  }

  static String genererCodeAcces() {
    final uuid = const Uuid().v4().substring(0, 8).toUpperCase();
    return 'ADH-$uuid';
  }

  Future<Map<String, dynamic>?> connexionCoach(String email, String mdp) async {
    final db    = DatabaseHelper.instance;
    final coach = await db.getCoachParEmail(email.trim().toLowerCase());
    if (coach == null) return null;
    final hashSaisi = _hasherMotDePasse(mdp);
    if (coach['mot_de_passe'] != hashSaisi) return null;
    await _sauvegarderSession(id: coach['id'], role: 'coach', nom: coach['nom'], prenom: coach['prenom']);
    return coach;
  }

  Future<Map<String, dynamic>?> connexionAdherent(String code) async {
    final db       = DatabaseHelper.instance;
    final adherent = await db.getUtilisateurParCodeAcces(code.trim().toUpperCase());
    if (adherent == null) return null;
    await _sauvegarderSession(id: adherent['id'], role: 'adherent', nom: adherent['nom'], prenom: adherent['prenom']);
    return adherent;
  }

  Future<void> _sauvegarderSession({
    required int id,
    required String role,
    required String nom,
    required String prenom,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt   (_keyUserId,     id);
    await prefs.setString(_keyUserRole,   role);
    await prefs.setString(_keyUserNom,    nom);
    await prefs.setString(_keyUserPrenom, prenom);
    await prefs.setBool  (_keyConnecte,   true);

    // ── S'abonner au topic FCM selon le rôle ──
    try {
      if (role == 'adherent') {
        await FirebaseMessaging.instance.subscribeToTopic('adherent_$id');
      } else if (role == 'coach') {
        await FirebaseMessaging.instance.subscribeToTopic('coach_messages');
      }
    } catch (_) {}
  }

  Future<void> deconnexion() async {
    final prefs = await SharedPreferences.getInstance();
    final role   = prefs.getString(_keyUserRole) ?? '';
    final id     = prefs.getInt(_keyUserId);

    // Se désabonner du topic FCM
    try {
      if (role == 'adherent' && id != null) {
        await FirebaseMessaging.instance.unsubscribeFromTopic('adherent_$id');
      } else if (role == 'coach') {
        await FirebaseMessaging.instance.unsubscribeFromTopic('coach_messages');
      }
    } catch (_) {}

    await prefs.clear();
  }

  Future<bool> estConnecte() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyConnecte) ?? false;
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  Future<String> getNomComplet() async {
    final prefs  = await SharedPreferences.getInstance();
    final nom    = prefs.getString(_keyUserNom)    ?? '';
    final prenom = prefs.getString(_keyUserPrenom) ?? '';
    return '$prenom $nom'.trim();
  }
}
