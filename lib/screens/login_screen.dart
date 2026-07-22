import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/app_text_styles.dart';
import '../widgets/kit.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).login(
        'demo',
        _emailController.text,
        _passwordController.text,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppAmbientGlow(
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.surfaceApp,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // ── Transparent Automedon Logo Display ──────────────
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.95)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(
                          color: isDark ? AppTheme.neonViolet.withValues(alpha: 0.35) : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? AppTheme.neonViolet : AppTheme.primary600).withValues(alpha: isDark ? 0.35 : 0.15),
                            blurRadius: 28,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/automedon_logo_transparent.png',
                        height: 110,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/logo.png',
                          height: 110,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Bon retour',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displayLg(color: isDark ? Colors.white : AppTheme.ink900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Connectez-vous à votre espace fleet',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd(color: isDark ? Colors.white60 : AppTheme.ink600),
                  ),
                  const SizedBox(height: 36),

                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(color: AppTheme.danger.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.inter(color: AppTheme.danger, fontWeight: FontWeight.w600, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  Text(
                    'Adresse e-mail',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppTheme.ink900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.ink900),
                    decoration: InputDecoration(
                      hintText: 'admin@automedon.tn',
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : AppTheme.ink400),
                      prefixIcon: Icon(Icons.person_outline, color: isDark ? AppTheme.neonViolet : AppTheme.primary600),
                      fillColor: isDark ? AppTheme.darkSurface : Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: isDark ? AppTheme.neonViolet : AppTheme.primary600, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Mot de passe',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppTheme.ink900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.ink900),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : AppTheme.ink400),
                      prefixIcon: Icon(Icons.lock_outline, color: isDark ? AppTheme.neonViolet : AppTheme.primary600),
                      fillColor: isDark ? AppTheme.darkSurface : Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: isDark ? AppTheme.neonViolet : AppTheme.primary600, width: 1.5),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: isDark ? Colors.white54 : AppTheme.ink400,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  AppPrimaryButton(
                    label: 'Se connecter',
                    onPressed: _login,
                    isLoading: _isLoading,
                    icon: Icons.login,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
