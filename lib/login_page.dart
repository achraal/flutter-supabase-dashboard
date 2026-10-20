import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showClearEmail = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      final hasText = _emailController.text.isNotEmpty;
      if (hasText != _showClearEmail) {
        setState(() => _showClearEmail = hasText);
      }
    });
  }

  // --- PALETTE DE COULEURS DYNAMIQUE (Alignée sur le Dark Theme Tailwind/Material) ---
  bool get _darkMode => Theme.of(context).brightness == Brightness.dark;

  // Surfaces & Containers
  Color get _bgSurface => _darkMode ? const Color(0xFF121317) : const Color(0xFFFAF9FE);
  Color get _emblemBg => _darkMode ? const Color(0xFF0D0E12) : Colors.white;
  Color get _inputBg => _darkMode ? const Color(0xFF1E1F23) : const Color(0xFFE3E2E7).withOpacity(0.6);
  Color get _socialBtnBg => _darkMode ? const Color(0xFF292A2E) : Colors.white;
  Color get _snackBg => _darkMode ? const Color(0xFF343539) : Colors.white;

  // Textes & Contours
  Color get _textPrimary => _darkMode ? const Color(0xFFE3E2E7) : const Color(0xFF1A1B1F);
  Color get _textSecondary => _darkMode ? const Color(0xFFC0C6D6) : const Color(0xFF414755);
  Color get _outline => _darkMode ? const Color(0xFF8B91A0) : const Color(0xFF717786);
  Color get _dividerColor => _darkMode ? const Color(0xFF414754).withOpacity(0.4) : Colors.black.withOpacity(0.08);

  // Accentuations & Liens
  Color get _primaryLink => _darkMode ? const Color(0xFFAAC7FF) : const Color(0xFF0A84FF);
  Color get _error => _darkMode ? const Color(0xFFFFB4AB) : const Color(0xFFFF453A);
  Color get _btnTextColor => _darkMode ? const Color(0xFF003064) : Colors.white;

  // Dégradé du bouton principal
  List<Color> get _btnGradientColors => _darkMode
      ? const [Color(0xFF3E90FF), Color(0xFFAAC7FF), Color(0xFF3630BF)]
      : const [Color(0xFF0A84FF), Color(0xFF5E5CE6)];

  void _showToast(String message, {bool isError = false, IconData? icon}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: _snackBg,
        elevation: 10,
        content: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: (isError ? _error : _primaryLink).withOpacity(0.20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? (isError ? Icons.error_outline : Icons.check_circle_outline),
                color: isError ? _error : _primaryLink,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showToast('Veuillez remplir tous les champs', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;

      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      debugPrint('Erreur Auth Supabase: ${e.message}');
      _showToast(e.message, isError: true);
    } catch (e) {
      debugPrint('Erreur inattendue: $e');
      _showToast('Erreur de connexion: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showToast('Entrez votre adresse email pour réinitialiser le mot de passe', isError: true);
      return;
    }

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      _showToast(
        'Un lien sécurisé a été transmis par courriel.',
        icon: CupertinoIcons.checkmark_seal_fill,
      );
    } catch (e) {
      _showToast('Erreur lors de la réinitialisation: $e', isError: true);
    }
  }

  Future<void> _signInWithOAuth(OAuthProvider provider) async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(provider);
    } catch (e) {
      _showToast('Erreur d\'authentification SSO: $e', isError: true);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgSurface,
      body: Stack(
        children: [
          // 0. AMBIENT GLOW ORBS (Lumières diffuses en arrière-plan)
          Positioned(
            top: -40,
            left: -40,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _darkMode
                      ? const Color(0xFF3E90FF).withOpacity(0.20)
                      : const Color(0xFFE8F2FF),
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: -40,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _darkMode
                      ? const Color(0xFFC2C1FF).withOpacity(0.20)
                      : const Color(0xFFF3E8FF),
                ),
              ),
            ),
          ),

          // CONTENU PRINCIPAL
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. CARTE EMBLEME / LOGO
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: _emblemBg,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(_darkMode ? 0.25 : 0.06),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            if (_darkMode)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFAAC7FF).withOpacity(0.10),
                                        Colors.transparent,
                                        const Color(0xFFC2C1FF).withOpacity(0.15),
                                      ],
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight,
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Image.asset(
                                'assets/images/emsi.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    CupertinoIcons.sparkles,
                                    size: 44,
                                    color: _primaryLink,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. EN-TÊTE TYPOGRAPHIQUE
                    Text(
                      'Connexion',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Entrez vos identifiants pour vous connecter',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: _textSecondary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 3. CHAMP EMAIL AVEC BOUTON D'EFFACEMENT
                    _buildInputField(
                      controller: _emailController,
                      hintText: 'Adresse email',
                      icon: CupertinoIcons.mail,
                      keyboardType: TextInputType.emailAddress,
                      suffixIcon: _showClearEmail
                          ? GestureDetector(
                        onTap: () => _emailController.clear(),
                        child: Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: _outline,
                          size: 18,
                        ),
                      )
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // 4. CHAMP MOT DE PASSE
                    _buildInputField(
                      controller: _passwordController,
                      hintText: 'Mot de passe',
                      icon: CupertinoIcons.lock,
                      obscureText: _obscurePassword,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                          color: _outline,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 5. MOT DE PASSE OUBLIÉ
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _resetPassword,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _primaryLink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 6. BOUTON PRINCIPAL SE CONNECTER
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: _btnGradientColors,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _darkMode
                                ? const Color(0xFF3E90FF).withOpacity(0.25)
                                : const Color(0xFF0A84FF).withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? CupertinoActivityIndicator(color: _btnTextColor)
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Se connecter',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _btnTextColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              CupertinoIcons.arrow_right,
                              size: 18,
                              color: _btnTextColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 7. SÉPARATEUR "OU"
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: _dividerColor,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'OU',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _outline,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: _dividerColor,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 8. BOUTONS DE CONNEXION SOCIALE (Apple & Google)
                    _buildSocialButton(
                      label: 'Continuer avec Apple',
                      iconWidget: Icon(
                        Icons.apple,
                        size: 22,
                        color: _textPrimary,
                      ),
                      onPressed: () => _signInWithOAuth(OAuthProvider.apple),
                    ),
                    const SizedBox(height: 12),
                    _buildSocialButton(
                      label: 'Continuer avec Google',
                      iconWidget: const Icon(
                        CupertinoIcons.globe,
                        size: 18,
                        color: Color(0xFF4285F4),
                      ),
                      onPressed: () => _signInWithOAuth(OAuthProvider.google),
                    ),
                    const SizedBox(height: 28),

                    // 9. REDIRECTION INSCRIPTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pas encore de compte ? ',
                          style: TextStyle(fontSize: 14, color: _textSecondary),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterPage()),
                            );
                          },
                          child: Text(
                            'S\'inscrire',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _primaryLink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Composant pour les champs de saisie
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_darkMode ? 0.2 : 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15, color: _textPrimary),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: _outline, fontSize: 15),
          prefixIcon: Icon(icon, color: _outline, size: 20),
          suffixIcon: suffixIcon != null
              ? Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: suffixIcon,
          )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  // Composant pour les boutons d'authentification SSO
  Widget _buildSocialButton({
    required String label,
    required Widget iconWidget,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: _socialBtnBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withOpacity(_darkMode ? 0.0 : 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_darkMode ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(child: iconWidget),
                ),
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}