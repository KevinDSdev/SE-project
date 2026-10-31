import 'package:flutter/material.dart';

class FinPulseLogo extends StatelessWidget {
  final double size;
  final bool withHalo;

  const FinPulseLogo({
    super.key,
    this.size = 60,
    this.withHalo = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final logoWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: size * 0.08,
              height: size * 0.32,
              decoration: BoxDecoration(
                color: const Color(0xFF0C0F14),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(width: size * 0.06),
            Container(
              width: size * 0.08,
              height: size * 0.46,
              decoration: BoxDecoration(
                color: const Color(0xFF0C0F14),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(width: size * 0.06),
            Container(
              width: size * 0.08,
              height: size * 0.60,
              decoration: BoxDecoration(
                color: const Color(0xFF0C0F14),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );

    if (!withHalo) {
      return logoWidget;
    }

    return Container(
      width: size * 1.55,
      height: size * 1.55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withValues(alpha: 0.08),
        border: Border.all(
          color: primary.withValues(alpha: 0.18),
          width: 1.5,
        ),
      ),
      child: Center(child: logoWidget),
    );
  }
}
