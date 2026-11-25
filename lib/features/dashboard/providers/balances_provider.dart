import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/balances_repository.dart';
import '../models/balance_account_model.dart';

final balancesRepositoryProvider = Provider<BalancesRepository>(
  (ref) => BalancesRepository.instance,
);

class BalancesState {
  final List<BalanceAccount> accounts;

  const BalancesState({required this.accounts});

  List<BalanceAccount> get bankAccounts =>
      accounts.where((a) => a.type == BalanceAccountType.bank).toList();

  List<BalanceAccount> get cashWallets =>
      accounts.where((a) => a.type == BalanceAccountType.cash).toList();

  double get bankTotal =>
      bankAccounts.fold(0.0, (sum, account) => sum + account.balance);

  double get cashTotal =>
      cashWallets.fold(0.0, (sum, account) => sum + account.balance);

  double get totalLiquidBalance => bankTotal + cashTotal;

  double get bankPercentage =>
      totalLiquidBalance <= 0 ? 0.0 : (bankTotal / totalLiquidBalance) * 100;

  double get cashPercentage =>
      totalLiquidBalance <= 0 ? 0.0 : (cashTotal / totalLiquidBalance) * 100;

  BalanceAccount? findById(String id) {
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  BalancesState copyWith({List<BalanceAccount>? accounts}) {
    return BalancesState(accounts: accounts ?? this.accounts);
  }
}

class BalancesNotifier extends Notifier<BalancesState> {
  BalancesRepository get _repository => ref.read(balancesRepositoryProvider);

  @override
  BalancesState build() {
    return BalancesState(accounts: _repository.cachedAccounts);
  }

  static BalanceBrand inferBrand(String name, BalanceAccountType type) {
    final lower = name.toLowerCase();
    if (type == BalanceAccountType.bank) {
      if (lower.contains('commercial') || lower.contains('combank')) {
        return BalanceBrand.commercialBank;
      }
      if (lower.contains('sampath')) {
        return BalanceBrand.sampathBank;
      }
      if (lower.contains('hatton') || lower.contains('hnb')) {
        return BalanceBrand.hattonNationalBank;
      }
      return BalanceBrand.genericBank;
    }
    if (lower.contains('home') || lower.contains('reserve')) {
      return BalanceBrand.homeCashReserve;
    }
    if (lower.contains('wallet') || lower.contains('daily')) {
      return BalanceBrand.physicalWallet;
    }
    return BalanceBrand.genericCash;
  }

  Future<BalanceAccount?> addAccount({
    required String name,
    String? subtitle,
    required double balance,
    required BalanceAccountType type,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return null;

    final newAccount = BalanceAccount(
      id: 'acct_${DateTime.now().microsecondsSinceEpoch}',
      name: trimmedName,
      subtitle: subtitle != null && subtitle.trim().isNotEmpty
          ? subtitle.trim()
          : null,
      balance: balance < 0 ? 0 : balance,
      type: type,
      brand: inferBrand(trimmedName, type),
    );

    state = state.copyWith(accounts: [...state.accounts, newAccount]);
    await _repository.upsertAccount(newAccount);
    return newAccount;
  }

  Future<void> updateBalance(String id, double newBalance) async {
    final existing = state.findById(id);
    if (existing == null) return;

    final updated = existing.copyWith(balance: newBalance < 0 ? 0 : newBalance);
    state = state.copyWith(
      accounts: state.accounts
          .map((account) => account.id == id ? updated : account)
          .toList(),
    );
    await _repository.upsertAccount(updated);
  }

  Future<void> adjustBalance(String id, double delta) async {
    final existing = state.findById(id);
    if (existing == null) return;
    await updateBalance(id, existing.balance + delta);
  }

  Future<void> deleteAccount(String id) async {
    state = state.copyWith(
      accounts: state.accounts.where((account) => account.id != id).toList(),
    );
    await _repository.deleteAccount(id);
  }
}

final balancesProvider = NotifierProvider<BalancesNotifier, BalancesState>(
  BalancesNotifier.new,
);
