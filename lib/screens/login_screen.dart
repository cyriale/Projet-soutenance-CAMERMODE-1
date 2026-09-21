import 'package:flutter/material.dart';
import '../compronents/app_button.dart';
import '../compronents/app_text_field.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';
import 'auth/role_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onContinueAsGuest;
  const LoginScreen({super.key, this.onContinueAsGuest});

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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez saisir votre email et votre mot de passe."),
          backgroundColor: AppColors.erreur,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await _authService.signIn(
      email.toLowerCase(),
      password,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.erreur,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      // Si error == null, AuthWrapper détecte le changement de session et redirige instantanément
    }
  }

  void _showForgotPasswordModal() {
    final resetEmailController = TextEditingController(text: _emailController.text.trim());
    bool isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.rose.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock_reset, color: AppColors.rose, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "Mot de passe oublié ?",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.noir),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Entrez votre adresse email ci-dessous. Nous vous enverrons un lien sécurisé pour réinitialiser votre mot de passe immédiatement.",
                style: TextStyle(color: AppColors.texteSecondaire, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: resetEmailController,
                labelText: "Adresse e-mail",
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.rose),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: "ENVOYER LE LIEN DE RÉCUPÉRATION",
                isLoading: isSending,
                onPressed: isSending
                    ? () {}
                    : () async {
                        final email = resetEmailController.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Email invalide.")),
                          );
                          return;
                        }

                        setModalState(() => isSending = true);
                        final error = await _authService.sendPasswordResetEmail(email);
                        setModalState(() => isSending = false);

                        if (context.mounted) {
                          Navigator.pop(context);
                          if (error == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Lien envoyé avec succès à $email ! Vérifiez vos emails."),
                                backgroundColor: AppColors.succes,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error), backgroundColor: AppColors.erreur),
                            );
                          }
                        }
                      },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _quickFill(String email, String pass) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = pass;
    });
  }

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
              const SizedBox(height: 16),
              
              // Widget Dynamique d'accueil CamerMode
              _buildBrandHeader(),
              
              const SizedBox(height: 32),
              
              // Titre et bienvenue
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
                'Connectez-vous pour retrouver votre espace personnel et professionnel.',
                style: TextStyle(color: AppColors.texteSecondaire, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Raccourcis de test rapide pour fluidifier les démonstrations
              _buildQuickTestBar(),

              const SizedBox(height: 24),

              // Champ Email
              AppTextField(
                controller: _emailController,
                labelText: 'Adresse e-mail',
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.noir),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Champ Mot de passe
              AppTextField(
                controller: _passwordController,
                labelText: 'Mot de passe',
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.noir),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xB31C1C1C),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),

              // Mot de passe oublié
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPasswordModal,
                  child: const Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bouton Connexion
              AppButton(
                text: 'SE CONNECTER',
                backgroundColor: AppColors.rose,
                isLoading: _isLoading,
                onPressed: _isLoading ? () {} : _handleLogin,
              ),
              const SizedBox(height: 24),

              // Séparateur
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OU', style: TextStyle(color: AppColors.texteSecondaire, fontSize: 12)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),

              // Créer un compte
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
                      style: TextStyle(color: AppColors.noir, fontSize: 14),
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
              const SizedBox(height: 24),

              // Continuer en tant que visiteur
              if (widget.onContinueAsGuest != null)
                Center(
                  child: TextButton.icon(
                    onPressed: widget.onContinueAsGuest,
                    icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.texteSecondaire),
                    label: const Text(
                      "Continuer en tant que visiteur",
                      style: TextStyle(
                        color: AppColors.texteSecondaire,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // Header dynamique avec logo et puces interactives
  Widget _buildBrandHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.rose.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 14),
          const Text(
            'CAMERMODE',
            style: TextStyle(
              color: AppColors.noir,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Mode Africaine Sur-Mesure • Coiffure • IA Morphologique',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.texteSecondaire, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          // Dynamic feature tags
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _featureTag(Icons.checkroom, "Couture"),
                const SizedBox(width: 8),
                _featureTag(Icons.content_cut, "Coiffure"),
                const SizedBox(width: 8),
                _featureTag(Icons.view_in_ar, "Essayage AR"),
                const SizedBox(width: 8),
                _featureTag(Icons.psychology, "IA Styliste"),
                const SizedBox(width: 8),
                _featureTag(Icons.location_on, "Proximité"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.rose.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.rose),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.noir)),
        ],
      ),
    );
  }

  // Raccourcis pour tester instantanément
  Widget _buildQuickTestBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ligne),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bolt, color: Colors.amber, size: 16),
              SizedBox(width: 6),
              Text(
                "Accès rapide aux Dashboards :",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.texteSecondaire),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                label: const Text("👑 Admin"),
                backgroundColor: AppColors.rose.withOpacity(0.1),
                side: const BorderSide(color: AppColors.rose),
                labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.rose),
                onPressed: () => _quickFill("cyrialesahamene@gmail.com", "12345678"),
              ),
              ActionChip(
                label: const Text("✂️ Prestataire"),
                backgroundColor: Colors.blue.withOpacity(0.08),
                side: const BorderSide(color: Colors.blue),
                labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
                onPressed: () => _quickFill("prestataire@camermode.cm", "12345678"),
              ),
              ActionChip(
                label: const Text("🛍️ Client"),
                backgroundColor: Colors.green.withOpacity(0.08),
                side: const BorderSide(color: Colors.green),
                labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                onPressed: () => _quickFill("client@camermode.cm", "12345678"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
