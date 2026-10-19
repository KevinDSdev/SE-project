import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class FinPulsePrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const FinPulsePrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: const Color(0xFF0C0F14),
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF0C0F14),
                ),
              )
            : Text(text),
      ),
    );
  }
}

class FinPulseCircleButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;

  const FinPulseCircleButton({
    super.key,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.darkButton,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.darkBorder, width: 0.8),
        ),
        child: Center(child: icon),
      ),
    );
  }
}

class FinPulseCurrencyBadge extends StatelessWidget {
  final String label;

  const FinPulseCurrencyBadge({
    super.key,
    this.label = 'LK (LKR)',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.darkButton,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Color(0xFFFF5722),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class FinPulseSocialButtons extends StatelessWidget {
  final VoidCallback? onAppleTap;
  final VoidCallback? onGoogleTap;

  const FinPulseSocialButtons({
    super.key,
    this.onAppleTap,
    this.onGoogleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Apple button
        Expanded(
          child: InkWell(
            onTap: onAppleTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.darkInput,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.darkBorder, width: 1),
              ),
              child: const Center(
                child: Icon(
                  Icons.apple,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Google button
        Expanded(
          child: InkWell(
            onTap: onGoogleTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.darkInput,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.darkBorder, width: 1),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            color: Color(0xFF4285F4),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'sans-serif',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
