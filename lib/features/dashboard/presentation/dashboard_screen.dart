import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/presentation/add_transaction_screen.dart';
import '../../transactions/providers/transactions_provider.dart';

enum DashboardCategoryFilter { all, groceries, shopping, dining, bills }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DashboardCategoryFilter _selectedCategory = DashboardCategoryFilter.groceries;
  final currencyFormat = NumberFormat('#,##0', 'en_US');

  static Widget _buildKeellsLogo() {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        color: Color(0xFF007A33), // Keells Brand Green
        shape: BoxShape.circle,
      ),
      child: Center(
        child: RichText(
          text: const TextSpan(
            text: 'Keells',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildPizzaHutLogo() {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        color: Color(0xFFD61827), // Pizza Hut Crimson Red
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Pizza\nHut',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                height: 0.9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDialogLogo() {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CustomPaint(
            painter: _DialogTrianglesPainter(),
          ),
        ),
      ),
    );
  }

  Widget _buildGenericLogo(TransactionModel item) {
    Color iconColor;
    Color bgColor;
    IconData icon;

    if (item.type == TransactionType.income) {
      iconColor = const Color(0xFF38BDF8);
      bgColor = const Color(0xFF162738);
      icon = Icons.south_west_rounded;
    } else {
      switch (item.category) {
        case TransactionCategoryType.groceries:
          iconColor = const Color(0xFFF59E0B);
          bgColor = const Color(0xFF2E2419);
          icon = Icons.shopping_bag_outlined;
          break;
        case TransactionCategoryType.dining:
          iconColor = const Color(0xFFA855F7);
          bgColor = const Color(0xFF281E38);
          icon = Icons.restaurant_rounded;
          break;
        case TransactionCategoryType.bills:
          iconColor = const Color(0xFF06B6D4);
          bgColor = const Color(0xFF172533);
          icon = Icons.receipt_long_rounded;
          break;
        case TransactionCategoryType.transport:
          iconColor = const Color(0xFF38BDF8);
          bgColor = const Color(0xFF162738);
          icon = Icons.directions_car_filled_rounded;
          break;
        case TransactionCategoryType.shopping:
          iconColor = const Color(0xFF06B6D4);
          bgColor = const Color(0xFF162B33);
          icon = Icons.shopping_basket_outlined;
          break;
        default:
          iconColor = AppColors.primary;
          bgColor = const Color(0xFF1B2414);
          icon = Icons.account_balance_wallet_rounded;
      }
    }

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }

  Widget _resolveLogo(TransactionModel item) {
    final lower = item.merchant.toLowerCase();
    if (lower.contains('keells')) {
      return _buildKeellsLogo();
    } else if (lower.contains('pizza')) {
      return _buildPizzaHutLogo();
    } else if (lower.contains('dialog')) {
      return _buildDialogLogo();
    }
    return _buildGenericLogo(item);
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionsProvider);
    final transactions = txState.transactions;
    final availableBudget = txState.availableBudget;
    final spentBudget = txState.spentBudget;
    final totalTargetBudget = txState.targetBudget;

    final filteredList = _selectedCategory == DashboardCategoryFilter.all
        ? transactions
        : transactions.where((t) {
            switch (_selectedCategory) {
              case DashboardCategoryFilter.groceries:
                return t.category == TransactionCategoryType.groceries;
              case DashboardCategoryFilter.shopping:
                return t.category == TransactionCategoryType.shopping;
              case DashboardCategoryFilter.dining:
                return t.category == TransactionCategoryType.dining;
              case DashboardCategoryFilter.bills:
                return t.category == TransactionCategoryType.bills;
              default:
                return true;
            }
          }).toList();

    final spendPercentage = (spentBudget / totalTargetBudget * 100).clamp(0, 100).toInt();
    final spendRatio = (spentBudget / totalTargetBudget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: "Your Dashboard" + Profile Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(selectedTabProvider.notifier).setTab(4);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161922),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Hero Lime Green Active Budget Plan Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge: "Active Budget Plan"
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C0F14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Active Budget Plan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subtitle: "Total Available Budget:"
                    const Text(
                      'Total Available Budget:',
                      style: TextStyle(
                        color: Color(0xFF18230A),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Big Amount: "LKR 1,845,000"
                    Text(
                      'LKR ${currencyFormat.format(availableBudget)}',
                      style: const TextStyle(
                        color: Color(0xFF0C0F14),
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Spend Progress text
                    Text(
                      'Monthly Spend Progress: LKR ${currencyFormat.format(spentBudget)} / ${currencyFormat.format(totalTargetBudget)} ($spendPercentage%)',
                      style: const TextStyle(
                        color: Color(0xFF22300C),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Progress Bar
                    Container(
                      width: double.infinity,
                      height: 7,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: spendRatio,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C0F14),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Two Cards Row: "Quick Add Budget" & "Top Budget Goal"
              Row(
                children: [
                  // Quick Add Budget Card -> Navigates to AddTransactionScreen
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddTransactionScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Color(0xFF0C0F14),
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Quick Add Budget',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '+ Tap to create',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Top Budget Goal Card
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(selectedTabProvider.notifier).setTab(3);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Top Budget Goal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Save for Vacation:',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'LKR 310K / 1.2M',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFF262438),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: 0.26,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFA855F7), // Purple fill
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section Header: "Recent Categorized Transactions"
              const Text(
                'Recent Categorized Transactions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 14),

              // Filter Category Chips (Groceries, Shopping, Dining, Bills)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Groceries pill
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = _selectedCategory == DashboardCategoryFilter.groceries
                              ? DashboardCategoryFilter.all
                              : DashboardCategoryFilter.groceries;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2530),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedCategory == DashboardCategoryFilter.groceries
                                ? AppColors.primary
                                : AppColors.darkBorder,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.shopping_bag_outlined,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Groceries',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Shopping Cart button
                    _buildCircularFilterButton(
                      category: DashboardCategoryFilter.shopping,
                      icon: Icons.shopping_cart_outlined,
                      iconColor: const Color(0xFFA855F7),
                      bgColor: const Color(0xFF281E38),
                    ),
                    const SizedBox(width: 10),

                    // Dining / Cutlery button
                    _buildCircularFilterButton(
                      category: DashboardCategoryFilter.dining,
                      icon: Icons.restaurant_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      bgColor: const Color(0xFF2E2419),
                    ),
                    const SizedBox(width: 10),

                    // Bills / Lock button
                    _buildCircularFilterButton(
                      category: DashboardCategoryFilter.bills,
                      icon: Icons.lock_outline_rounded,
                      iconColor: const Color(0xFF06B6D4),
                      bgColor: const Color(0xFF172533),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Transactions List
              if (filteredList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No transactions in this category yet',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredList.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return _buildTransactionTile(item);
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularFilterButton({
    required DashboardCategoryFilter category,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = isSelected ? DashboardCategoryFilter.all : category;
        });
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildTransactionTile(TransactionModel item) {
    final isExpense = item.type == TransactionType.expense;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Merchant Avatar
          _resolveLogo(item),
          const SizedBox(width: 14),

          // Merchant name & timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.merchant,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),

          // Amount & Cashback Tag
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isExpense ? '-' : '+'}LKR ${currencyFormat.format(item.amount)}',
                style: TextStyle(
                  color: isExpense ? Colors.white : const Color(0xFF38BDF8),
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              if (item.cashback > 0)
                Text(
                  '+LKR ${currencyFormat.format(item.cashback)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else if (!isExpense && item.account != null)
                Text(
                  item.account!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom painter for Dialog Axiata multicolored triangles logo
class _DialogTrianglesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Red triangle (top-left)
    paint.color = const Color(0xFFE11D48);
    final path1 = Path()
      ..moveTo(size.width * 0.15, size.height * 0.2)
      ..lineTo(size.width * 0.55, size.height * 0.1)
      ..lineTo(size.width * 0.5, size.height * 0.5)
      ..close();
    canvas.drawPath(path1, paint);

    // Orange/Yellow triangle (bottom-left)
    paint.color = const Color(0xFFF97316);
    final path2 = Path()
      ..moveTo(size.width * 0.15, size.height * 0.2)
      ..lineTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.35, size.height * 0.85)
      ..close();
    canvas.drawPath(path2, paint);

    // Purple triangle (right)
    paint.color = const Color(0xFF8B5CF6);
    final path3 = Path()
      ..moveTo(size.width * 0.55, size.height * 0.1)
      ..lineTo(size.width * 0.85, size.height * 0.45)
      ..lineTo(size.width * 0.5, size.height * 0.5)
      ..close();
    canvas.drawPath(path3, paint);

    // Cyan triangle (bottom-right)
    paint.color = const Color(0xFF06B6D4);
    final path4 = Path()
      ..moveTo(size.width * 0.5, size.height * 0.5)
      ..lineTo(size.width * 0.85, size.height * 0.45)
      ..lineTo(size.width * 0.55, size.height * 0.85)
      ..close();
    canvas.drawPath(path4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
