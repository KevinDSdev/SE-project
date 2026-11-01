import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/fixed_bill_model.dart';

/// Screen 03A – Add Fixed Bill Screen
/// Faithfully reproduces Figma Screen 03A from "Dhare Screens/New folder/03A - Add Fixed Bill.png"
class AddFixedBillScreen extends ConsumerStatefulWidget {
  const AddFixedBillScreen({super.key});

  @override
  ConsumerState<AddFixedBillScreen> createState() => _AddFixedBillScreenState();
}

class _AddFixedBillScreenState extends ConsumerState<AddFixedBillScreen> {
  final _nameController = TextEditingController();
  final _providerController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedDueDate = 'Day 5 of every month';
  final List<String> _dueDates = [
    'Day 1 of every month',
    'Day 5 of every month',
    'Day 10 of every month',
    'Day 15 of every month',
    'Day 20 of every month',
    'Day 25 of every month',
    'Day 30 of every month',
  ];

  int _selectedCategoryIndex = 0;
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Internet',
      'icon': Icons.language_rounded,
      'color': const Color(0xFF0284C7),
      'bg': Colors.white,
    },
    {
      'name': 'Insurance',
      'icon': Icons.security_rounded,
      'color': const Color(0xFF0D9488),
      'bg': Colors.white,
    },
    {
      'name': 'Rent',
      'icon': Icons.home_rounded,
      'color': const Color(0xFF334155),
      'bg': Colors.white,
    },
    {
      'name': 'medicine',
      'icon': Icons.medical_services_rounded,
      'color': const Color(0xFF0284C7),
      'bg': Colors.white,
    },
    {
      'name': 'Phone',
      'icon': Icons.phone_in_talk_rounded,
      'color': const Color(0xFFDC2626),
      'bg': Colors.white,
    },
    {
      'name': 'Other',
      'icon': Icons.more_horiz_rounded,
      'color': Colors.white,
      'bg': const Color(0xFF1E2332),
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _providerController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleAddBill(Color accentColor) {
    final name = _nameController.text.trim();
    final provider = _providerController.text.trim();
    final cleanAmountStr = _amountController.text.replaceAll(',', '').trim();
    final amount = double.tryParse(cleanAmountStr) ?? 0.0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a bill name'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid monthly amount'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final cat = _categories[_selectedCategoryIndex];
    final newBill = FixedBillModel(
      id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
      title: name,
      provider: provider.isNotEmpty ? provider : name,
      amount: amount,
      dueDate: _selectedDueDate,
      category: cat['name'] as String,
      icon: cat['icon'] as IconData,
      iconColor: cat['color'] as Color,
      iconBg: cat['bg'] as Color,
      isPaid: false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name added successfully!'),
        backgroundColor: accentColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop(newBill);
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

                  // Title: "Add Fixed Bill"
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Add Fixed Bill',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  // Symmetrical spacer
                  const SizedBox(width: 44),
                ],
              ),
            ),

            // Scrollable Form Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Bill Name Field
                    const Text(
                      'Bill Name',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g., Internet, Insurance',
                        hintStyle: const TextStyle(
                          color: Colors.white30,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF131722),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1E2332),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1E2332),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: accentColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Biller / Provider Name Field
                    const Text(
                      'Biller / Provider Name',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _providerController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'e.g., SLT-Mobitel',
                        hintStyle: const TextStyle(
                          color: Colors.white30,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF131722),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1E2332),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1E2332),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: accentColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Monthly Amount Field
                    const Text(
                      'Monthly Amount',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131722),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1E2332),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'LKR',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: const InputDecoration(
                                hintText: '0.00',
                                hintStyle: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Due Date Field
                    const Text(
                      'Due Date',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131722),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1E2332),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDueDate,
                          dropdownColor: const Color(0xFF161922),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white70,
                          ),
                          isExpanded: true,
                          items: _dueDates.map((date) {
                            return DropdownMenuItem<String>(
                              value: date,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_rounded,
                                    color: Colors.white54,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    date,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedDueDate = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category & Icon Selector
                    const Text(
                      'Category & Icon',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(_categories.length, (idx) {
                        final isSelected = idx == _selectedCategoryIndex;
                        final cat = _categories[idx];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = idx;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: cat['bg'] as Color,
                                  borderRadius: BorderRadius.circular(12),
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
                                    cat['icon'] as IconData,
                                    color: cat['color'] as Color,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cat['name'] as String,
                                style: TextStyle(
                                  color: isSelected
                                      ? accentColor
                                      : Colors.white60,
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

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
                          elevation: 0,
                        ),
                        onPressed: () => _handleAddBill(accentColor),
                        child: const Text(
                          'Add Fixed Bill',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
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
