import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prot/main.dart';
import 'package:prot/core/constants/app_strings.dart';

void main() {
  testWidgets('App renders onboarding smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ProtApp(),
      ),
    );

    // Verify that the app brand name and onboarding text is displayed
    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.skip), findsOneWidget);
  });
}
