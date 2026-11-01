import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/fixed_bill_model.dart';

/// Screen 03B – Edit Fixed Bill Screen
/// Faithfully reproduces Figma Screen 03B from "Dhare Screens/New folder/03B - Edit Fixed Bill.png"
/// A single, reusable edit screen that dynamically displays any selected fixed bill's information.
class EditFixedBillScreen extends ConsumerStatefulWidget {
  final FixedBillModel bill;

  const EditFixedBillScreen({
    super.key,
    required this.bill,
  });

  @override
  ConsumerState<EditFixedBillScreen> createState() =>
      _EditFixedBillScreenState();
}

class _EditFixedBillScreenState extends ConsumerState<EditFixedBillScreen> {
  final currencyFormat = NumberFormat('#,##0', 'en_US');
  late final TextEditingController _nameController;
  late final TextEditingController _providerController;
  late final TextEditingController _amountController;

  late String _selectedDueDate;
  final List<String> _dueDates = [
    'Day 1 of every month',
    'Day 5 of every month',
    'Day 10 of every month',
    'Day 15 of every month',
    'Day 20 of every month',
    'Day 25 of every month',
    'Day 30 of every month',
  ];

  late bool _isPaid;
  late double _amount;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bill.title);
    _providerController = TextEditingController(text: widget.bill.provider);
    _amount = widget.bill.amount;
    _amountController = TextEditingController(
      text: currencyFormat.format(_amount.toInt()),
    );

    _selectedDueDate = widget.bill.dueDate;
    if (!_dueDates.contains(_selectedDueDate)) {
      _dueDates.insert(0, _selectedDueDate);
    }

    _isPaid = widget.bill.isPaid;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _providerController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleSave(Color accentColor) {
    final name = _nameController.text.trim();
    final provider = _providerController.text.trim();
    final cleanAmountStr = _amountController.text.replaceAll(',', '').trim();
    final amount = double.tryParse(cleanAmountStr) ?? _amount;

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
          content: Text('Please enter a valid amount'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final updated = widget.bill.copyWith(
      title: name,
      provider: provider.isNotEmpty ? provider : name,
      amount: amount,
      dueDate: _selectedDueDate,
      isPaid: _isPaid,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name updated successfully!'),
        backgroundColor: accentColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop(FixedBillEditResult.updated(updated));
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161922),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF262B36)),
        ),
        title: const Text(
          'Delete Fixed Bill',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.bill.title}"? This will remove the bill from your monthly budget.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.of(context).pop(FixedBillEditResult.deleted());
            },
            child: const Text(
              'Delete',
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

                  // Title: "Edit Fixed Bill"
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Edit Fixed Bill',
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

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),

                    // Hero Header Card (matching Figma Screen 03B)
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
                      child: Row(
                        children: [
                          // Bill Icon
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: widget.bill.iconBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                widget.bill.icon,
                                color: widget.bill.iconColor,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Bill Title & Subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.bill.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Monthly Fixed Bill',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Status Selector Pills (Pending / Paid)
                          Row(
                            children: [
                              // Pending Pill
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isPaid = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !_isPaid
                                        ? const Color(0xFFF59E0B)
                                            .withValues(alpha: 0.15)
                                        : const Color(0xFF181C26),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: !_isPaid
                                          ? const Color(0xFFF59E0B)
                                          : const Color(0xFF262C38),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Text(
                                    'Pending',
                                    style: TextStyle(
                                      color: !_isPaid
                                          ? const Color(0xFFF59E0B)
                                          : Colors.white54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Paid Pill
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isPaid = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isPaid
                                        ? accentColor.withValues(alpha: 0.15)
                                        : const Color(0xFF181C26),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _isPaid
                                          ? accentColor
                                          : const Color(0xFF262C38),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Text(
                                    'Paid',
                                    style: TextStyle(
                                      color: _isPaid ? accentColor : Colors.white54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bill Name
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

                    // Biller / Provider Name
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

                    // Monthly Amount
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
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onChanged: (val) {
                                final parsed = double.tryParse(
                                  val.replaceAll(',', '').trim(),
                                );
                                if (parsed != null && parsed > 0) {
                                  _amount = parsed;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Due Date
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
                    const SizedBox(height: 32),

                    // Save Changes Button (Solid Lime Green pill button)
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
                        onPressed: () => _handleSave(accentColor),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Delete Fixed Bill Button (Dark with subtle red border)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A151C),
                          foregroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                            side: BorderSide(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.4),
                              width: 1.2,
                            ),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _handleDelete,
                        child: const Text(
                          'Delete Fixed Bill',
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
