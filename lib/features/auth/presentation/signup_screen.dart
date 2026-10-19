import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/finpulse_buttons.dart';
import '../../../core/widgets/finpulse_logo.dart';
import '../../../core/widgets/finpulse_text_field.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../navigation/main_wrapper.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController(text: 'Kavinda Perera');
  final _emailController =
      TextEditingController(text: 'kavinda.perera@email.lk');
  final _phoneController = TextEditingController(text: '77 458 9210');
  final _passwordController = TextEditingController(text: 'password123');
  bool _agreeTerms = true;
  bool _isEmailValid = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      final isValid = _emailController.text.contains('@') &&
          _emailController.text.contains('.');
      if (isValid != _isEmailValid) {
        setState(() => _isEmailValid = isValid);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateAccount() async {
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service & Privacy Policy.'),
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

    if (mounted && success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainWrapper()),
        (route) => false,
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Back Button and LK (LKR) Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FinPulseCircleButton(
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      }
                    },
                  ),
                  const FinPulseCurrencyBadge(
                    label: 'LK (LKR)',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Header Row: FinPulse App Logo + Title + Subtitle
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const FinPulseLogo(size: 54),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Join FinPulse Sri Lanka for smart budgeting',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // FULL NAME
              FinPulseTextField(
                label: 'Full Name',
                hintText: 'Kavinda Perera',
                controller: _nameController,
                prefixIcon: Icons.person_outline_rounded,
                isUppercaseLabel: true,
              ),
              const SizedBox(height: 18),

              // EMAIL ADDRESS
              FinPulseTextField(
                label: 'Email Address',
                hintText: 'kavinda.perera@email.lk',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline_rounded,
                isUppercaseLabel: true,
                suffixWidget: _isEmailValid
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 20,
                      )
                    : null,
              ),
              const SizedBox(height: 18),

              // MOBILE NUMBER (FOR OTP & ALERTS)
              FinPulseTextField(
                label: 'Mobile Number (For OTP & Alerts)',
                hintText: '77 458 9210',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                isUppercaseLabel: true,
                prefixWidget: Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF232733),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+94 🇱🇰',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // CREATE PASSWORD
              FinPulseTextField(
                label: 'Create Password',
                hintText: '••••••••••',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: Icons.lock_outline_rounded,
                isUppercaseLabel: true,
              ),
              const SizedBox(height: 12),

              // Password Strength Meter (3 Segments + "Strong password ✓")
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Strong password ✓',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Terms of Service & Privacy Policy Checkbox
              GestureDetector(
                onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: _agreeTerms
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _agreeTerms
                              ? AppColors.primary
                              : AppColors.darkBorder,
                              width: 1.5,
                        ),
                      ),
                      child: _agreeTerms
                          ? const Icon(
                              Icons.check_rounded,
                              color: Color(0xFF0C0F14),
                              size: 16,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'I agree to the ',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: ' & '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Create Account Primary Button
              FinPulsePrimaryButton(
                text: 'Create Account →',
                isLoading: authState.isLoading,
                onPressed: _handleCreateAccount,
              ),
              const SizedBox(height: 28),

              // "or sign up with" Divider
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
                      'or sign up with',
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
              const SizedBox(height: 22),

              // Social Buttons (Apple & Google)
              FinPulseSocialButtons(
                onAppleTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Apple Sign Up selected')),
                  );
                },
                onGoogleTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Google Sign Up selected')),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Bottom Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
