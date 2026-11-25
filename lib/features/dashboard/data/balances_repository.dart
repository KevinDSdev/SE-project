import '../models/balance_account_model.dart';
import 'balances_storage.dart';
import 'balances_storage_factory.dart';

/// Repository for Bank & Cash Balances backed by [BalancesStorage]
/// (SQLite on native, IndexedDB on web) with a synchronous in-memory cache
/// preloaded at app startup.
class BalancesRepository {
  static BalancesRepository? _instance;

  static BalancesRepository get instance =>
      _instance ??= BalancesRepository();

  static void resetForTesting({BalancesStorage? storage}) {
    _instance = storage != null ? BalancesRepository(storage: storage) : null;
  }

  final BalancesStorage _storage;
  List<BalanceAccount> _cachedAccounts = const [];
  bool _initialized = false;

  BalancesRepository({BalancesStorage? storage})
    : _storage = storage ?? createDefaultBalancesStorage();

  bool get isInitialized => _initialized;

  List<BalanceAccount> get cachedAccounts =>
      List<BalanceAccount>.unmodifiable(_cachedAccounts);

  Future<List<BalanceAccount>> init() async {
    await _storage.init();
    _cachedAccounts = await _storage.getAllAccounts();
    _initialized = true;
    return cachedAccounts;
  }

  Future<List<BalanceAccount>> reload() async {
    if (!_initialized) {
      return init();
    }
    _cachedAccounts = await _storage.getAllAccounts();
    return cachedAccounts;
  }

  Future<void> upsertAccount(BalanceAccount account) async {
    final index = _cachedAccounts.indexWhere((a) => a.id == account.id);
    if (index == -1) {
      _cachedAccounts = [..._cachedAccounts, account];
    } else {
      final updated = List<BalanceAccount>.from(_cachedAccounts);
      updated[index] = account;
      _cachedAccounts = updated;
    }

    if (_initialized || _storage.isOpen) {
      await _storage.upsertAccount(account);
    }
  }

  Future<void> deleteAccount(String id) async {
    _cachedAccounts = _cachedAccounts.where((a) => a.id != id).toList();
    if (_initialized || _storage.isOpen) {
      await _storage.deleteAccount(id);
    }
  }

  Future<void> close() async {
    await _storage.close();
    _initialized = false;
  }
}
