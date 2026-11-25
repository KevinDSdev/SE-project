import 'package:idb_shim/idb_shim.dart';

import '../models/balance_account_model.dart';
import 'balances_storage.dart';

/// IndexedDB persistence backend for Bank & Cash Balances on Flutter Web.
class BalancesWebDb implements BalancesStorage {
  static const String defaultDatabaseName = 'finpulse_balances_web';
  static const int databaseVersion = 1;
  static const String storeName = 'balance_accounts';

  final IdbFactory _idbFactory;
  final String _databaseName;
  Database? _database;

  BalancesWebDb({
    required this._idbFactory,
    this._databaseName = defaultDatabaseName,
  });

  @override
  bool get isOpen => _database != null;

  @override
  Future<Database> init() async {
    if (_database != null) {
      return _database!;
    }
    _database = await _idbFactory.open(
      _databaseName,
      version: databaseVersion,
      onUpgradeNeeded: (VersionChangeEvent event) {
        final db = event.database;
        if (!db.objectStoreNames.contains(storeName)) {
          db.createObjectStore(storeName, keyPath: 'id');
        }
      },
    );
    return _database!;
  }

  Future<Database> get database async => init();

  @override
  Future<List<BalanceAccount>> getAllAccounts() async {
    final db = await database;
    final txn = db.transaction(storeName, idbModeReadOnly);
    final store = txn.objectStore(storeName);
    final items = await store.getAll();
    await txn.completed;

    final accounts = <BalanceAccount>[];
    for (final raw in items) {
      if (raw is Map) {
        final normalized = <String, Object?>{
          for (final entry in raw.entries) entry.key.toString(): entry.value,
        };
        accounts.add(BalanceAccount.fromMap(normalized));
      }
    }
    return accounts;
  }

  @override
  Future<void> upsertAccount(
    BalanceAccount account, {
    DateTime? timestamp,
  }) async {
    final db = await database;
    final txn = db.transaction(storeName, idbModeReadWrite);
    final store = txn.objectStore(storeName);
    await store.put(account.toMap(timestamp: timestamp));
    await txn.completed;
  }

  @override
  Future<void> deleteAccount(String id) async {
    final db = await database;
    final txn = db.transaction(storeName, idbModeReadWrite);
    final store = txn.objectStore(storeName);
    await store.delete(id);
    await txn.completed;
  }

  @override
  Future<void> close() async {
    _database?.close();
    _database = null;
  }
}
