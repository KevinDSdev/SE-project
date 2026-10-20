import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';

class BudgetSetupScreen extends ConsumerStatefulWidget {
  const BudgetSetupScreen({super.key});

  @override
  ConsumerState<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends ConsumerState<BudgetSetupScreen> {
  final currencyFormat = NumberFormat('#,##0', 'en_US');

  double _monthlyIncome = 450000;

  // Variable Expense Budgets
  double _foodGroceries = 65000;
  double _diningTakeout = 35000;
  double _travelTransport = 30000;
  double _shoppingLifestyle = 25000;

  // Fixed Monthly Bills
  final List<Map<String, dynamic>> _fixedBills = [
    {
      'title': 'Apartment Rent',
      'amount': 120000.0,
      'icon': Icons.home_rounded,
    },
    {
      'title': 'CEB Electricity & Water',
      'amount': 45000.0,
      'icon': Icons.bolt_rounded,
    },
    {
      'title': 'Dialog & Insurance',
      'amount': 25000.0,
      'icon': Icons.wifi_rounded,
    },
  ];

  double get _totalVariable =>
      _foodGroceries + _diningTakeout + _travelTransport + _shoppingLifestyle;

  double get _totalFixed =>
      _fixedBills.fold(0.0, (sum, bill) => sum + (bill['amount'] as double));

  double get _remainingToAllocate =>
      _monthlyIncome - (_totalVariable + _totalFixed);

  void _showEditNumberDialog({
    required String title,
    required double initialValue,
    required ValueChanged<double> onSaved,
  }) {
    final controller = TextEditingController(
      text: initialValue.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder),
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
            prefixStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            filled: true,
            fillColor: const Color(0xFF161922),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.darkBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showAddFixedBillDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        title: const Text(
          'Add Fixed Monthly Bill',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Bill name (e.g. Gym Membership)',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: const Color(0xFF161922),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.darkBorder),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixText: 'LKR ',
                prefixStyle: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
                hintText: 'Amount',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: const Color(0xFF161922),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.darkBorder),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: const Color(0xFF0C0F14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final name = nameController.text.trim();
              final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
              if (name.isNotEmpty && amount > 0) {
                setState(() {
                  _fixedBills.add({
                    'title': name,
                    'amount': amount,
                    'icon': Icons.receipt_long_rounded,
                  });
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add Bill', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    onTap: () => Navigator.of(context).pop(),
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

                  // Title: "Monthly Budget Setup"
                  const Text(
                    'Monthly Budget Setup',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  // Status / Link Button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF161922),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.edit_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Budget Setup Form
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
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Base salary & extras',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _showEditNumberDialog(
                              title: 'Monthly Income',
                              initialValue: _monthlyIncome,
                              onSaved: (val) => setState(() => _monthlyIncome = val),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF181C26),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF142416),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Remaining to Allocate:',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'LKR ${currencyFormat.format(_remainingToAllocate)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section 1: Variable Expense Budgets
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
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131722),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF1E2332),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildBudgetRow(
                            title: 'Food & Groceries',
                            amount: _foodGroceries,
                            icon: Icons.shopping_basket_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            bgColor: const Color(0xFF2E2218),
                            onTap: () => _showEditNumberDialog(
                              title: 'Food & Groceries Cap',
                              initialValue: _foodGroceries,
                              onSaved: (v) => setState(() => _foodGroceries = v),
                            ),
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _buildBudgetRow(
                            title: 'Dining & Takeout',
                            amount: _diningTakeout,
                            icon: Icons.restaurant_rounded,
                            iconColor: const Color(0xFFA855F7),
                            bgColor: const Color(0xFF281E38),
                            onTap: () => _showEditNumberDialog(
                              title: 'Dining & Takeout Cap',
                              initialValue: _diningTakeout,
                              onSaved: (v) => setState(() => _diningTakeout = v),
                            ),
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _buildBudgetRow(
                            title: 'Travel & Transport',
                            amount: _travelTransport,
                            icon: Icons.directions_car_rounded,
                            iconColor: const Color(0xFF38BDF8),
                            bgColor: const Color(0xFF162738),
                            onTap: () => _showEditNumberDialog(
                              title: 'Travel & Transport Cap',
                              initialValue: _travelTransport,
                              onSaved: (v) => setState(() => _travelTransport = v),
                            ),
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _buildBudgetRow(
                            title: 'Shopping & Lifestyle',
                            amount: _shoppingLifestyle,
                            icon: Icons.shopping_bag_outlined,
                            iconColor: const Color(0xFF06B6D4),
                            bgColor: const Color(0xFF162B33),
                            onTap: () => _showEditNumberDialog(
                              title: 'Shopping & Lifestyle Cap',
                              initialValue: _shoppingLifestyle,
                              onSaved: (v) => setState(() => _shoppingLifestyle = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section 2: Update Fixed Monthly Bills
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
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131722),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF1E2332),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < _fixedBills.length; i++) ...[
                            if (i > 0) const Divider(color: Colors.white10, height: 1),
                            _buildBudgetRow(
                              title: _fixedBills[i]['title'] as String,
                              amount: _fixedBills[i]['amount'] as double,
                              icon: _fixedBills[i]['icon'] as IconData,
                              iconColor: const Color(0xFF38BDF8),
                              bgColor: const Color(0xFF162738),
                              onTap: () => _showEditNumberDialog(
                                title: _fixedBills[i]['title'] as String,
                                initialValue: _fixedBills[i]['amount'] as double,
                                onSaved: (v) => setState(
                                    () => _fixedBills[i]['amount'] = v),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          // Add New Fixed Bill Button
                          GestureDetector(
                            onTap: _showAddFixedBillDialog,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161922),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white12,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  '+ Add New Fixed Bill',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Save & Update Budget Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: const Color(0xFF0C0F14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Budget updated successfully!'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Save & Update Budget',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
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

  Widget _buildBudgetRow({
    required String title,
    required double amount,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF161922),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Text(
                'LKR ${currencyFormat.format(amount)}',
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
  }
}
