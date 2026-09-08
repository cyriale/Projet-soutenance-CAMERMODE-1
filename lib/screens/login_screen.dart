import 'package:flutter/material.dart';
import '../compronents/app_button.dart';
import '../compronents/app_text_field.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';
import 'auth/role_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseClair,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.rose,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'CamerMode',
                      style: TextStyle(
                        color: AppColors.noir,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Bienvenue sur CamerMode',
                style: TextStyle(
                  color: AppColors.noir,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connectez-vous pour retrouver votre espace.',
                style: TextStyle(color: AppColors.noir, fontSize: 16),
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _emailController,
                labelText: 'Adresse e-mail',
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.noir),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _passwordController,
                labelText: 'Mot de passe',
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.noir),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xB31C1C1C), // Noir with opacity
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(color: AppColors.noir, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Se connecter',
                backgroundColor: AppColors.rose,
                isLoading: _isLoading,
                onPressed: _isLoading ? () {} : () async {
                  if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                    setState(() => _isLoading = true);
                    
                    final messenger = ScaffoldMessenger.of(context);
                    final user = await _authService.signIn(
                      _emailController.text.trim(),
                      _passwordController.text,
                    );

                    if (user == null && mounted) {
                      setState(() => _isLoading = false);
                      messenger.showSnackBar(
                        const SnackBar(content: Text("Email ou mot de passe incorrect.")),
                      );
                    }
                    // Si user != null, le AuthWrapper redirigera automatiquement
                  }
                },
              ),
              const SizedBox(height: 20),

              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OU', style: TextStyle(color: AppColors.texteSecondaire)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.g_mobiledata, size: 30),
                label: const Text('Continuer avec Google'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(color: AppColors.texteSecondaire),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Vous n'avez pas encore de compte ? ",
                      style: TextStyle(color: AppColors.noir),
                      children: [
                        TextSpan(
                          text: 'Créer un compte',
                          style: TextStyle(
                            color: AppColors.rose,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
