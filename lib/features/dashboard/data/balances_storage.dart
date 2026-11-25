import '../models/balance_account_model.dart';

/// Platform-agnostic persistence contract for Bank & Cash Balances.
///
/// Native platforms use SQLite ([BalancesDb]); Flutter Web uses IndexedDB
/// ([BalancesWebDb]).
abstract class BalancesStorage {
  bool get isOpen;

  Future<Object> init();

  Future<List<BalanceAccount>> getAllAccounts();

  Future<void> upsertAccount(BalanceAccount account, {DateTime? timestamp});

  Future<void> deleteAccount(String id);

  Future<void> close();
}
