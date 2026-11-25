import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prot/core/services/app_preferences_service.dart';
import 'package:prot/core/theme/app_theme.dart';
import 'package:prot/features/dashboard/data/balances_repository.dart';
import 'package:prot/features/dashboard/data/balances_storage.dart';
import 'package:prot/features/dashboard/models/balance_account_model.dart';
import 'package:prot/features/dashboard/presentation/bank_cash_balances_screen.dart';
import 'package:prot/features/dashboard/presentation/dashboard_screen.dart';
import 'package:prot/features/dashboard/providers/balances_provider.dart';
import 'package:prot/features/navigation/main_wrapper.dart';
import 'package:prot/features/transactions/presentation/add_transaction_screen.dart';

class _InMemoryBalancesStorage implements BalancesStorage {
  final Map<String, BalanceAccount> _store = {};
  bool _open = false;

  @override
  bool get isOpen => _open;

  @override
  Future<Object> init() async {
    _open = true;
    return this;
  }

  @override
  Future<List<BalanceAccount>> getAllAccounts() async => _store.values.toList();

  @override
  Future<void> upsertAccount(
    BalanceAccount account, {
    DateTime? timestamp,
  }) async {
    _store[account.id] = account;
  }

  @override
  Future<void> deleteAccount(String id) async {
    _store.remove(id);
  }

  @override
  Future<void> close() async {
    _open = false;
  }
}

void main() {
  late _InMemoryBalancesStorage storage;
  late BalancesRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppPreferencesService.resetForTesting();
    await AppPreferencesService.init();

    storage = _InMemoryBalancesStorage();
    repository = BalancesRepository(storage: storage);
    await repository.init();
  });

  testWidgets(
    'starts empty with no placeholder accounts and navigates from dashboard eye icon',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [balancesRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const MainWrapper(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('dashboard_balances_eye_button')));
      await tester.pumpAndSettle();

      expect(find.byType(BankCashBalancesScreen), findsOneWidget);
      expect(find.text('Bank & Cash Balances'), findsOneWidget);
      expect(find.text('LKR 0'), findsWidgets);
      expect(find.text('All (0)'), findsOneWidget);
      expect(find.text('No bank accounts added yet'), findsOneWidget);
      expect(find.text('No cash wallets added yet'), findsOneWidget);
      expect(find.text('Commercial Bank'), findsNothing);
      expect(find.text('Sampath Bank'), findsNothing);

      // Back button returns to Dashboard
      await tester.tap(find.byKey(const Key('balances_back_button')));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Add Income button opens AddTransactionScreen on Record Inflow (Income) tab',
    (tester) async {
      await repository.upsertAccount(
        const BalanceAccount(
          id: 'acct_1',
          name: 'Commercial Bank',
          subtitle: 'Savings •••• 4821',
          balance: 500000,
          type: BalanceAccountType.bank,
          brand: BalanceBrand.commercialBank,
        ),
      );
      await repository.reload();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [balancesRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const BankCashBalancesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('balances_add_income_button')));
      await tester.pumpAndSettle();

      expect(find.byType(AddTransactionScreen), findsOneWidget);
      expect(find.text('Record Inflow'), findsOneWidget);
      expect(find.text('Confirm & Record Income'), findsOneWidget);
      expect(find.text('Deposit into Commercial Bank'), findsOneWidget);
      expect(find.text('Current Balance: LKR 500,000'), findsOneWidget);
    },
  );

  testWidgets('adding bank account & cash wallet persists and filters cleanly', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [balancesRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const BankCashBalancesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Top-right + button is removed; use Add Account button in the middle
    expect(find.byKey(const Key('balances_add_button')), findsNothing);
    await tester.tap(find.byKey(const Key('balances_add_account_button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('add_account_name_field')),
      'Commercial Bank',
    );
    await tester.enterText(
      find.byKey(const Key('add_account_subtitle_field')),
      'Savings •••• 4821',
    );
    await tester.enterText(
      find.byKey(const Key('add_account_balance_field')),
      '200000',
    );
    await tester.tap(find.byKey(const Key('save_account_button')));
    await tester.pumpAndSettle();

    expect(find.text('Commercial Bank'), findsOneWidget);
    expect(find.text('All (1)'), findsOneWidget);
    expect(find.text('Bank Accounts (1)'), findsOneWidget);

    // Persisted in storage backend
    final persisted = await storage.getAllAccounts();
    expect(persisted.length, 1);
    expect(persisted.first.name, 'Commercial Bank');
    expect(persisted.first.balance, 200000);

    // Filter to Cash Wallets (empty)
    await tester.tap(find.text('Cash Wallets (0)'));
    await tester.pumpAndSettle();
    expect(find.text('Commercial Bank'), findsNothing);
    expect(find.text('No cash wallets added yet'), findsOneWidget);
  });
}
