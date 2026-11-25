import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:idb_shim/idb_shim.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:prot/features/dashboard/data/balances_db.dart';
import 'package:prot/features/dashboard/data/balances_repository.dart';
import 'package:prot/features/dashboard/data/balances_web_db.dart';
import 'package:prot/features/dashboard/models/balance_account_model.dart';

void main() {
  sqfliteFfiInit();

  group('BalancesDb (SQLite)', () {
    late Directory tempDir;
    late String dbPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('finpulse_balances_db_');
      dbPath = p.join(tempDir.path, 'balances.db');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('persists accounts across repository restarts (CRUD)', () async {
      final db1 = BalancesDb(
        databasePath: dbPath,
        databaseFactory: databaseFactoryFfi,
      );
      final repo1 = BalancesRepository(storage: db1);
      await repo1.init();
      expect(repo1.cachedAccounts, isEmpty);

      const bank = BalanceAccount(
        id: 'bank_1',
        name: 'Commercial Bank',
        subtitle: 'Savings •••• 4821',
        balance: 945000,
        type: BalanceAccountType.bank,
        brand: BalanceBrand.commercialBank,
      );
      const cash = BalanceAccount(
        id: 'cash_1',
        name: 'Physical Wallet',
        balance: 17500,
        type: BalanceAccountType.cash,
        brand: BalanceBrand.physicalWallet,
      );

      await repo1.upsertAccount(bank);
      await repo1.upsertAccount(cash);
      await repo1.close();

      // Simulate restart with fresh DB + Repository instance
      final db2 = BalancesDb(
        databasePath: dbPath,
        databaseFactory: databaseFactoryFfi,
      );
      final repo2 = BalancesRepository(storage: db2);
      final loaded = await repo2.init();

      expect(loaded.length, 2);
      expect(loaded[0].name, 'Commercial Bank');
      expect(loaded[0].balance, 945000);
      expect(loaded[1].name, 'Physical Wallet');
      expect(loaded[1].balance, 17500);

      // Update and delete
      await repo2.upsertAccount(bank.copyWith(balance: 1000000));
      await repo2.deleteAccount('cash_1');
      final reloaded = await repo2.reload();
      expect(reloaded.length, 1);
      expect(reloaded.first.balance, 1000000);
      await repo2.close();
    });
  });

  group('BalancesWebDb (IndexedDB)', () {
    test('persists, updates, and deletes accounts in IndexedDB', () async {
      final idbFactory = newIdbFactoryMemory();
      final webDb = BalancesWebDb(
        idbFactory: idbFactory,
        databaseName: 'test_balances_web',
      );
      final repo = BalancesRepository(storage: webDb);
      await repo.init();
      expect(repo.cachedAccounts, isEmpty);

      const acct = BalanceAccount(
        id: 'web_1',
        name: 'Sampath Bank',
        subtitle: 'Vishwa •••• 9014',
        balance: 520500,
        type: BalanceAccountType.bank,
        brand: BalanceBrand.sampathBank,
      );
      await repo.upsertAccount(acct);

      final loaded = await repo.reload();
      expect(loaded.length, 1);
      expect(loaded.first.name, 'Sampath Bank');
      expect(loaded.first.balance, 520500);

      await repo.deleteAccount('web_1');
      expect(await repo.reload(), isEmpty);
      await repo.close();
    });
  });
}
