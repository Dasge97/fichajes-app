import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/entro_theme.dart';
import '../../../core/widgets/entro_widgets.dart';
import 'auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: EC.bgCanvas,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),
              const EntroLogo(size: 20),
              const SizedBox(height: 36),
              Text(
                'Hola de nuevo.',
                style: ET.sans(size: 34, weight: FontWeight.w700, height: 1.05),
              ),
              const SizedBox(height: 8),
              Text(
                'Introduce tus datos para empezar la jornada.',
                style: ET.sans(size: 15, color: EC.text2),
              ),
              const SizedBox(height: 32),

              // Email field
              Text(
                'EMAIL O CÓDIGO',
                style: ET.sans(size: 11, weight: FontWeight.w600, color: EC.text3, letterSpacing: 0.6),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: ET.sans(size: 15),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.mail_outline_rounded, size: 18, color: EC.text3),
                  hintText: 'email@empresa.com',
                ),
              ),
              const SizedBox(height: 14),

              // Password field
              Text(
                'PIN',
                style: ET.sans(size: 11, weight: FontWeight.w600, color: EC.text3, letterSpacing: 0.6),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                onSubmitted: (_) => _submit(auth),
                style: ET.sans(size: 15),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: EC.text3),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(
                      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 18,
                      color: EC.text3,
                    ),
                  ),
                  hintText: '••••',
                ),
              ),

              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '¿No recuerdas tu acceso?',
                  style: ET.sans(size: 14, color: EC.text2).copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: EC.line,
                  ),
                ),
              ),

              if (auth.error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: EC.errorSoft,
                    borderRadius: BorderRadius.circular(ER.md),
                  ),
                  child: Text(auth.error!, style: ET.sans(size: 13, color: EC.error)),
                ),
              ],

              const SizedBox(height: 32),
              PrimaryBtn(
                label: auth.loading ? 'Entrando...' : 'Entrar',
                onTap: auth.loading ? null : () => _submit(auth),
              ),
              const SizedBox(height: 14),
              SoftBtn(
                label: 'Entrar con huella',
                icon: Icons.fingerprint_rounded,
                onTap: null,
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Powered by entroya · v3.4.1',
                  style: ET.sans(size: 12, color: EC.text3),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(AuthController auth) {
    FocusScope.of(context).unfocus();
    auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
  }
}
