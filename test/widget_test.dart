import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prot/main.dart';
import 'package:prot/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('App renders signup screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FinPulseApp(),
      ),
    );

    // Verify Sign Up header, currency badge, and action button
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('LK (LKR)'), findsOneWidget);
    expect(find.text('Create Account →'), findsOneWidget);
  });

  testWidgets('Login screen renders accurately', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In →'), findsOneWidget);
  });
}
