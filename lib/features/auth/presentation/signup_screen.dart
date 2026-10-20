import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/finpulse_buttons.dart';
import '../../../core/widgets/finpulse_logo.dart';
import '../../../core/widgets/finpulse_text_field.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../navigation/main_wrapper.dart';

enum PasswordStrength { empty, weak, medium, strong }

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp _phoneRegExp = RegExp(
    r'^(?:0|94|\+94)?(7[0-8]\d{7})$',
  );

  final _nameController = TextEditingController(text: 'Kavinda Perera');
  final _emailController =
      TextEditingController(text: 'kavinda.perera@email.lk');
  final _phoneController = TextEditingController(text: '77 458 9210');
  final _passwordController = TextEditingController(text: 'FinPulse@2026');
  bool _agreeTerms = true;
  late bool _isEmailValid;
  late bool _isPhoneValid;
  String? _emailError;
  String? _phoneError;

  bool _checkEmail(String email) => _emailRegExp.hasMatch(email.trim());
  bool _checkPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return _phoneRegExp.hasMatch(clean);
  }

  PasswordStrength _evaluatePasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    if (password.length < 6) return PasswordStrength.weak;

    int lengthPoints;
    if (password.length >= 16) {
      lengthPoints = 4;
    } else if (password.length >= 12) {
      lengthPoints = 3;
    } else if (password.length >= 8) {
      lengthPoints = 2;
    } else {
      lengthPoints = 1;
    }

    int diversityCount = 0;
    if (RegExp(r'[a-z]').hasMatch(password)) diversityCount++;
    if (RegExp(r'[A-Z]').hasMatch(password)) diversityCount++;
    if (RegExp(r'[0-9]').hasMatch(password)) diversityCount++;
    if (RegExp(r'[!@#\$%^&*()_\-+=\[\]{};:\x27",.<>?/\\|~`]').hasMatch(password)) diversityCount++;

    final varietyBonus = diversityCount >= 3 ? 1 : 0;
    final totalScore = lengthPoints + diversityCount + varietyBonus;

    if (diversityCount >= 2 && (totalScore >= 6 || password.length >= 14)) {
      return PasswordStrength.strong;
    } else if (totalScore >= 4 || (password.length >= 8 && diversityCount >= 2)) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.weak;
    }
  }

  @override
  void initState() {
    super.initState();
    _isEmailValid = _checkEmail(_emailController.text);
    _isPhoneValid = _checkPhone(_phoneController.text);

    _emailController.addListener(() {
      final isValid = _checkEmail(_emailController.text);
      if (isValid != _isEmailValid || _emailError != null) {
        setState(() {
          _isEmailValid = isValid;
          if (isValid) _emailError = null;
        });
      }
    });

    _phoneController.addListener(() {
      final isValid = _checkPhone(_phoneController.text);
      if (isValid != _isPhoneValid || _phoneError != null) {
        setState(() {
          _isPhoneValid = isValid;
          if (isValid) _phoneError = null;
        });
      }
    });

    _passwordController.addListener(() {
      setState(() {});
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
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name.')),
      );
      return;
    }

    if (email.isEmpty || !_checkEmail(email)) {
      setState(() => _emailError = 'Please enter a valid email address');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address (e.g. name@domain.lk).')),
      );
      return;
    }

    if (phone.isEmpty || !_checkPhone(phone)) {
      setState(() => _phoneError = 'Valid Sri Lankan mobile number required');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Sri Lankan mobile number (e.g. 77 458 9210).')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters long.')),
      );
      return;
    }

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service & Privacy Policy.'),
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).register(
          name,
          email,
          password,
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

    final pwdText = _passwordController.text;
    final strength = _evaluatePasswordStrength(pwdText);
    Color segment1Color = AppColors.darkBorder;
    Color segment2Color = AppColors.darkBorder;
    Color segment3Color = AppColors.darkBorder;
    String strengthLabel = 'Enter password';
    Color labelColor = AppColors.textSecondary;

    switch (strength) {
      case PasswordStrength.empty:
        segment1Color = AppColors.darkBorder;
        segment2Color = AppColors.darkBorder;
        segment3Color = AppColors.darkBorder;
        strengthLabel = 'Enter password';
        labelColor = AppColors.textSecondary;
        break;
      case PasswordStrength.weak:
        segment1Color = AppColors.error;
        segment2Color = AppColors.darkBorder;
        segment3Color = AppColors.darkBorder;
        strengthLabel = 'Weak password';
        labelColor = AppColors.error;
        break;
      case PasswordStrength.medium:
        segment1Color = AppColors.warning;
        segment2Color = AppColors.warning;
        segment3Color = AppColors.darkBorder;
        strengthLabel = 'Medium strength';
        labelColor = AppColors.warning;
        break;
      case PasswordStrength.strong:
        segment1Color = AppColors.primary;
        segment2Color = AppColors.primary;
        segment3Color = AppColors.primary;
        strengthLabel = 'Strong password ✓';
        labelColor = AppColors.primary;
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

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
              const SizedBox(height: 18),

              // MOBILE NUMBER (FOR OTP & ALERTS)
              FinPulseTextField(
                label: 'Mobile Number (For OTP & Alerts)',
                hintText: '77 458 9210',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                isUppercaseLabel: true,
                errorText: _phoneError,
                suffixWidget: _phoneController.text.trim().isNotEmpty
                    ? (_isPhoneValid
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

              // Password Strength Meter (3 Segments + Label)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: segment1Color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: segment2Color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: segment3Color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    strengthLabel,
                    style: TextStyle(
                      color: labelColor,
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
                    behavior: HitTestBehavior.opaque,
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
