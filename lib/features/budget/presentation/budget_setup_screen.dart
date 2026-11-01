import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../settings/providers/settings_provider.dart';
import 'budget_progress_screen.dart';

/// Data class representing a Variable Expense Category
class VariableExpenseItem {
  final String id;
  String title;
  double amount;
  Widget iconWidget;

  VariableExpenseItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.iconWidget,
  });
}

/// Data class representing a Fixed Monthly Bill
class FixedBillItem {
  final String id;
  String title;
  double amount;
  String? provider;
  String? dueDate;
  Widget iconWidget;

  FixedBillItem({
    required this.id,
    required this.title,
    required this.amount,
    this.provider,
    this.dueDate,
    required this.iconWidget,
  });
}

/// Screen 01 – Budget Setup Screen
/// Faithfully reproduces Figma Screen 01 from "Dhare Screens/New folder/01 - Budget Setup Screen .png"
class BudgetSetupScreen extends ConsumerStatefulWidget {
  const BudgetSetupScreen({super.key});

  @override
  ConsumerState<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends ConsumerState<BudgetSetupScreen> {
  final currencyFormat = NumberFormat('#,##0', 'en_US');

  // Baseline Monthly Income matching Figma Screen 01
  double _monthlyIncome = 450000;

  // Baseline savings/investment reserved from onboarding
  final double _baselineSavings = 25000;

  // Variable Expense Budgets matching Figma Screen 01
  late List<VariableExpenseItem> _variableExpenses;

  // Fixed Monthly Bills matching Figma Screen 01
  late List<FixedBillItem> _fixedBills;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _variableExpenses = [
      VariableExpenseItem(
        id: 'food_groceries',
        title: 'Food & Groceries',
        amount: 65000,
        iconWidget: _buildLeadingIcon(
          bgColor: Colors.white,
          child: const Center(
            child: Icon(
              Icons.shopping_basket_rounded,
              color: Color(0xFFF59E0B),
              size: 22,
            ),
          ),
        ),
      ),
      VariableExpenseItem(
        id: 'dining_takeout',
        title: 'Dining & Takeout',
        amount: 35000,
        iconWidget: _buildLeadingIcon(
          bgColor: const Color(0xFFE11D48),
          child: const Center(
            child: Icon(
              Icons.restaurant_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      VariableExpenseItem(
        id: 'travel_transport',
        title: 'Travel & Transport',
        amount: 30000,
        iconWidget: _buildLeadingIcon(
          bgColor: Colors.white,
          child: const Center(
            child: Icon(
              Icons.directions_bus_rounded,
              color: Color(0xFF2563EB),
              size: 22,
            ),
          ),
        ),
      ),
    ];

    _fixedBills = [
      FixedBillItem(
        id: 'apartment_rent',
        title: 'Apartment Rent',
        amount: 120000,
        provider: 'Landlord',
        dueDate: 'Day 1 of every month',
        iconWidget: _buildLeadingIcon(
          bgColor: Colors.white,
          child: const Center(
            child: Icon(
              Icons.apartment_rounded,
              color: Color(0xFF334155),
              size: 22,
            ),
          ),
        ),
      ),
      FixedBillItem(
        id: 'ceb_bills',
        title: 'CEB Electricity & Water',
        amount: 45000,
        provider: 'CEB / NWSDB',
        dueDate: 'Day 10 of every month',
        iconWidget: _buildLeadingIcon(
          bgColor: const Color(0xFFFEF08A),
          child: const Center(
            child: Icon(
              Icons.bolt_rounded,
              color: Color(0xFFDC2626),
              size: 24,
            ),
          ),
        ),
      ),
      FixedBillItem(
        id: 'dialog_insurance',
        title: 'Dialog & Insurance',
        amount: 25000,
        provider: 'Dialog Axiata & Ceylinco',
        dueDate: 'Day 15 of every month',
        iconWidget: _buildLeadingIcon(
          bgColor: Colors.white,
          child: const Center(
            child: Icon(
              Icons.change_history_rounded,
              color: Color(0xFFE11D48),
              size: 22,
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildLeadingIcon({required Color bgColor, required Widget child}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  double get _totalVariable =>
      _variableExpenses.fold(0.0, (sum, item) => sum + item.amount);

  double get _totalFixed =>
      _fixedBills.fold(0.0, (sum, item) => sum + item.amount);

  double get _remainingToAllocate =>
      _monthlyIncome - (_totalVariable + _totalFixed + _baselineSavings);

  // Edit Amount Dialog
  void _showEditAmountDialog({
    required String title,
    required double initialValue,
    required ValueChanged<double> onSaved,
  }) {
    final accentColor = ref.read(accentColorProvider).color;
    final controller = TextEditingController(
      text: initialValue.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161922),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF262B36)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            prefixText: 'LKR ',
            prefixStyle: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w700,
            ),
            filled: true,
            fillColor: const Color(0xFF10141D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF262B36)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white60),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: const Color(0xFF0C0F14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final val = double.tryParse(controller.text.trim()) ?? initialValue;
              onSaved(val);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // Add Budget Category Modal (Matching Screen 02A)
  void _showAddCategorySheet() {
    final accentColor = ref.read(accentColorProvider).color;
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    String selectedGroup = 'Needs';
    final groups = ['Bills', 'Needs', 'Wants', 'Savings', 'Custom'];

    int selectedIconIndex = 0;
    final icons = [
      {'icon': Icons.school_rounded, 'color': const Color(0xFFF59E0B), 'bg': Colors.white},
      {'icon': Icons.receipt_long_rounded, 'color': const Color(0xFF8B5CF6), 'bg': Colors.white},
      {'icon': Icons.shopping_basket_rounded, 'color': const Color(0xFFF59E0B), 'bg': Colors.white},
      {'icon': Icons.directions_bus_rounded, 'color': const Color(0xFF2563EB), 'bg': Colors.white},
      {'icon': Icons.savings_rounded, 'color': const Color(0xFF06B6D4), 'bg': Colors.white},
      {'icon': Icons.shopping_bag_rounded, 'color': const Color(0xFF10B981), 'bg': Colors.white},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0C0F14),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
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
                    const SizedBox(height: 16),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add Budget Category',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: const Icon(Icons.close_rounded, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Available to Assign Pill
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Available to Assign:',
                            style: TextStyle(
                              color: Color(0xFF0C0F14),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'LKR ${currencyFormat.format(_remainingToAllocate > 0 ? _remainingToAllocate : 0)}',
                            style: const TextStyle(
                              color: Color(0xFF0C0F14),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Category Information Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131722),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF1E2332)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Category Information',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Category Name',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: nameController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'e.g. Education, Health',
                              hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                              filled: true,
                              fillColor: const Color(0xFF181C26),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFF262C38)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: accentColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Group Selector
                          const Text(
                            'Category Group',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: groups.map((g) {
                                final isSelected = g == selectedGroup;
                                return GestureDetector(
                                  onTap: () => setModalState(() => selectedGroup = g),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF181C26),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isSelected ? accentColor : const Color(0xFF262C38),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      g,
                                      style: TextStyle(
                                        color: isSelected ? accentColor : Colors.white70,
                                        fontSize: 12.5,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Icon Selector
                          const Text(
                            'Category Icon',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(icons.length, (idx) {
                              final isSelected = idx == selectedIconIndex;
                              final iconData = icons[idx];
                              return GestureDetector(
                                onTap: () => setModalState(() => selectedIconIndex = idx),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: iconData['bg'] as Color,
                                    borderRadius: BorderRadius.circular(10),
                                    border: isSelected
                                        ? Border.all(color: accentColor, width: 2)
                                        : Border.all(color: Colors.transparent),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      iconData['icon'] as IconData,
                                      color: iconData['color'] as Color,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Budget Allocation Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131722),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF1E2332)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Budget Allocation',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Assigned Amount (LKR)',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10141D),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: accentColor, width: 1.2),
                            ),
                            child: TextField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: InputDecoration(
                                prefixText: 'LKR ',
                                prefixStyle: TextStyle(
                                  color: accentColor,
                                  fontWeight: FontWeight.w700,
                                ),
                                border: InputBorder.none,
                                hintText: '0',
                                hintStyle: const TextStyle(color: Colors.white30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Add Category Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: const Color(0xFF0C0F14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        onPressed: () {
                          final name = nameController.text.trim();
                          final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                          if (name.isNotEmpty && amount > 0) {
                            final iconInfo = icons[selectedIconIndex];
                            setState(() {
                              _variableExpenses.add(
                                VariableExpenseItem(
                                  id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
                                  title: name,
                                  amount: amount,
                                  iconWidget: _buildLeadingIcon(
                                    bgColor: iconInfo['bg'] as Color,
                                    child: Center(
                                      child: Icon(
                                        iconInfo['icon'] as IconData,
                                        color: iconInfo['color'] as Color,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                          }
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Add Category',
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

  // Add Fixed Bill Modal (Matching Screen 03A)
  void _showAddFixedBillSheet() {
    final accentColor = ref.read(accentColorProvider).color;
    final nameController = TextEditingController();
    final providerController = TextEditingController();
    final amountController = TextEditingController();

    String selectedDueDate = 'Day 5 of every month';
    final dueDates = [
      'Day 1 of every month',
      'Day 5 of every month',
      'Day 10 of every month',
      'Day 15 of every month',
      'Day 25 of every month',
    ];

    int selectedIconIdx = 0;
    final fixedIcons = [
      {'name': 'Internet', 'icon': Icons.language_rounded, 'color': const Color(0xFF0284C7), 'bg': Colors.white},
      {'name': 'Insurance', 'icon': Icons.security_rounded, 'color': const Color(0xFF0D9488), 'bg': Colors.white},
      {'name': 'Rent', 'icon': Icons.home_rounded, 'color': const Color(0xFF334155), 'bg': Colors.white},
      {'name': 'Medicine', 'icon': Icons.medical_services_rounded, 'color': const Color(0xFF0284C7), 'bg': Colors.white},
      {'name': 'Phone', 'icon': Icons.phone_in_talk_rounded, 'color': const Color(0xFFDC2626), 'bg': Colors.white},
      {'name': 'Other', 'icon': Icons.more_horiz_rounded, 'color': Colors.white, 'bg': const Color(0xFF1E2332)},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0C0F14),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
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
                    const SizedBox(height: 16),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add Fixed Bill',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: const Icon(Icons.close_rounded, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Bill Name
                    const Text(
                      'Bill Name',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'e.g., Internet, Insurance',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF131722),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF1E2332)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: accentColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Biller / Provider Name
                    const Text(
                      'Biller / Provider Name',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: providerController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'e.g., SLT-Mobitel',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF131722),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF1E2332)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: accentColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Monthly Amount
                    const Text(
                      'Monthly Amount',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        prefixText: 'LKR ',
                        prefixStyle: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                        ),
                        hintText: '0.00',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF131722),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF1E2332)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: accentColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Due Date
                    const Text(
                      'Due Date',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131722),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF1E2332)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedDueDate,
                          dropdownColor: const Color(0xFF161922),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                          isExpanded: true,
                          items: dueDates.map((date) {
                            return DropdownMenuItem<String>(
                              value: date,
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded, color: Colors.white54, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    date,
                                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedDueDate = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category & Icon
                    const Text(
                      'Category & Icon',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(fixedIcons.length, (idx) {
                        final isSelected = idx == selectedIconIdx;
                        final iconData = fixedIcons[idx];
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedIconIdx = idx),
                          child: Column(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: iconData['bg'] as Color,
                                  borderRadius: BorderRadius.circular(10),
                                  border: isSelected
                                      ? Border.all(color: accentColor, width: 2)
                                      : Border.all(color: Colors.transparent),
                                ),
                                child: Center(
                                  child: Icon(
                                    iconData['icon'] as IconData,
                                    color: iconData['color'] as Color,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                iconData['name'] as String,
                                style: TextStyle(
                                  color: isSelected ? accentColor : Colors.white60,
                                  fontSize: 10.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Add Fixed Bill Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: const Color(0xFF0C0F14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        onPressed: () {
                          final name = nameController.text.trim();
                          final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                          final provider = providerController.text.trim();
                          if (name.isNotEmpty && amount > 0) {
                            final iconInfo = fixedIcons[selectedIconIdx];
                            setState(() {
                              _fixedBills.add(
                                FixedBillItem(
                                  id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
                                  title: name,
                                  amount: amount,
                                  provider: provider.isNotEmpty ? provider : null,
                                  dueDate: selectedDueDate,
                                  iconWidget: _buildLeadingIcon(
                                    bgColor: iconInfo['bg'] as Color,
                                    child: Center(
                                      child: Icon(
                                        iconInfo['icon'] as IconData,
                                        color: iconInfo['color'] as Color,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                          }
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Add Fixed Bill',
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

  @override
  Widget build(BuildContext context) {
    final accentColor = ref.watch(accentColorProvider).color;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0F14),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
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
                        border: Border.all(color: const Color(0xFF262B36)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),

                  // Title: "Monthly Budget Setup"
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Monthly Budget Setup',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  // Symmetrical empty spacer
                  const SizedBox(width: 44),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),

                    // Monthly Income Hero Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131722),
                        borderRadius: BorderRadius.circular(20),
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
                                'Monthly Income',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Base salary & extras',
                                style: TextStyle(
                                  color: Color(0xFF8E95A3),
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _showEditAmountDialog(
                              title: 'Monthly Income',
                              initialValue: _monthlyIncome,
                              onSaved: (val) =>
                                  setState(() => _monthlyIncome = val),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF181C26),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: accentColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                'LKR ${currencyFormat.format(_monthlyIncome)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Remaining to Allocate Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Remaining to Allocate:',
                            style: TextStyle(
                              color: Color(0xFF0C0F14),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'LKR ${currencyFormat.format(_remainingToAllocate)}',
                            style: const TextStyle(
                              color: Color(0xFF0C0F14),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 1: Variable Expense Budgets Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131722),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF1E2332),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header inside card
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Variable Expense Budgets',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Type cap below',
                                style: TextStyle(
                                  color: Color(0xFF8E95A3),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Items List
                          ..._variableExpenses.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                children: [
                                  item.iconWidget,
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showEditAmountDialog(
                                      title: '${item.title} Cap',
                                      initialValue: item.amount,
                                      onSaved: (v) =>
                                          setState(() => item.amount = v),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF181C26),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFF262C38),
                                        ),
                                      ),
                                      child: Text(
                                        'LKR ${currencyFormat.format(item.amount)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          // Add New Budget Category Button (Dashed outline)
                          GestureDetector(
                            onTap: _showAddCategorySheet,
                            child: CustomPaint(
                              painter: DashedBorderPainter(
                                color: accentColor,
                                strokeWidth: 1.2,
                                radius: 12,
                                dashWidth: 5,
                                dashSpace: 4,
                              ),
                              child: Container(
                                width: double.infinity,
                                height: 46,
                                alignment: Alignment.center,
                                child: Text(
                                  '+ Add New Budget Category',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 2: Update Fixed Monthly Bills Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131722),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF1E2332),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header inside card
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Update Fixed Monthly Bills',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Total: LKR ${currencyFormat.format(_totalFixed)}',
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Items List
                          ..._fixedBills.map((bill) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                children: [
                                  bill.iconWidget,
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      bill.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showEditAmountDialog(
                                      title: '${bill.title} Amount',
                                      initialValue: bill.amount,
                                      onSaved: (v) =>
                                          setState(() => bill.amount = v),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF181C26),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFF262C38),
                                        ),
                                      ),
                                      child: Text(
                                        'LKR ${currencyFormat.format(bill.amount)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          // Add New Fixed Bill Button (Dashed outline)
                          GestureDetector(
                            onTap: _showAddFixedBillSheet,
                            child: CustomPaint(
                              painter: DashedBorderPainter(
                                color: accentColor,
                                strokeWidth: 1.2,
                                radius: 12,
                                dashWidth: 5,
                                dashSpace: 4,
                              ),
                              child: Container(
                                width: double.infinity,
                                height: 46,
                                alignment: Alignment.center,
                                child: Text(
                                  '+ Add New Fixed Bill',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Save & Update Budget Button (Pinned at bottom)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: const Color(0xFF0C0F14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Budget saved & updated successfully!',
                          style: TextStyle(
                            color: Color(0xFF0C0F14),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        backgroundColor: accentColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );

                    // If opened as a pushed screen, pop or go to progress
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      // Navigate to Budget Progress screen (Screen 04)
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BudgetProgressScreen(),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Save & Update Budget',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for rounded dashed borders
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  const DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.2,
    this.radius = 12.0,
    this.dashWidth = 5.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    final dashedPath = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final length = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        dashedPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius ||
      oldDelegate.dashWidth != dashWidth ||
      oldDelegate.dashSpace != dashSpace;
}
