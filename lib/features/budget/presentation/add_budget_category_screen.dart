import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/budget_category_model.dart';

/// Screen 02A – Add Budget Category Screen
/// Faithfully reproduces Figma Screen 02A from "Dhare Screens/New folder/02A - Create Budget Category.png"
class AddBudgetCategoryScreen extends ConsumerStatefulWidget {
  final double availableToAssign;

  const AddBudgetCategoryScreen({
    super.key,
    this.availableToAssign = 15000,
  });

  @override
  ConsumerState<AddBudgetCategoryScreen> createState() =>
      _AddBudgetCategoryScreenState();
}

class _AddBudgetCategoryScreenState
    extends ConsumerState<AddBudgetCategoryScreen> {
  final currencyFormat = NumberFormat('#,##0', 'en_US');
  final _nameController = TextEditingController(text: 'Education');
  final _amountController = TextEditingController(text: '10,000');

  String _selectedGroup = 'Needs';
  final List<String> _groups = ['Bills', 'Needs', 'Wants', 'Savings', 'Custom'];

  int _selectedIconIndex = 0;
  final List<Map<String, dynamic>> _icons = [
    {
      'icon': Icons.school_rounded,
      'color': const Color(0xFFF59E0B),
      'bg': Colors.white,
    },
    {
      'icon': Icons.receipt_long_rounded,
      'color': const Color(0xFF8B5CF6),
      'bg': Colors.white,
    },
    {
      'icon': Icons.shopping_basket_rounded,
      'color': const Color(0xFFF59E0B),
      'bg': Colors.white,
    },
    {
      'icon': Icons.directions_bus_rounded,
      'color': const Color(0xFF2563EB),
      'bg': Colors.white,
    },
    {
      'icon': Icons.savings_rounded,
      'color': const Color(0xFF06B6D4),
      'bg': Colors.white,
    },
    {
      'icon': Icons.shopping_bag_rounded,
      'color': const Color(0xFF10B981),
      'bg': Colors.white,
    },
  ];

  int _selectedColorIndex = 0;
  final List<Color> _colors = const [
    Color(0xFF98E836), // Lime Green
    Color(0xFFF59E0B), // Amber / Orange
    Color(0xFF38BDF8), // Light Sky Blue
    Color(0xFF9353D3), // Purple
    Color(0xFFF43F5E), // Coral / Salmon Red
    Color(0xFF94A3B8), // Slate Grey
  ];

  @override
  void dispose() {
    _nameController.disposeValidate();
    _amountController.dispose();
    super.dispose();
  }

  void _handleAddCategory(Color accentColor) {
    final name = _nameController.text.trim();
    final cleanAmountStr = _amountController.text.replaceAll(',', '').trim();
    final amount = double.tryParse(cleanAmountStr) ?? 0.0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a category name'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid allocation amount'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final selectedIconInfo = _icons[_selectedIconIndex];
    final selectedColor = _colors[_selectedColorIndex];

    final newCategory = BudgetCategoryModel(
      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      group: _selectedGroup,
      icon: selectedIconInfo['icon'] as IconData,
      color: selectedColor,
      iconBg: selectedIconInfo['bg'] as Color,
      assignedAmount: amount,
      spentAmount: 0.0,
      description: 'Assigned to $_selectedGroup expense budget.',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name added successfully!'),
        backgroundColor: accentColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop(newCategory);
  }

  void _showAdvancedSettingsModal(Color accentColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0xFF1E2332)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
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
              const SizedBox(height: 16),
              const Text(
                'Advanced Category Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingTile(
                title: 'Rollover Unused Balance',
                subtitle: 'Carry over unspent funds to next month',
                initialValue: true,
                accentColor: accentColor,
              ),
              const Divider(color: Colors.white10),
              _buildSettingTile(
                title: 'Spending Threshold Alert',
                subtitle: 'Notify when 85% of budget is spent',
                initialValue: true,
                accentColor: accentColor,
              ),
              const Divider(color: Colors.white10),
              _buildSettingTile(
                title: 'Strict Cap Lock',
                subtitle: 'Prevent logging transactions exceeding cap',
                initialValue: false,
                accentColor: accentColor,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: const Color(0xFF0C0F14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool initialValue,
    required Color accentColor,
  }) {
    return StatefulBuilder(
      builder: (context, setTileState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: initialValue,
              activeThumbColor: accentColor,
              activeTrackColor: accentColor.withValues(alpha: 0.3),
              inactiveThumbColor: Colors.white54,
              inactiveTrackColor: const Color(0xFF1E2332),
              onChanged: (val) {
                setTileState(() {
                  initialValue = val;
                });
              },
            ),
          ],
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
                  // Circular Back Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
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
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Add Budget Category',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
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
                    const SizedBox(height: 4),

                    // Available to Assign Banner (matching Figma Screen 02A)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Available to Assign:',
                            style: TextStyle(
                              color: Color(0xFF0C0F14),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'LKR ${currencyFormat.format(widget.availableToAssign)}',
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

                    // Category Information Card
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
                          const Text(
                            'Category Information',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Category Name
                          const Text(
                            'Category Name',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF181C26),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFF262C38),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: accentColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Category Group
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
                              children: _groups.map((group) {
                                final isSelected = group == _selectedGroup;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedGroup = group;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF181C26),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isSelected
                                            ? accentColor
                                            : const Color(0xFF262C38),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      group,
                                      style: TextStyle(
                                        color: isSelected
                                            ? accentColor
                                            : Colors.white70,
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Category Icon
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
                            children: List.generate(_icons.length, (idx) {
                              final isSelected = idx == _selectedIconIndex;
                              final iconInfo = _icons[idx];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedIconIndex = idx;
                                  });
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: iconInfo['bg'] as Color,
                                    borderRadius: BorderRadius.circular(10),
                                    border: isSelected
                                        ? Border.all(
                                            color: accentColor,
                                            width: 2.2,
                                          )
                                        : Border.all(
                                            color: Colors.transparent,
                                          ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      iconInfo['icon'] as IconData,
                                      color: iconInfo['color'] as Color,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 14),

                          // Category Color Palette (NEW FEATURE from updated reference)
                          const Text(
                            'Category Color',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(_colors.length, (idx) {
                              final isSelected = idx == _selectedColorIndex;
                              final color = _colors[idx];
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedColorIndex = idx;
                                  });
                                },
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          )
                                        : null,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: color.withValues(alpha: 0.5),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            )
                                          ]
                                        : null,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Budget Allocation Card
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
                          const Text(
                            'Budget Allocation',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
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
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10141D),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: accentColor,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'LKR',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Add Category Primary Button
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
                        onPressed: () => _handleAddCategory(accentColor),
                        child: const Text(
                          'Add Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Advanced Setting Button (NEW FEATURE from updated reference)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1D26),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                            side: const BorderSide(
                              color: Color(0xFF262B36),
                            ),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => _showAdvancedSettingsModal(accentColor),
                        child: const Text(
                          'Advanced setting',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on TextEditingController {
  void disposeValidate() {
    dispose();
  }
}
