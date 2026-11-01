import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/shared_budget_model.dart';
import '../providers/shared_budget_provider.dart';

/// Screen 06B – Create Shared Budget (and Edit Shared Budget)
/// Faithfully reproduces Figma Screen 06B from "06B - Create Shared Budget.png"
/// Allows editing budget information and independently editing each allocated category.
class CreateSharedBudgetScreen extends ConsumerStatefulWidget {
  final SharedBudget? budget;
  final String buttonText;
  final ValueChanged<SharedBudget>? onSave;

  const CreateSharedBudgetScreen({
    super.key,
    this.budget,
    this.buttonText = 'Save Changes',
    this.onSave,
  });

  @override
  ConsumerState<CreateSharedBudgetScreen> createState() =>
      _CreateSharedBudgetScreenState();
}

class _CreateSharedBudgetScreenState
    extends ConsumerState<CreateSharedBudgetScreen> {
  final currencyFormat = NumberFormat('#,##0', 'en_US');

  late TextEditingController _nameController;
  late TextEditingController _goalController;
  late TextEditingController _periodController;
  late TextEditingController _totalFundsController;

  late List<TextEditingController> _categoryNameControllers;
  late List<TextEditingController> _categoryAmountControllers;
  late List<SharedBudgetCategory> _editableCategories;

  @override
  void initState() {
    super.initState();
    final SharedBudget sourceBudget =
        widget.budget ?? ref.read(sharedBudgetProvider);

    _nameController = TextEditingController(text: sourceBudget.name);
    _goalController = TextEditingController(text: sourceBudget.goal);
    _periodController = TextEditingController(text: sourceBudget.period);
    _totalFundsController = TextEditingController(
      text: currencyFormat.format(sourceBudget.totalSharedFunds),
    );

    _editableCategories =
        sourceBudget.categories.map((c) => c.copyWith()).toList();

    _categoryNameControllers = [];
    _categoryAmountControllers = [];
    for (final cat in _editableCategories) {
      _categoryNameControllers.add(TextEditingController(text: cat.name));
      _categoryAmountControllers.add(
        TextEditingController(
          text: currencyFormat.format(cat.assignedAmount),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _periodController.dispose();
    _totalFundsController.dispose();
    for (final c in _categoryNameControllers) {
      c.dispose();
    }
    for (final c in _categoryAmountControllers) {
      c.dispose();
    }
    super.dispose();
  }

  double get _totalFunds {
    final cleaned =
        _totalFundsController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 150000;
  }

  double get _totalAllocated {
    double sum = 0;
    for (int i = 0; i < _categoryAmountControllers.length; i++) {
      final raw = _categoryAmountControllers[i]
          .text
          .replaceAll(RegExp(r'[^0-9.]'), '');
      sum += double.tryParse(raw) ?? 0;
    }
    return sum;
  }

  double get _remainingFunds {
    return (_totalFunds - _totalAllocated).clamp(0.0, double.infinity);
  }

  void _onCancel() {
    // Discard unsaved changes and navigate back to Screen 06A
    Navigator.of(context).pop();
  }

  void _onSave() {
    // Commit edits into categories
    final updatedCategories = <SharedBudgetCategory>[];
    for (int i = 0; i < _editableCategories.length; i++) {
      final cat = _editableCategories[i];
      final newName = _categoryNameControllers[i].text.trim().isNotEmpty
          ? _categoryNameControllers[i].text.trim()
          : cat.name;

      final amtRaw = _categoryAmountControllers[i]
          .text
          .replaceAll(RegExp(r'[^0-9.]'), '');
      final newAssigned = double.tryParse(amtRaw) ?? cat.assignedAmount;
      final newAvailable = (newAssigned - cat.usedAmount).clamp(0.0, double.infinity);

      updatedCategories.add(
        cat.copyWith(
          name: newName,
          assignedAmount: newAssigned,
          availableAmount: newAvailable,
        ),
      );
    }

    final newTotalFunds = _totalFunds;
    final SharedBudget sourceBudget =
        widget.budget ?? ref.read(sharedBudgetProvider);

    final updatedBudget = sourceBudget.copyWith(
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : sourceBudget.name,
      goal: _goalController.text.trim().isNotEmpty
          ? _goalController.text.trim()
          : sourceBudget.goal,
      period: _periodController.text.trim().isNotEmpty
          ? _periodController.text.trim()
          : sourceBudget.period,
      totalSharedFunds: newTotalFunds,
      categories: updatedCategories,
    );

    // Update global state notifier
    ref.read(sharedBudgetProvider.notifier).updateBudget(
          name: updatedBudget.name,
          goal: updatedBudget.goal,
          period: updatedBudget.period,
          totalSharedFunds: updatedBudget.totalSharedFunds,
          categories: updatedCategories,
        );

    if (widget.onSave != null) {
      widget.onSave!(updatedBudget);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Shared budget saved successfully!',
          style: TextStyle(
            color: Color(0xFF0C0F14),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Color(0xFF98E836),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Return to Screen 06A
    Navigator.of(context).pop(updatedBudget);
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
                  // Back button '<'
                  GestureDetector(
                    onTap: _onCancel,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161922),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF262C38)),
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
                  const SizedBox(width: 14),

                  // Title: "Create Shared Budget"
                  const Text(
                    'Create Shared Budget',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Main Scrollable Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Card 1: Shared Budget Information
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
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
                          const Text(
                            'Shared Budget Information',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Field 1: Shared Budget Name
                          const Text(
                            'Shared Budget Name',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF181C26),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF282D3B),
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              controller: _nameController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Field 2: Financial Goal / Purpose
                          const Text(
                            'Financial Goal / Purpose',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF181C26),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF282D3B),
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              controller: _goalController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Row: Planning Period & Total Shared Funds
                          Row(
                            children: [
                              // Planning Period
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Planning Period',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 46,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF181C26),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFF282D3B),
                                        ),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: TextField(
                                        controller: _periodController,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Total Shared Funds (LKR)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Shared Funds (LKR)',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 46,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF181C26),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: accentColor,
                                          width: 1.2,
                                        ),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Text(
                                            'LKR ',
                                            style: TextStyle(
                                              color: accentColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Expanded(
                                            child: TextField(
                                              controller: _totalFundsController,
                                              keyboardType:
                                                  TextInputType.number,
                                              style: TextStyle(
                                                color: accentColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                              ),
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              onChanged: (_) => setState(() {}),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: Allocate Shared Categories
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
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
                          const Text(
                            'Allocate Shared Categories',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Dynamic list of categories with independent name and amount editing
                          ...List.generate(_editableCategories.length, (index) {
                            final cat = _editableCategories[index];
                            final nameCtrl = _categoryNameControllers[index];
                            final amountCtrl = _categoryAmountControllers[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  // Icon box in white
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        cat.icon,
                                        color: cat.iconColor,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Category Name TextField (Editable independently)
                                  Expanded(
                                    child: Container(
                                      height: 42,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF181C26),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFF282D3B),
                                        ),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: TextField(
                                        controller: nameCtrl,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Allocated Amount TextField (Editable independently)
                                  Container(
                                    width: 130,
                                    height: 42,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF181C26),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFF282D3B),
                                      ),
                                    ),
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'LKR ',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Expanded(
                                          child: TextField(
                                            controller: amountCtrl,
                                            keyboardType:
                                                TextInputType.number,
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                            onChanged: (_) => setState(() {}),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 8),

                          // Summary line: Total Allocated • Remaining
                          Center(
                            child: Text(
                              'Total Allocated: LKR ${currencyFormat.format(_totalAllocated)} • Remaining: LKR ${currencyFormat.format(_remainingFunds)}',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
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

            // Bottom Action Buttons: Save Changes (or Create Shared Budget) & Cancel
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Button 1: Save / Save Changes / Create Shared Budget (Solid Lime Green)
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
                      onPressed: _onSave,
                      child: Text(
                        widget.buttonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Button 2: Cancel (Dark button, discards changes)
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
                      onPressed: _onCancel,
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
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
