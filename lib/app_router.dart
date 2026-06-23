import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_theme.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/code_acces_screen.dart';
import 'screens/coach/coach_dashboard_screen.dart';
import 'screens/coach/adherents_screen.dart';
import 'screens/coach/ajouter_adherent_screen.dart';
import 'screens/coach/fiche_adherent_screen.dart';
import 'screens/coach/bilan_corporel_screen.dart';
import 'screens/coach/bilan_sanguin_screen.dart';
import 'screens/coach/prog_alimentaire_screen.dart';
import 'screens/coach/prog_musculation_screen.dart';
import 'screens/coach/prog_simple_screen.dart';
import 'screens/coach/tracker_screen.dart';
import 'screens/coach/suivi_mensuel_screen.dart';
import 'screens/coach/coach_chat_screen.dart';
import 'screens/adherent/adherent_home_screen.dart';
import 'screens/adherent/adherent_prog_view_screen.dart';
import 'screens/adherent/adherent_tracking_screen.dart';
import 'screens/adherent/adherent_nutrition_screen.dart';
import 'screens/adherent/adherent_entrainement_screen.dart';
import 'screens/adherent/adherent_musculation_screen.dart';
import 'screens/adherent/adherent_chat_screen.dart';

final _auth = AuthService();

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) async {
    final connecte = await _auth.estConnecte();
    final role     = await _auth.getRole();
    final loc      = state.matchedLocation;
    if (loc == '/splash') {
      if (!connecte) return '/login';
      return role == 'coach' ? '/coach' : '/adherent';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login',  builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/code-acces', builder: (_, __) => const CodeAccesScreen()),

    // ═══ COACH ═══
    GoRoute(path: '/coach', builder: (_, __) => const CoachDashboardScreen(), routes: [
      GoRoute(path: 'adherents', builder: (_, __) => const AdherentsScreen(), routes: [
        GoRoute(path: 'ajouter', builder: (_, __) => const AjouterAdherentScreen()),
        GoRoute(path: ':id/modifier',
            builder: (_, s) => AjouterAdherentScreen(
                adherentId: int.parse(s.pathParameters['id']!))),
      ]),
      GoRoute(path: 'adherent/:id',
          builder: (_, s) => FicheAdherentScreen(
              adherentId: int.parse(s.pathParameters['id']!)),
          routes: [
            GoRoute(path: 'bilan-corporel',
                builder: (_, s) => BilanCorporelScreen(
                    adherentId: int.parse(s.pathParameters['id']!))),
            GoRoute(path: 'bilan-sanguin',
                builder: (_, s) => BilanSanguinScreen(
                    adherentId: int.parse(s.pathParameters['id']!))),
            GoRoute(path: 'suivi-mensuel',
                builder: (_, s) => SuiviMensuelScreen(
                    adherentId: int.parse(s.pathParameters['id']!))),
            GoRoute(path: 'prog-alimentaire',
                builder: (_, s) => ProgAlimentaireScreen(
                    adherentId: int.parse(s.pathParameters['id']!))),
            GoRoute(path: 'prog-musculation',
                builder: (_, s) => ProgMusculationScreen(
                    adherentId: int.parse(s.pathParameters['id']!))),
            GoRoute(path: 'prog-cardio',
                builder: (_, s) => ProgSimpleScreen(
                    adherentId: int.parse(s.pathParameters['id']!),
                    type: TypeProg.cardio)),
            GoRoute(path: 'tracker',
                builder: (_, s) => TrackerScreen(
                    adherentId: int.parse(s.pathParameters['id']!))),
            GoRoute(path: 'chat',
                builder: (_, s) => CoachChatScreen(
                    adherentId: int.parse(s.pathParameters['id']!),
                    nomAdherent: s.uri.queryParameters['nom'] ?? '')),
          ]),
    ]),

    // ═══ ADHERENT ═══
    GoRoute(path: '/adherent', builder: (_, __) => const AdherentHomeScreen(), routes: [
      GoRoute(path: 'prog-alimentaire/:progId',
          builder: (_, s) => AdherentProgViewScreen(
              programmeId: int.parse(s.pathParameters['progId']!),
              type: TypeProg.alimentaire)),
      GoRoute(path: 'prog-musculation/:progId',
          builder: (_, s) => AdherentMusculationScreen(
              programmeId: int.parse(s.pathParameters['progId']!))),
      GoRoute(path: 'prog-cardio/:progId',
          builder: (_, s) => AdherentProgViewScreen(
              programmeId: int.parse(s.pathParameters['progId']!),
              type: TypeProg.cardio)),
      GoRoute(path: 'tracking/:adherentId',
          builder: (_, s) => AdherentTrackingScreen(
              adherentId: int.parse(s.pathParameters['adherentId']!))),
      GoRoute(path: 'nutrition/:progId',
          builder: (_, s) => AdherentNutritionScreen(
              programmeId: int.parse(s.pathParameters['progId']!))),
      GoRoute(path: 'entrainement/:progId',
          builder: (_, s) => AdherentEntrainementScreen(
              programmeId: int.parse(s.pathParameters['progId']!))),
      GoRoute(path: 'chat',
          builder: (_, __) => const AdherentChatScreen()),
    ]),
  ],
);

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: CircularProgressIndicator(color: AppTheme.orange)));
}
