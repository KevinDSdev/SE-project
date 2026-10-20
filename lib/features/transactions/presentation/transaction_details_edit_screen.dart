import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/transaction_model.dart';
import '../providers/transactions_provider.dart';
import 'receipt_capture_screen.dart';

class TransactionDetailsEditScreen extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailsEditScreen({
    super.key,
    required this.transaction,
  });

  @override
  ConsumerState<TransactionDetailsEditScreen> createState() =>
      _TransactionDetailsEditScreenState();
}

class _TransactionDetailsEditScreenState
    extends ConsumerState<TransactionDetailsEditScreen> {
  late TextEditingController _merchantController;
  late TextEditingController _noteController;
  late TransactionCategoryType _selectedCategory;
  late double _amount;
  late double _cashback;

  String? _receiptFileName;
  int? _receiptItemCount;
  int? _receiptMatchPercent;
  String? _receiptImagePath;

  final currencyFormat = NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    _merchantController =
        TextEditingController(text: widget.transaction.merchant);
    _noteController = TextEditingController(
      text: widget.transaction.note ?? '',
    );
    _selectedCategory = widget.transaction.category;
    _amount = widget.transaction.amount;
    _cashback = widget.transaction.cashback > 0
        ? widget.transaction.cashback
        : (_amount * 0.01).roundToDouble();

    _receiptFileName = widget.transaction.receiptFileName;
    _receiptItemCount = widget.transaction.receiptItemCount;
    _receiptMatchPercent = widget.transaction.receiptMatchPercent;
    _receiptImagePath = widget.transaction.receiptImagePath;
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _attachReceipt() async {
    final result = await Navigator.of(context).push<ReceiptScanResult>(
      MaterialPageRoute(
        builder: (_) => const ReceiptCaptureScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _receiptFileName = result.receiptFileName ?? 'Receipt_Scanned.jpg';
        _receiptItemCount = result.itemCount ?? 3;
        _receiptMatchPercent = result.matchPercent ?? 100;
        _receiptImagePath = result.imagePath;
      });
    }
  }

  void _saveChanges() {
    final updated = widget.transaction.copyWith(
      merchant: _merchantController.text.trim().isEmpty
          ? widget.transaction.merchant
          : _merchantController.text.trim(),
      note: _noteController.text.trim(),
      category: _selectedCategory,
      amount: _amount,
      cashback: _cashback,
      receiptFileName: _receiptFileName,
      receiptItemCount: _receiptItemCount,
      receiptMatchPercent: _receiptMatchPercent,
      receiptImagePath: _receiptImagePath,
    );

    ref.read(transactionsProvider.notifier).updateTransaction(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved successfully!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        title: const Text(
          'Delete Transaction?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'This will remove this transaction and restore your budget balance.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
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
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(transactionsProvider.notifier)
                  .deleteTransaction(widget.transaction.id);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction deleted.'),
                  backgroundColor: Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                ),
              );

              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCategoryPickerSheet() {
    final categories = [
      (
        TransactionCategoryType.dining,
        'Dining & Takeout',
        'LKR 31,850 Left',
        Icons.restaurant_rounded,
        const Color(0xFFA855F7),
        const Color(0xFF2C1E3C),
      ),
      (
        TransactionCategoryType.groceries,
        'Groceries & Supermarket',
        'LKR 45,200 Left',
        Icons.shopping_bag_outlined,
        const Color(0xFFF59E0B),
        const Color(0xFF2E2419),
      ),
      (
        TransactionCategoryType.transport,
        'Transport & Fuel',
        'LKR 18,500 Left',
        Icons.directions_car_filled_rounded,
        const Color(0xFF38BDF8),
        const Color(0xFF162738),
      ),
      (
        TransactionCategoryType.shopping,
        'Shopping & Retail',
        'LKR 24,000 Left',
        Icons.shopping_basket_outlined,
        const Color(0xFF06B6D4),
        const Color(0xFF162B33),
      ),
      (
        TransactionCategoryType.bills,
        'Bills & Utilities',
        'LKR 12,300 Left',
        Icons.receipt_long_rounded,
        const Color(0xFFEC4899),
        const Color(0xFF2D1624),
      ),
      (
        TransactionCategoryType.savings,
        'Savings & Investments',
        'LKR 150,000 Left',
        Icons.savings_outlined,
        AppColors.primary,
        const Color(0xFF1E2D16),
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  'Select Budget Category',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final cat = categories[i];
                    final isSelected = _selectedCategory == cat.$1;

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = cat.$1);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161922),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.darkBorder,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: cat.$6,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(cat.$4, color: cat.$5, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.$2,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    cat.$3,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditMerchantDialog() {
    final controller = TextEditingController(text: _merchantController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        title: const Text(
          'Edit Merchant / Payee',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter merchant name',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
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
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _merchantController.text = controller.text.trim();
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showEditNoteDialog() {
    final controller = TextEditingController(text: _noteController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        title: const Text(
          'Edit Note & Tags',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Add note or tags (e.g. #work, #dinner)',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
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
              setState(() {
                _noteController.text = controller.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showReceiptInspector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Scanned Receipt',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'OCR 100% Match',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Simulated full receipt view
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'PIZZA HUT SRI LANKA',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'COLOMBO 03 • TEL: 011 272 9729',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildReceiptRow('1x Large Pan Pizza', '2,450.00'),
                      const SizedBox(height: 4),
                      _buildReceiptRow('1x Garlic Bread Sticks', '450.00'),
                      const SizedBox(height: 4),
                      _buildReceiptRow('1x Pepsi 400ml', '250.00'),
                      const SizedBox(height: 10),
                      Container(height: 1, color: const Color(0xFFD1D5DB)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'TOTAL LKR',
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '3,150.00',
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
          ),
        );
      },
    );
  }

  static Widget _buildReceiptRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _showSplitBillSheet() {
    int numberOfPeople = 2;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final perPerson = _amount / numberOfPeople;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      'Split Bill with Friends',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Total: LKR ${currencyFormat.format(_amount)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Per Person Big Amount Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161922),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Each person pays',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'LKR ${currencyFormat.format(perPerson)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Number of people selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Number of People',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: numberOfPeople > 2
                                  ? () => setModalState(() => numberOfPeople--)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppColors.primary,
                              disabledColor: Colors.white24,
                            ),
                            Text(
                              '$numberOfPeople',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              onPressed: numberOfPeople < 12
                                  ? () => setModalState(() => numberOfPeople++)
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                              color: AppColors.primary,
                              disabledColor: Colors.white24,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: const Color(0xFF0C0F14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Split request generated: LKR ${currencyFormat.format(perPerson)} each for $numberOfPeople friends.',
                              ),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_outlined, size: 20),
                        label: const Text(
                          'Share Payment Request',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
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

  void _showTaxInvoiceSheet() {
    final netAmount = _amount / 1.18;
    final vatAmount = _amount - netAmount;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Official Tax Invoice',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'IRD SL Compliant',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161922),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Column(
                    children: [
                      _buildTaxRow('Merchant TIN', '102384910-7000'),
                      const SizedBox(height: 8),
                      _buildTaxRow('Invoice No.', 'INV-2026-LK-0912'),
                      const SizedBox(height: 8),
                      _buildTaxRow(
                          'Net Amount', 'LKR ${currencyFormat.format(netAmount)}'),
                      const SizedBox(height: 8),
                      _buildTaxRow(
                          'VAT (18%)', 'LKR ${currencyFormat.format(vatAmount)}'),
                      const Divider(color: Colors.white12, height: 16),
                      _buildTaxRow('Gross Total',
                          'LKR ${currencyFormat.format(_amount)}',
                          isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: const Color(0xFF0C0F14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Tax Invoice downloaded to receipts folder.'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 20),
                    label: const Text(
                      'Download Tax PDF',
                      style: TextStyle(fontWeight: FontWeight.w700),
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

  static Widget _buildTaxRow(String label, String value,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? AppColors.primary : Colors.white,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Resolves the circular merchant avatar
  Widget _buildMerchantAvatar() {
    final lower = _merchantController.text.toLowerCase();

    if (lower.contains('pizza')) {
      return Container(
        width: 54,
        height: 54,
        decoration: const BoxDecoration(
          color: Color(0xFFD61827), // Crimson Red
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 5.5,
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
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  height: 0.9,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (lower.contains('keells')) {
      return Container(
        width: 54,
        height: 54,
        decoration: const BoxDecoration(
          color: Color(0xFF007A3D),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'Keells',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: widget.transaction.type == TransactionType.income
              ? const Color(0xFF162738)
              : const Color(0xFF2C1E3C),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.transaction.type == TransactionType.income
              ? Icons.south_west_rounded
              : Icons.storefront_rounded,
          color: widget.transaction.type == TransactionType.income
              ? const Color(0xFF38BDF8)
              : const Color(0xFFA855F7),
          size: 26,
        ),
      );
    }
  }

  // Mini receipt graphic icon
  Widget _buildMiniReceiptThumbnail() {
    return Container(
      width: 44,
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 3,
            width: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF9CA3AF),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          Container(
            height: 2.5,
            width: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          Container(
            height: 2.5,
            width: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          Container(
            height: 2.5,
            width: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  (String, String, IconData, Color, Color) _resolveCategoryDisplay(
      TransactionCategoryType cat) {
    switch (cat) {
      case TransactionCategoryType.dining:
        return (
          'Dining & Takeout',
          'LKR 31,850 Left',
          Icons.restaurant_rounded,
          const Color(0xFFA855F7),
          const Color(0xFF2C1E3C),
        );
      case TransactionCategoryType.groceries:
        return (
          'Groceries & Supermarket',
          'LKR 45,200 Left',
          Icons.shopping_bag_outlined,
          const Color(0xFFF59E0B),
          const Color(0xFF2E2419),
        );
      case TransactionCategoryType.transport:
        return (
          'Transport & Fuel',
          'LKR 18,500 Left',
          Icons.directions_car_filled_rounded,
          const Color(0xFF38BDF8),
          const Color(0xFF162738),
        );
      case TransactionCategoryType.shopping:
        return (
          'Shopping & Retail',
          'LKR 24,000 Left',
          Icons.shopping_basket_outlined,
          const Color(0xFF06B6D4),
          const Color(0xFF162B33),
        );
      case TransactionCategoryType.bills:
        return (
          'Bills & Utilities',
          'LKR 12,300 Left',
          Icons.receipt_long_rounded,
          const Color(0xFFEC4899),
          const Color(0xFF2D1624),
        );
      case TransactionCategoryType.savings:
        return (
          'Savings & Investments',
          'LKR 150,000 Left',
          Icons.savings_outlined,
          AppColors.primary,
          const Color(0xFF1E2D16),
        );
      default:
        return (
          'General Category',
          'LKR 20,000 Left',
          Icons.account_balance_wallet_rounded,
          AppColors.primary,
          const Color(0xFF1E2D16),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = widget.transaction.type == TransactionType.expense;
    final categoryInfo = _resolveCategoryDisplay(_selectedCategory);

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

                  // Title: "Transaction Details"
                  const Text(
                    'Transaction Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  // Delete Button
                  GestureDetector(
                    onTap: _confirmDelete,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F1418),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFEF4444),
                          size: 20,
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
                    const SizedBox(height: 8),

                    // Top Hero Card: Merchant Avatar, Amount, Status, Cashback Tag
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131722),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF1E2332),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Merchant Avatar
                          _buildMerchantAvatar(),
                          const SizedBox(height: 14),

                          // Large Amount: "-LKR 3,150.00"
                          Text(
                            '${isExpense ? '-' : '+'}LKR ${currencyFormat.format(_amount)}',
                            style: TextStyle(
                              color: isExpense
                                  ? Colors.white
                                  : const Color(0xFF38BDF8),
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Status Subtitle: "Completed • Today, Oct 19 at 8:20 PM"
                          Text(
                            widget.transaction.subtitle.contains('•')
                                ? widget.transaction.subtitle
                                : 'Completed • ${widget.transaction.subtitle}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Cashback Badge Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF162B14),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.5,
                                  height: 6.5,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '+LKR ${currencyFormat.format(_cashback)} (1% Back)',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Details Card Group
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131722),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF1E2332),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. MERCHANT / PAYEE
                          const Text(
                            'MERCHANT / PAYEE',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _showEditMerchantDialog,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF181C26),
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: AppColors.darkBorder),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _merchantController.text,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.textSecondary,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // 2. BUDGET CATEGORY
                          const Text(
                            'BUDGET CATEGORY',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _showCategoryPickerSheet,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF181C26),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: categoryInfo.$5,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      categoryInfo.$3,
                                      color: categoryInfo.$4,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      categoryInfo.$1,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    categoryInfo.$2,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // 3. NOTE & TAGS
                          const Text(
                            'NOTE & TAGS',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _showEditNoteDialog,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF181C26),
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: AppColors.darkBorder),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _noteController.text.isNotEmpty
                                          ? _noteController.text
                                          : 'Add a note or tags...',
                                      style: TextStyle(
                                        color: _noteController.text.isNotEmpty
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.textSecondary,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // 4. ATTACHED RECEIPT (OCR VERIFIED or OPTIONAL)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _receiptFileName != null && _receiptFileName!.isNotEmpty
                                    ? 'ATTACHED RECEIPT (OCR VERIFIED)'
                                    : 'ATTACHED RECEIPT (OPTIONAL)',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              if (_receiptFileName != null && _receiptFileName!.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _receiptFileName = null;
                                      _receiptItemCount = null;
                                      _receiptMatchPercent = null;
                                      _receiptImagePath = null;
                                    });
                                  },
                                  child: const Text(
                                    'Remove',
                                    style: TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_receiptFileName != null && _receiptFileName!.isNotEmpty)
                            GestureDetector(
                              onTap: _showReceiptInspector,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF181C26),
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: AppColors.darkBorder),
                                ),
                                child: Row(
                                  children: [
                                    _buildMiniReceiptThumbnail(),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _receiptFileName!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            'Auto-extracted ${_receiptItemCount ?? 3} items • ${_receiptMatchPercent ?? 100}% Match',
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Tap to inspect full scanned image',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: _attachReceipt,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF181C26),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.darkBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF222838),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.receipt_long_outlined,
                                        color: AppColors.textSecondary,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'No receipt attached',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Optional • Tap to scan or upload',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B2E15),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: const Text(
                                        '+ Add',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Floating Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // Save Changes Primary Button
                  SizedBox(
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
                      onPressed: _saveChanges,
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

                  // Split Bill and Tax Invoice Row
                  Row(
                    children: [
                      // Split Bill Button
                      Expanded(
                        child: GestureDetector(
                          onTap: _showSplitBillSheet,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF161922),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.darkBorder),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(22, 14),
                                  painter: _VennCirclesPainter(),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Split Bill',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Tax Invoice Button
                      Expanded(
                        child: GestureDetector(
                          onTap: _showTaxInvoiceSheet,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF161922),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.darkBorder),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.file_download_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Tax Invoice',
                                  style: TextStyle(
                                    color: Colors.white,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the two overlapping Venn rings (Split Bill)
class _VennCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    const r = 6.0;
    canvas.drawCircle(const Offset(7, 7), r, paint);
    canvas.drawCircle(const Offset(15, 7), r, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
