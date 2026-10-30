import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/presentation/transaction_details_edit_screen.dart';
import '../../transactions/providers/transactions_provider.dart';

enum HistoryCategoryFilter {
  all,
  groceries,
  utilities,
  housing,
  transport,
  food,
  savings,
  entertainment,
}

enum HistorySortOption { newest, oldest, highest, lowest }

class AnalyticsScreen extends ConsumerStatefulWidget {
  final HistoryCategoryFilter initialCategory;
  final String? initialSearchQuery;

  const AnalyticsScreen({
    super.key,
    this.initialCategory = HistoryCategoryFilter.all,
    this.initialSearchQuery,
  });

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late String _searchQuery;
  late HistoryCategoryFilter _selectedCategory;
  HistorySortOption _selectedSort = HistorySortOption.newest;

  final currencyFormat = NumberFormat('#,##0', 'en_US');

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _searchQuery = widget.initialSearchQuery ?? '';
    if (_searchQuery.isNotEmpty) {
      _searchController.text = _searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Sort Transactions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _buildSortTile('Newest First', HistorySortOption.newest),
                _buildSortTile('Oldest First', HistorySortOption.oldest),
                _buildSortTile('Highest Amount', HistorySortOption.highest),
                _buildSortTile('Lowest Amount', HistorySortOption.lowest),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortTile(String title, HistorySortOption option) {
    final isSelected = _selectedSort == option;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : Colors.white,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() => _selectedSort = option);
        Navigator.pop(context);
      },
    );
  }

  List<TransactionModel> _applyFilters(List<TransactionModel> list) {
    var result = list.where((item) {
      // 1. Text Search Filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesMerchant = item.merchant.toLowerCase().contains(q);
        final matchesSubtitle = item.subtitle.toLowerCase().contains(q);
        final matchesNote = item.note?.toLowerCase().contains(q) ?? false;
        if (!matchesMerchant && !matchesSubtitle && !matchesNote) {
          return false;
        }
      }

      // 2. Category Filter
      switch (_selectedCategory) {
        case HistoryCategoryFilter.all:
          return true;
        case HistoryCategoryFilter.groceries:
          return item.category == TransactionCategoryType.groceries;
        case HistoryCategoryFilter.utilities:
          return item.category == TransactionCategoryType.bills;
        case HistoryCategoryFilter.housing:
          return item.category == TransactionCategoryType.housing;
        case HistoryCategoryFilter.transport:
          return item.category == TransactionCategoryType.transport;
        case HistoryCategoryFilter.food:
          return item.category == TransactionCategoryType.dining;
        case HistoryCategoryFilter.savings:
          return item.category == TransactionCategoryType.savings ||
              (item.note?.toLowerCase().contains('saving') ?? false);
        case HistoryCategoryFilter.entertainment:
          return item.category == TransactionCategoryType.entertainment ||
              (item.note?.toLowerCase().contains('entertainment') ?? false);
      }
    }).toList();

    // 3. Sorting
    switch (_selectedSort) {
      case HistorySortOption.newest:
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case HistorySortOption.oldest:
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case HistorySortOption.highest:
        result.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case HistorySortOption.lowest:
        result.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return result;
  }

  // Merchant Avatar resolver matching design
  Widget _buildMerchantAvatar(TransactionModel item) {
    final lower = item.merchant.toLowerCase();

    if (lower.contains('keells')) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFF007A3D),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'Keells',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    } else if (lower.contains('dialog')) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CustomPaint(painter: _DialogTrianglesPainter()),
          ),
        ),
      );
    } else if (lower.contains('pizza')) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFFD61827),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 1.5),
              const Text(
                'Pizza\nHut',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  height: 0.9,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (lower.contains('ceb') || lower.contains('electricity')) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFFEAB308), // CEB Yellow
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const Icon(
              Icons.electric_bolt_rounded,
              color: Color(0xFFDC2626), // CEB Red
              size: 20,
            ),
          ),
        ),
      );
    } else if (lower.contains('rent') || lower.contains('apartment')) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.domain_rounded, color: Color(0xFF1E293B), size: 22),
        ),
      );
    } else if (lower.contains('pickme')) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFFFBBF24), // PickMe Yellow
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.person_pin_circle_rounded,
            color: Color(0xFF0C0F14),
            size: 24,
          ),
        ),
      );
    } else if (lower.contains('salary') || lower.contains('techlabs')) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 26,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Center(
              child: Text(
                'TL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: item.type == TransactionType.income
              ? const Color(0xFF162738)
              : const Color(0xFF281E38),
          shape: BoxShape.circle,
        ),
        child: Icon(
          item.type == TransactionType.income
              ? Icons.south_west_rounded
              : Icons.storefront_rounded,
          color: item.type == TransactionType.income
              ? const Color(0xFF38BDF8)
              : const Color(0xFFA855F7),
          size: 20,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionsProvider);
    final filteredList = _applyFilters(txState.transactions);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0F14),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        ref.read(selectedTabProvider.notifier).setTab(0);
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161922),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  // Title: "Transaction History"
                  const Text(
                    'Transaction History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  // Filter / Tune Button
                  GestureDetector(
                    onTap: _showSortFilterSheet,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161922),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.filter_list_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 6),

                    // Search Bar
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161922),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() => _searchQuery = val.trim());
                              },
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Search',
                                hintStyle: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14.5,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Monthly Summary Card: "October 2026 • 142 Logged Transactions • LKR 318,500 Total Outflow"
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131722),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF1E2332),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'October 2026',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '142 Logged Transactions',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'LKR ${currencyFormat.format(txState.spentBudget)}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Total Outflow',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Filter Chips: All (142), Groceries, Utilities, Housing, Transport, Food
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'All (142)',
                            filter: HistoryCategoryFilter.all,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Groceries',
                            filter: HistoryCategoryFilter.groceries,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Utilities',
                            filter: HistoryCategoryFilter.utilities,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Housing',
                            filter: HistoryCategoryFilter.housing,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Transport',
                            filter: HistoryCategoryFilter.transport,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Food',
                            filter: HistoryCategoryFilter.food,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Savings',
                            filter: HistoryCategoryFilter.savings,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Entertainment',
                            filter: HistoryCategoryFilter.entertainment,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Transactions Cards List
                    if (filteredList.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No transactions found',
                            style: TextStyle(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.8,
                              ),
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
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          return _buildTransactionCard(item);
                        },
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required HistoryCategoryFilter filter,
  }) {
    final isSelected = _selectedCategory == filter;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = filter);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFF161922),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.darkBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFF0C0F14)
                : AppColors.textSecondary,
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel item) {
    final isIncome = item.type == TransactionType.income;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailsEditScreen(transaction: item),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF131722),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isIncome
                ? AppColors.primary.withValues(alpha: 0.35)
                : const Color(0xFF1E2332),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Merchant Logo
            _buildMerchantAvatar(item),
            const SizedBox(width: 14),

            // Merchant details (Title & subtitle)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.merchant,
                    style: TextStyle(
                      color: isIncome ? AppColors.primary : Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '${isIncome ? '+' : '-'}LKR ${currencyFormat.format(item.amount)}',
              style: TextStyle(
                color: isIncome ? AppColors.primary : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
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
