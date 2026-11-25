import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/balance_account_model.dart';
import 'balances_storage.dart';

/// SQLite persistence backend for Bank & Cash Balances on Android/iOS/VM.
class BalancesDb implements BalancesStorage {
  static const String databaseName = 'finpulse_balances.db';
  static const int databaseVersion = 1;
  static const String tableName = 'balance_accounts';

  static const String createTableSql =
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      subtitle TEXT,
      balance REAL NOT NULL DEFAULT 0,
      type TEXT NOT NULL CHECK (type IN ('bank', 'cash')),
      brand TEXT NOT NULL DEFAULT 'genericBank',
      is_highlighted INTEGER NOT NULL DEFAULT 0,
      updated_at TEXT NOT NULL
    )
  ''';

  final String? _customDatabasePath;
  final DatabaseFactory? _customDatabaseFactory;
  Database? _database;

  BalancesDb({String? databasePath, DatabaseFactory? databaseFactory})
    : _customDatabasePath = databasePath,
      _customDatabaseFactory = databaseFactory;

  @override
  bool get isOpen => _database != null && _database!.isOpen;

  Future<String> _resolveDatabasePath() async {
    if (_customDatabasePath != null && _customDatabasePath.isNotEmpty) {
      return _customDatabasePath;
    }
    final factory = _customDatabaseFactory ?? databaseFactory;
    final dbDir = await factory.getDatabasesPath();
    return p.join(dbDir, databaseName);
  }

  @override
  Future<Database> init() async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    final factory = _customDatabaseFactory ?? databaseFactory;
    final dbPath = await _resolveDatabasePath();
    _database = await factory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: databaseVersion,
        onCreate: (db, version) async {
          await db.execute(createTableSql);
        },
        onOpen: (db) async {
          await db.execute(createTableSql);
        },
      ),
    );
    return _database!;
  }

  Future<Database> get database async => init();

  @override
  Future<List<BalanceAccount>> getAllAccounts() async {
    final db = await database;
    final rows = await db.query(tableName, orderBy: 'rowid ASC');
    return rows.map((row) => BalanceAccount.fromMap(row)).toList();
  }

  @override
  Future<void> upsertAccount(
    BalanceAccount account, {
    DateTime? timestamp,
  }) async {
    final db = await database;
    await db.insert(
      tableName,
      account.toMap(timestamp: timestamp),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteAccount(String id) async {
    final db = await database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }
    _database = null;
  }
}
