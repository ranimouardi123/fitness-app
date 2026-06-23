import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../app_theme.dart';

class CodeAccesScreen extends StatefulWidget {
  const CodeAccesScreen({super.key});
  @override
  State<CodeAccesScreen> createState() => _CodeAccesScreenState();
}

class _CodeAccesScreenState extends State<CodeAccesScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading   = false;

  @override
  void dispose() { _codeCtrl.dispose(); super.dispose(); }

  Future<void> _connexion() async {
    if (_codeCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final result = await AuthService().connexionAdherent(_codeCtrl.text);
    setState(() => _loading = false);
    if (!mounted) return;
    if (result != null) {
      context.go('/adherent');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Code d'accès invalide. Vérifiez avec votre coach."),
        backgroundColor: AppTheme.danger,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Logo
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))],
                  ),
                  child: Image.asset('assets/images/logo.png', width: 130, height: 100, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 28),

              const Text('Espace adhérent',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              const Text('Entrez le code fourni par votre coach',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
              const SizedBox(height: 36),

              TextFormField(
                controller: _codeCtrl,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 4),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'ADH-XXXXXXXX',
                  hintStyle: TextStyle(letterSpacing: 2, color: AppTheme.textSecondary, fontWeight: FontWeight.normal, fontSize: 18),
                  prefixIcon: Icon(Icons.vpn_key_outlined),
                ),
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
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Accéder à mon programme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
