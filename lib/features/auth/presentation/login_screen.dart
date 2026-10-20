import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/finpulse_buttons.dart';
import '../../../core/widgets/finpulse_logo.dart';
import '../../../core/widgets/finpulse_text_field.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';
import '../../navigation/main_wrapper.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  final _emailController =
      TextEditingController(text: 'kavinda.perera@email.lk');
  final _passwordController = TextEditingController(text: 'secret123');
  bool _rememberMe = true;
  late bool _isEmailValid;
  String? _emailError;

  bool _checkEmail(String email) => _emailRegExp.hasMatch(email.trim());

  @override
  void initState() {
    super.initState();
    _isEmailValid = _checkEmail(_emailController.text);
    _emailController.addListener(() {
      final isValid = _checkEmail(_emailController.text);
      if (isValid != _isEmailValid || _emailError != null) {
        setState(() {
          _isEmailValid = isValid;
          if (isValid) _emailError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _emailError = 'Please enter your email address');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address.'),
        ),
      );
      return;
    }

    if (!_checkEmail(email)) {
      setState(() => _emailError = 'Please enter a valid email address');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address (e.g. name@domain.lk).'),
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password.'),
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).login(
          email,
          password,
        );

    if (mounted && success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Hero Logo with Circular Glow Halo
              const FinPulseLogo(
                size: 64,
                withHalo: true,
              ),
              const SizedBox(height: 24),

              // Title and Subtitle
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to manage your finances',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 36),

              // Email Address Field
              FinPulseTextField(
                label: 'Email Address',
                hintText: 'kavinda.perera@email.lk',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline_rounded,
                errorText: _emailError,
                suffixWidget: _emailController.text.trim().isNotEmpty
                    ? (_isEmailValid
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 20,
                          )
                        : const Icon(
                            Icons.cancel_rounded,
                            color: AppColors.error,
                            size: 20,
                          ))
                    : null,
              ),
              const SizedBox(height: 20),

              // Password Field
              FinPulseTextField(
                label: 'Password',
                hintText: '••••••••',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: Icons.lock_outline_rounded,
              ),
              const SizedBox(height: 16),

              // Remember Me & Forgot Password Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _rememberMe
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _rememberMe
                                  ? AppColors.primary
                                  : AppColors.darkBorder,
                              width: 1.5,
                            ),
                          ),
                          child: _rememberMe
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Color(0xFF0C0F14),
                                  size: 16,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Remember me',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Reset link sent to registered email address.'),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Sign In Primary Button
              FinPulsePrimaryButton(
                text: 'Sign In →',
                isLoading: authState.isLoading,
                onPressed: _handleSignIn,
              ),
              const SizedBox(height: 32),

              // "or continue with" Divider
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.darkBorder,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or continue with',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.darkBorder,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Social Buttons (Apple and Google)
              FinPulseSocialButtons(
                onAppleTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Apple Sign In selected')),
                  );
                },
                onGoogleTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Google Sign In selected')),
                  );
                },
              ),
              const SizedBox(height: 36),

              // Bottom Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
