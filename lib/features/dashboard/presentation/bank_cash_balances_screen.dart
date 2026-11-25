import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_colors.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/presentation/add_transaction_screen.dart';
import '../models/balance_account_model.dart';
import '../providers/balances_provider.dart';

enum BalanceFilter { all, bank, cash }

class BankCashBalancesScreen extends ConsumerStatefulWidget {
  const BankCashBalancesScreen({super.key});

  @override
  ConsumerState<BankCashBalancesScreen> createState() =>
      _BankCashBalancesScreenState();
}

class _BankCashBalancesScreenState
    extends ConsumerState<BankCashBalancesScreen> {
  BalanceFilter _selectedFilter = BalanceFilter.all;
  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'en_US');

  String _formatLkr(double amount) => 'LKR ${_currencyFormat.format(amount)}';

  String _formatPercent(double value) => '${value.toStringAsFixed(1)}%';

  void _openAddIncomeScreen() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) =>
            const AddTransactionScreen(initialType: TransactionType.income),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balancesState = ref.watch(balancesProvider);
    final accentColor = ref.watch(accentColorProvider).color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = AppColors.getBg(isDark);
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);

    final isAccentDark =
        ThemeData.estimateBrightnessForColor(accentColor) == Brightness.dark;
    final heroTextColor = isAccentDark ? Colors.white : const Color(0xFF0C0F14);
    final heroSubtextColor = isAccentDark
        ? Colors.white70
        : const Color(0xFF18230A);

    final bankAccounts = balancesState.bankAccounts;
    final cashWallets = balancesState.cashWallets;
    final showBanks =
        _selectedFilter == BalanceFilter.all ||
        _selectedFilter == BalanceFilter.bank;
    final showCash =
        _selectedFilter == BalanceFilter.all ||
        _selectedFilter == BalanceFilter.cash;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Back Button + Title
              Row(
                children: [
                  GestureDetector(
                    key: const Key('balances_back_button'),
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Bank & Cash Balances',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Hero Total Liquid Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Liquid Balance (Bank + Cash):',
                      style: TextStyle(
                        color: heroSubtextColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatLkr(balancesState.totalLiquidBalance),
                      style: TextStyle(
                        color: heroTextColor,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _buildHeroSplitPill(
                            label:
                                'Bank Total (${_formatPercent(balancesState.bankPercentage)})',
                            value: _formatLkr(balancesState.bankTotal),
                            valueColor: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildHeroSplitPill(
                            label:
                                'Cash Total (${_formatPercent(balancesState.cashPercentage)})',
                            value: _formatLkr(balancesState.cashTotal),
                            valueColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Quick Actions Row: Add Income -> Record Inflow screen, Add Account/Wallet
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      key: const Key('balances_add_income_button'),
                      onTap: _openAddIncomeScreen,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(
                            alpha: isDark ? 0.14 : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.55),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.south_west_rounded,
                              color: AppColors.secondary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Add Income',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.secondary
                                    : const Color(0xFF0369A1),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      key: const Key('balances_add_account_button'),
                      onTap: () => _showAddAccountSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              color: textPrimary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Add Account',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterPill(
                      filter: BalanceFilter.all,
                      label: 'All (${balancesState.accounts.length})',
                      accentColor: accentColor,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 10),
                    _buildFilterPill(
                      filter: BalanceFilter.bank,
                      label: 'Bank Accounts (${bankAccounts.length})',
                      accentColor: accentColor,
                      isDark: isDark,
                      tintedOutline: true,
                    ),
                    const SizedBox(width: 10),
                    _buildFilterPill(
                      filter: BalanceFilter.cash,
                      label: 'Cash Wallets (${cashWallets.length})',
                      accentColor: accentColor,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Linked Bank Accounts Section
              if (showBanks) ...[
                _buildSectionHeader(
                  title: 'LINKED BANK ACCOUNTS (${bankAccounts.length})',
                  totalText: _formatLkr(balancesState.bankTotal),
                  totalColor: AppColors.secondary,
                  titleColor: textSecondary,
                ),
                const SizedBox(height: 12),
                if (bankAccounts.isEmpty)
                  _buildEmptySectionCard(
                    icon: Icons.account_balance_outlined,
                    title: 'No bank accounts added yet',
                    subtitle: 'Tap to add your first bank account',
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    accentColor: AppColors.secondary,
                    onTap: () => _showAddAccountSheet(
                      context,
                      initialType: BalanceAccountType.bank,
                    ),
                  )
                else
                  ...bankAccounts.map(
                    (account) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildAccountCard(
                        account: account,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        accentColor: accentColor,
                        isDark: isDark,
                      ),
                    ),
                  ),
              ],

              if (showBanks && showCash) const SizedBox(height: 12),

              // Cash in Hand Section
              if (showCash) ...[
                _buildSectionHeader(
                  title: 'CASH IN HAND (${cashWallets.length})',
                  totalText: _formatLkr(balancesState.cashTotal),
                  totalColor: isDark ? accentColor : AppColors.primaryDark,
                  titleColor: textSecondary,
                ),
                const SizedBox(height: 12),
                if (cashWallets.isEmpty)
                  _buildEmptySectionCard(
                    icon: Icons.payments_outlined,
                    title: 'No cash wallets added yet',
                    subtitle: 'Tap to track physical wallet or cash reserve',
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    accentColor: isDark ? accentColor : AppColors.primaryDark,
                    onTap: () => _showAddAccountSheet(
                      context,
                      initialType: BalanceAccountType.cash,
                    ),
                  )
                else
                  ...cashWallets.map(
                    (wallet) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCashCard(
                        account: wallet,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        accentColor: accentColor,
                        isDark: isDark,
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(color: textSecondary, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            Icon(Icons.add_circle_outline_rounded, color: accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSplitPill({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0F14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill({
    required BalanceFilter filter,
    required String label,
    required Color accentColor,
    required bool isDark,
    bool tintedOutline = false,
  }) {
    final isSelected = _selectedFilter == filter;
    final isAccentDark =
        ThemeData.estimateBrightnessForColor(accentColor) == Brightness.dark;
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);

    final Color bgColor;
    final Color effectiveBorder;
    final Color textColor;

    if (isSelected) {
      bgColor = accentColor;
      effectiveBorder = accentColor;
      textColor = isAccentDark ? Colors.white : const Color(0xFF0C0F14);
    } else if (tintedOutline) {
      bgColor = cardBg;
      effectiveBorder = accentColor.withValues(alpha: isDark ? 0.5 : 0.7);
      textColor = isDark ? accentColor : AppColors.primaryDark;
    } else {
      bgColor = cardBg;
      effectiveBorder = borderColor;
      textColor = textSecondary;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: effectiveBorder, width: 1.1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String totalText,
    required Color totalColor,
    required Color titleColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        Text(
          totalText,
          style: TextStyle(
            color: totalColor,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard({
    required BalanceAccount account,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color accentColor,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => _showEditBalanceSheet(context, account),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            _buildBrandLogo(account.brand, accentColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (account.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      account.subtitle!,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _formatLkr(account.balance),
              style: TextStyle(
                color: textPrimary,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashCard({
    required BalanceAccount account,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color accentColor,
    required bool isDark,
  }) {
    final effectiveBorder = account.isHighlighted
        ? accentColor.withValues(alpha: isDark ? 0.38 : 0.65)
        : borderColor;

    return GestureDetector(
      onTap: () => _showEditBalanceSheet(context, account),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: account.isHighlighted && isDark
              ? Color.alphaBlend(accentColor.withValues(alpha: 0.05), cardBg)
              : cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: effectiveBorder),
        ),
        child: Row(
          children: [
            _buildBrandLogo(account.brand, accentColor, size: 36),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                account.name,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _formatLkr(account.balance),
              style: TextStyle(
                color: textPrimary,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandLogo(
    BalanceBrand brand,
    Color accentColor, {
    double size = 44,
  }) {
    switch (brand) {
      case BalanceBrand.commercialBank:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF0072BC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance, color: Colors.white, size: 18),
              SizedBox(height: 1),
              Text(
                'COMBANK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 6.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        );
      case BalanceBrand.sampathBank:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF59E0B), width: 1.6),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.brightness_7_rounded,
                color: Color(0xFFEA580C),
                size: 18,
              ),
              Text(
                'Sampath',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      case BalanceBrand.hattonNationalBank:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
          ),
          child: Center(
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'HNB',
                    style: TextStyle(
                      color: Color(0xFF0284C7),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case BalanceBrand.physicalWallet:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF59E0B), width: 1.4),
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Color(0xFF92400E),
            size: 20,
          ),
        );
      case BalanceBrand.homeCashReserve:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF22C55E), width: 1.4),
          ),
          child: const Icon(
            Icons.home_rounded,
            color: Color(0xFF16A34A),
            size: 21,
          ),
        );
      case BalanceBrand.genericBank:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.45),
            ),
          ),
          child: const Icon(
            Icons.account_balance_rounded,
            color: AppColors.secondary,
            size: 22,
          ),
        );
      case BalanceBrand.genericCash:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accentColor.withValues(alpha: 0.45)),
          ),
          child: Icon(Icons.payments_rounded, color: accentColor, size: 20),
        );
    }
  }

  void _showAddAccountSheet(
    BuildContext context, {
    BalanceAccountType initialType = BalanceAccountType.bank,
  }) {
    final nameController = TextEditingController();
    final subtitleController = TextEditingController();
    final balanceController = TextEditingController();
    BalanceAccountType selectedType = initialType;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final cardBg = AppColors.getCard(isDark);
        final inputBg = AppColors.getInput(isDark);
        final borderColor = AppColors.getBorder(isDark);
        final textPrimary = AppColors.getTextPrimary(isDark);
        final textSecondary = AppColors.getTextSecondary(isDark);
        final accentColor = ref.read(accentColorProvider).color;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Add Account or Wallet',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeChoice(
                            label: 'Bank Account',
                            selected: selectedType == BalanceAccountType.bank,
                            accentColor: accentColor,
                            borderColor: borderColor,
                            textSecondary: textSecondary,
                            onTap: () => setModalState(
                              () => selectedType = BalanceAccountType.bank,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTypeChoice(
                            label: 'Cash Wallet',
                            selected: selectedType == BalanceAccountType.cash,
                            accentColor: accentColor,
                            borderColor: borderColor,
                            textSecondary: textSecondary,
                            onTap: () => setModalState(
                              () => selectedType = BalanceAccountType.cash,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      key: const Key('add_account_name_field'),
                      controller: nameController,
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        hintText: selectedType == BalanceAccountType.bank
                            ? 'Bank name (e.g. Commercial Bank)'
                            : 'Wallet name (e.g. Physical Wallet)',
                        hintStyle: TextStyle(color: textSecondary),
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                    ),
                    if (selectedType == BalanceAccountType.bank) ...[
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('add_account_subtitle_field'),
                        controller: subtitleController,
                        style: TextStyle(color: textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Account label (e.g. Savings •••• 4821)',
                          hintStyle: TextStyle(color: textSecondary),
                          filled: true,
                          fillColor: inputBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: borderColor),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('add_account_balance_field'),
                      controller: balanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        prefixText: 'LKR ',
                        prefixStyle: TextStyle(
                          color: textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                        hintText: 'Opening balance',
                        hintStyle: TextStyle(color: textSecondary),
                        filled: true,
                        fillColor: inputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        key: const Key('save_account_button'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: const Color(0xFF0C0F14),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final parsed = double.tryParse(
                            balanceController.text.replaceAll(',', '').trim(),
                          );
                          if (name.isEmpty || parsed == null) {
                            return;
                          }
                          await ref
                              .read(balancesProvider.notifier)
                              .addAccount(
                                name: name,
                                subtitle:
                                    selectedType == BalanceAccountType.bank
                                    ? subtitleController.text.trim()
                                    : null,
                                balance: parsed,
                                type: selectedType,
                              );
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                        child: const Text(
                          'Save Balance',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTypeChoice({
    required String label,
    required bool selected,
    required Color accentColor,
    required Color borderColor,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? accentColor : borderColor),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF0C0F14) : textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  void _showEditBalanceSheet(BuildContext context, BalanceAccount account) {
    final controller = TextEditingController(
      text: account.balance.toStringAsFixed(0),
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final cardBg = AppColors.getCard(isDark);
        final inputBg = AppColors.getInput(isDark);
        final borderColor = AppColors.getBorder(isDark);
        final textPrimary = AppColors.getTextPrimary(isDark);
        final textSecondary = AppColors.getTextSecondary(isDark);
        final accentColor = ref.read(accentColorProvider).color;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Update ${account.name}',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const Key('delete_account_button'),
                      tooltip: 'Delete account',
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                      ),
                      onPressed: () async {
                        await ref
                            .read(balancesProvider.notifier)
                            .deleteAccount(account.id);
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    prefixText: 'LKR ',
                    prefixStyle: TextStyle(
                      color: textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                    filled: true,
                    fillColor: inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: borderColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: const Color(0xFF0C0F14),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      final parsed = double.tryParse(
                        controller.text.replaceAll(',', '').trim(),
                      );
                      if (parsed == null) return;
                      await ref
                          .read(balancesProvider.notifier)
                          .updateBalance(account.id, parsed);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                    child: const Text(
                      'Update Balance',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
