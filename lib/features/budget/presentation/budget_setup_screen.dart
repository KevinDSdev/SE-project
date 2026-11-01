import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/navigation_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/budget_category_model.dart';
import '../models/fixed_bill_model.dart';
import 'add_budget_category_screen.dart';
import 'add_fixed_bill_screen.dart';
import 'budget_progress_screen.dart';
import 'edit_budget_category_screen.dart';
import 'edit_fixed_bill_screen.dart';

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
  late List<BudgetCategoryModel> _variableExpenses;

  // Fixed Monthly Bills matching Figma Screen 01
  late List<FixedBillModel> _fixedBills;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _variableExpenses = [
      BudgetCategoryModel(
        id: 'food_groceries',
        name: 'Food & Groceries',
        group: 'Needs (Variable)',
        icon: Icons.shopping_basket_rounded,
        color: const Color(0xFFF59E0B),
        iconBg: Colors.white,
        assignedAmount: 65000,
        spentAmount: 20000,
        description: 'Assigned to variable monthly household supplies.',
      ),
      BudgetCategoryModel(
        id: 'dining_takeout',
        name: 'Dining & Takeout',
        group: 'Wants',
        icon: Icons.restaurant_rounded,
        color: const Color(0xFFE11D48),
        iconBg: const Color(0xFFE11D48),
        assignedAmount: 35000,
        spentAmount: 12000,
        description: 'Dining out, cafes, takeaways and fast food.',
      ),
      BudgetCategoryModel(
        id: 'travel_transport',
        name: 'Travel & Transport',
        group: 'Needs (Variable)',
        icon: Icons.directions_bus_rounded,
        color: const Color(0xFF2563EB),
        iconBg: Colors.white,
        assignedAmount: 30000,
        spentAmount: 10000,
        description: 'Daily commute, fuel, public transit and ride-shares.',
      ),
    ];

    _fixedBills = [
      FixedBillModel(
        id: 'apartment_rent',
        title: 'Apartment Rent',
        amount: 120000,
        provider: 'Mr. Sandun (Landlord)',
        dueDate: 'Day 1 of every month',
        category: 'Rent',
        icon: Icons.apartment_rounded,
        iconColor: const Color(0xFF334155),
        iconBg: Colors.white,
        isPaid: false,
      ),
      FixedBillModel(
        id: 'ceb_bills',
        title: 'CEB Electricity & Water',
        amount: 45000,
        provider: 'CEB / NWSDB',
        dueDate: 'Day 10 of every month',
        category: 'Electricity',
        icon: Icons.bolt_rounded,
        iconColor: const Color(0xFFDC2626),
        iconBg: const Color(0xFFFEF08A),
        isPaid: false,
      ),
      FixedBillModel(
        id: 'dialog_insurance',
        title: 'Dialog & Insurance',
        amount: 25000,
        provider: 'Dialog Axiata & Ceylinco',
        dueDate: 'Day 15 of every month',
        category: 'Internet',
        icon: Icons.change_history_rounded,
        iconColor: const Color(0xFFE11D48),
        iconBg: Colors.white,
        isPaid: false,
      ),
    ];
  }

  double get _totalVariable =>
      _variableExpenses.fold(0.0, (sum, item) => sum + item.assignedAmount);

  double get _totalFixed =>
      _fixedBills.fold(0.0, (sum, item) => sum + item.amount);

  double get _remainingToAllocate =>
      _monthlyIncome - (_totalVariable + _totalFixed + _baselineSavings);

  // Navigate to Add Budget Category Screen (Screen 02A)
  Future<void> _navigateToAddCategory() async {
    final newCategory = await Navigator.of(context).push<BudgetCategoryModel>(
      MaterialPageRoute(
        builder: (_) => AddBudgetCategoryScreen(
          availableToAssign:
              _remainingToAllocate > 0 ? _remainingToAllocate : 0,
        ),
      ),
    );

    if (newCategory != null) {
      setState(() {
        _variableExpenses.add(newCategory);
      });
    }
  }

  // Navigate to Edit Budget Category Screen (Screen 02B)
  Future<void> _navigateToEditCategory(BudgetCategoryModel category) async {
    final result = await Navigator.of(context).push<CategoryEditResult>(
      MaterialPageRoute(
        builder: (_) => EditBudgetCategoryScreen(
          category: category,
        ),
      ),
    );

    if (result != null) {
      if (result.isDeleted) {
        setState(() {
          _variableExpenses.removeWhere((c) => c.id == category.id);
        });
      } else if (result.updatedCategory != null) {
        setState(() {
          final index =
              _variableExpenses.indexWhere((c) => c.id == category.id);
          if (index != -1) {
            _variableExpenses[index] = result.updatedCategory!;
          }
        });
      }
    }
  }

  // Navigate to Add Fixed Bill Screen (Screen 03A)
  Future<void> _navigateToAddFixedBill() async {
    final newBill = await Navigator.of(context).push<FixedBillModel>(
      MaterialPageRoute(
        builder: (_) => const AddFixedBillScreen(),
      ),
    );

    if (newBill != null) {
      setState(() {
        _fixedBills.add(newBill);
      });
    }
  }

  // Navigate to Edit Fixed Bill Screen (Screen 03B)
  Future<void> _navigateToEditFixedBill(FixedBillModel bill) async {
    final result = await Navigator.of(context).push<FixedBillEditResult>(
      MaterialPageRoute(
        builder: (_) => EditFixedBillScreen(
          bill: bill,
        ),
      ),
    );

    if (result != null) {
      if (result.isDeleted) {
        setState(() {
          _fixedBills.removeWhere((b) => b.id == bill.id);
        });
      } else if (result.updatedBill != null) {
        setState(() {
          final index = _fixedBills.indexWhere((b) => b.id == bill.id);
          if (index != -1) {
            _fixedBills[index] = result.updatedBill!;
          }
        });
      }
    }
  }

  // Edit Amount Dialog for Monthly Income
  void _showEditIncomeDialog() {
    final accentColor = ref.read(accentColorProvider).color;
    final controller = TextEditingController(
      text: _monthlyIncome.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161922),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF262B36)),
        ),
        title: const Text(
          'Monthly Income',
          style: TextStyle(
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
              final val =
                  double.tryParse(controller.text.trim()) ?? _monthlyIncome;
              setState(() => _monthlyIncome = val);
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
                            onTap: _showEditIncomeDialog,
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

                          // Items List: Tapping on any category opens Edit Budget Category Screen (02B)
                          ..._variableExpenses.map((category) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: InkWell(
                                onTap: () => _navigateToEditCategory(category),
                                borderRadius: BorderRadius.circular(10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: category.iconBg,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          category.icon,
                                          color: category.color,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        category.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF181C26),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFF262C38),
                                        ),
                                      ),
                                      child: Text(
                                        'LKR ${currencyFormat.format(category.assignedAmount)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          // Add New Budget Category Button (Navigates to Screen 02A)
                          GestureDetector(
                            onTap: _navigateToAddCategory,
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

                          // Items List: Tapping on any fixed bill opens Edit Fixed Bill Screen (03B)
                          ..._fixedBills.map((bill) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: InkWell(
                                onTap: () => _navigateToEditFixedBill(bill),
                                borderRadius: BorderRadius.circular(10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: bill.iconBg,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          bill.icon,
                                          color: bill.iconColor,
                                          size: 22,
                                        ),
                                      ),
                                    ),
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF181C26),
                                        borderRadius:
                                            BorderRadius.circular(10),
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
                                  ],
                                ),
                              ),
                            );
                          }),

                          // Add New Fixed Bill Button (Navigates to Screen 03A)
                          GestureDetector(
                            onTap: _navigateToAddFixedBill,
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

            // Bottom Action Buttons matching updated Screen 01 design
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Button 1: Add Recurring & Subscription (Dark pill button)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F222B),
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFF282D3B),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Add Recurring & Subscription',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: const Color(0xFF1E2332),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Add Recurring & Subscription',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Button 2: View Budget Progress (Solid accent color button)
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
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BudgetProgressScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'View Budget Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ],
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
