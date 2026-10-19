import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prot/main.dart';

void main() {
  testWidgets('App renders login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FinPulseApp(),
      ),
    );

    // Verify header and primary action button
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to manage your finances'), findsOneWidget);
    expect(find.text('Sign In →'), findsOneWidget);
  });
}
