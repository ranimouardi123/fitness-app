import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _mdpCtrl   = TextEditingController();
  bool _loading    = false;
  bool _showMdp    = false;

  @override
  void dispose() { _emailCtrl.dispose(); _mdpCtrl.dispose(); super.dispose(); }

  Future<void> _connexion() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final result = await AuthService().connexionCoach(_emailCtrl.text, _mdpCtrl.text);
    setState(() => _loading = false);
    if (!mounted) return;
    if (result != null) {
      context.go('/coach');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Email ou mot de passe incorrect'),
        backgroundColor: AppTheme.danger,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),

              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 280,
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 32),

              // Titre
              const Text('Connexion Coach',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              const Text('Accédez à votre espace de gestion',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
              const SizedBox(height: 36),

              // Formulaire
              Form(
                key: _formKey,
                child: Column(children: [
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _mdpCtrl,
                    obscureText: !_showMdp,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_showMdp
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () => setState(() => _showMdp = !_showMdp),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _loading ? null : _connexion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8410A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Se connecter',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: () => context.push('/code-acces'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE8410A),
                      minimumSize: const Size(double.infinity, 52),
                      side: const BorderSide(color: Color(0xFFE8410A)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Accès adhérent (code)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
              const SizedBox(height: 28),

              // Compte par défaut
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8410A).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8410A).withOpacity(0.2)),
                ),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Compte par défaut :',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  SizedBox(height: 4),
                  Text('Email : coach@fitness.app',
                      style: TextStyle(color: AppTheme.textSecondary)),
                  Text('Mot de passe : coach123',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ]),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
