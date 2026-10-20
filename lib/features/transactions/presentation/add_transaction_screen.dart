import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../models/transaction_model.dart';
import '../providers/transactions_provider.dart';
import 'receipt_capture_screen.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionType initialType;

  const AddTransactionScreen({
    super.key,
    this.initialType = TransactionType.expense,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _morphController;
  late Animation<double> _morphAnimation;

  late TransactionType _currentType;
  double _expenseAmount = 0.00;
  double _incomeAmount = 0.00;

  final TextEditingController _expenseNoteController = TextEditingController();
  final TextEditingController _incomeNoteController = TextEditingController();

  TransactionCategoryType? _selectedExpenseCategory;
  TransactionCategoryType? _selectedIncomeCategory;

  final currencyFormat = NumberFormat('#,##0.00', 'en_US');

  // Palette constants
  static const Color expenseColor = AppColors.primary; // Lime green #8CE827
  static const Color incomeColor = Color(0xFF38BDF8); // Electric sky blue #38BDF8
  static const Color darkCardBg = Color(0xFF141720);
  static const Color darkInputBg = Color(0xFF161922);

  @override
  void initState() {
    super.initState();
    _currentType = widget.initialType;

    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: _currentType == TransactionType.expense ? 0.0 : 1.0,
    );

    _morphAnimation = CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _morphController.dispose();
    _expenseNoteController.dispose();
    _incomeNoteController.dispose();
    super.dispose();
  }

  void _switchType(TransactionType type) {
    if (_currentType == type) return;
    setState(() {
      _currentType = type;
      if (type == TransactionType.expense) {
        _morphController.reverse();
      } else {
        _morphController.forward();
      }
    });
  }

  String _formatBufferRealtime(String buffer) {
    if (buffer.isEmpty) return '0.00';
    if (buffer.contains('.')) {
      final parts = buffer.split('.');
      final intStr = parts[0].isEmpty ? '0' : parts[0];
      final intVal = int.tryParse(intStr) ?? 0;
      final formattedInt = NumberFormat('#,##0', 'en_US').format(intVal);
      final decimals = parts.length > 1 ? parts[1] : '';
      return '$formattedInt.$decimals';
    } else {
      final intVal = int.tryParse(buffer) ?? 0;
      return NumberFormat('#,##0', 'en_US').format(intVal);
    }
  }

  void _showKeypadModal(bool isExpense) {
    final currentVal = isExpense ? _expenseAmount : _incomeAmount;
    String currentBuffer = currentVal > 0
        ? (currentVal.toStringAsFixed(2).endsWith('.00')
            ? currentVal.toInt().toString()
            : currentVal.toStringAsFixed(2))
        : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setKeypadState) {
            final activeColor = isExpense ? expenseColor : incomeColor;

            return SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.darkBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isExpense ? 'Enter Expense Amount' : 'Enter Income Amount',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'LKR ${_formatBufferRealtime(currentBuffer)}',
                        style: TextStyle(
                          color: activeColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 4x3 Keypad Grid
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        childAspectRatio: 2.1,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (var i = 1; i <= 9; i++)
                            _buildKeypadKey(
                              label: '$i',
                              onTap: () {
                                setKeypadState(() {
                                  if (currentBuffer.contains('.')) {
                                    final decimals = currentBuffer.split('.')[1];
                                    if (decimals.length >= 2) return;
                                  }
                                  if (currentBuffer == '0') currentBuffer = '';
                                  if (currentBuffer.length >= 12) return;
                                  currentBuffer += '$i';
                                });
                              },
                            ),
                          _buildKeypadKey(
                            label: '.',
                            onTap: () {
                              setKeypadState(() {
                                if (!currentBuffer.contains('.')) {
                                  currentBuffer = currentBuffer.isEmpty ? '0.' : '$currentBuffer.';
                                }
                              });
                            },
                          ),
                          _buildKeypadKey(
                            label: '0',
                            onTap: () {
                              setKeypadState(() {
                                if (currentBuffer.contains('.')) {
                                    final decimals = currentBuffer.split('.')[1];
                                    if (decimals.length >= 2) return;
                                }
                                if (currentBuffer.isNotEmpty && currentBuffer != '0') {
                                  currentBuffer += '0';
                                }
                              });
                            },
                          ),
                          _buildKeypadKey(
                            icon: Icons.backspace_outlined,
                            onTap: () {
                              setKeypadState(() {
                                if (currentBuffer.isNotEmpty) {
                                  currentBuffer = currentBuffer.substring(0, currentBuffer.length - 1);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeColor,
                            foregroundColor: const Color(0xFF0C0F14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            final parsed = double.tryParse(currentBuffer) ?? 0.0;
                            setState(() {
                              if (isExpense) {
                                _expenseAmount = parsed;
                              } else {
                                _incomeAmount = parsed;
                              }
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildKeypadKey({
    String? label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF1C202C),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Center(
          child: label != null
              ? Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  void _handleSubmit() {
    final isExpense = _currentType == TransactionType.expense;
    final amount = isExpense ? _expenseAmount : _incomeAmount;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount greater than 0.'),
          backgroundColor: AppColors.error,
        ),
      );
      _showKeypadModal(isExpense);
      return;
    }

    if (isExpense) {
      final merchant = _expenseNoteController.text.trim();
      if (merchant.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a merchant or description.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      if (_selectedExpenseCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an expense category.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      ref.read(transactionsProvider.notifier).addExpense(
            amount: amount,
            merchant: merchant,
            category: _selectedExpenseCategory!,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense of LKR ${currencyFormat.format(amount)} added.'),
          backgroundColor: AppColors.darkCard,
        ),
      );
    } else {
      final source = _incomeNoteController.text.trim();
      if (source.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter an income source.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      if (_selectedIncomeCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an income category.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      ref.read(transactionsProvider.notifier).addIncome(
            amount: amount,
            source: source,
            category: _selectedIncomeCategory!,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Income of LKR ${currencyFormat.format(amount)} recorded.'),
          backgroundColor: AppColors.darkCard,
        ),
      );
    }

    Navigator.pop(context);
  }

  Future<void> _openReceiptScanner() async {
    final result = await Navigator.of(context).push<ReceiptScanResult>(
      MaterialPageRoute(
        builder: (_) => const ReceiptCaptureScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _expenseAmount = result.amount;
        _expenseNoteController.text = result.merchant;
        _selectedExpenseCategory = result.category;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Receipt Scanned! Extracted LKR ${currencyFormat.format(result.amount)} from ${result.merchant}.',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _morphAnimation,
      builder: (context, child) {
        final t = _morphAnimation.value; // 0.0 = Expense (Green), 1.0 = Income (Blue)
        final activeColor = Color.lerp(expenseColor, incomeColor, t)!;

        return Scaffold(
          backgroundColor: AppColors.darkBg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top App Bar: Close Button, Title, and Action Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Circular Close button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),

                      // Morphing Screen Title
                      Text(
                        t < 0.5 ? 'Add Transaction' : 'Record Inflow',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),

                      // Morphing Right Action Button (Scanner / Document)
                      GestureDetector(
                        onTap: () {
                          if (t < 0.5) {
                            _openReceiptScanner();
                          }
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: Icon(
                            t < 0.5 ? Icons.crop_free_rounded : Icons.receipt_long_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Morphing Top Segmented Slider (Expense vs Income)
                  Center(
                    child: Container(
                      width: 270,
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161922),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final halfWidth = (constraints.maxWidth) / 2;

                          return Stack(
                            children: [
                              // Sliding indicator pill
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeInOutCubic,
                                left: _currentType == TransactionType.expense ? 0 : halfWidth,
                                top: 0,
                                bottom: 0,
                                width: halfWidth,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: activeColor,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: activeColor.withValues(alpha: 0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Text Labels Row
                              Row(
                                children: [
                                  // Expense Tab
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => _switchType(TransactionType.expense),
                                      child: Center(
                                        child: Text(
                                          'Expense',
                                          style: TextStyle(
                                            color: _currentType == TransactionType.expense
                                                ? const Color(0xFF0C0F14)
                                                : AppColors.textSecondary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Income Tab
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => _switchType(TransactionType.income),
                                      child: Center(
                                        child: Text(
                                          'Income',
                                          style: TextStyle(
                                            color: _currentType == TransactionType.income
                                                ? const Color(0xFF0C0F14)
                                                : AppColors.textSecondary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Morphing Amount Card
                  GestureDetector(
                    onTap: () => _showKeypadModal(_currentType == TransactionType.expense),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                      decoration: BoxDecoration(
                        color: darkCardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: activeColor.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Subtle Glow Halo behind the numbers
                          Container(
                            width: 130,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: activeColor.withValues(alpha: 0.12),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                t < 0.5 ? 'Enter Amount Spent' : 'Enter Income Received',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: t < 0.5 ? 'LKR ' : '+LKR ',
                                      style: TextStyle(
                                        color: t < 0.5 ? Colors.white70 : activeColor,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: _formatIntegerPart(t < 0.5 ? _expenseAmount : _incomeAmount),
                                      style: TextStyle(
                                        color: activeColor,
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.6,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '.${_formatDecimalPart(t < 0.5 ? _expenseAmount : _incomeAmount)}',
                                      style: TextStyle(
                                        color: activeColor,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                (t < 0.5 ? _expenseAmount : _incomeAmount) == 0.0
                                    ? 'Tap to enter amount with keypad'
                                    : 'Tap to edit amount with keypad',
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description / Merchant Input
                  Container(
                    decoration: BoxDecoration(
                      color: darkInputBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: activeColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            t < 0.5 ? Icons.edit_outlined : Icons.business_center_outlined,
                            color: activeColor,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: t < 0.5 ? _expenseNoteController : _incomeNoteController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: t < 0.5
                                  ? 'Enter merchant / description (e.g. Keells, Dialog...)'
                                  : 'Enter income source (e.g. Salary, Freelance...)',
                              hintStyle: const TextStyle(
                                color: Color(0xFF5A606D),
                                fontSize: 14,
                              ),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Category Header: "Select Category" vs "Income Category"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t < 0.5 ? 'Select Category' : 'Income Category',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Required',
                        style: TextStyle(
                          color: activeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Morphing Category Grid
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: t < 0.5 ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    firstChild: _buildExpenseCategoriesGrid(),
                    secondChild: _buildIncomeCategoriesGrid(),
                  ),
                  const SizedBox(height: 18),

                  // Morphing Secondary Action Card (Receipt Scan vs Bank Deposit Account)
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: t < 0.5 ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    firstChild: _buildCaptureReceiptCard(),
                    secondChild: _buildDepositAccountCard(),
                  ),
                  const SizedBox(height: 24),

                  // Primary Morphing Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeColor,
                        foregroundColor: const Color(0xFF0C0F14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _handleSubmit,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            t < 0.5 ? 'Confirm & Add Transaction' : 'Confirm & Record Income',
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Subtext below button
                  Center(
                    child: Text(
                      t < 0.5
                          ? (_selectedExpenseCategory != null
                              ? 'Auto-deducts from your ${_getCategoryName(_selectedExpenseCategory)} budget cap'
                              : 'Select an expense category to allocate')
                          : (_selectedIncomeCategory != null
                              ? 'Increases your available monthly budget pool'
                              : 'Select an income category to record inflow'),
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatIntegerPart(double amount) {
    final str = amount.toStringAsFixed(2);
    final parts = str.split('.');
    final intVal = int.tryParse(parts[0]) ?? 0;
    return NumberFormat('#,##0', 'en_US').format(intVal);
  }

  String _formatDecimalPart(double amount) {
    final str = amount.toStringAsFixed(2);
    final parts = str.split('.');
    return parts.length > 1 ? parts[1] : '00';
  }

  String _getCategoryName(TransactionCategoryType? cat) {
    if (cat == null) return 'selected';
    switch (cat) {
      case TransactionCategoryType.dining:
        return 'Dining (LKR 35,000)';
      case TransactionCategoryType.groceries:
        return 'Groceries (LKR 65,000)';
      case TransactionCategoryType.transport:
        return 'Transport (LKR 30,000)';
      case TransactionCategoryType.shopping:
        return 'Shopping (LKR 25,000)';
      case TransactionCategoryType.bills:
        return 'Bills / CEB (Fixed)';
      case TransactionCategoryType.savings:
        return 'Savings Fund';
      default:
        return 'Budget';
    }
  }

  // 6 Expense Categories Grid
  Widget _buildExpenseCategoriesGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCategoryCard(
                title: 'Dining',
                subtitle: _selectedExpenseCategory == TransactionCategoryType.dining ? 'Selected' : 'Cap: 35K',
                icon: Icons.restaurant_rounded,
                iconColor: const Color(0xFFA855F7),
                iconBg: const Color(0xFF281E38),
                isSelected: _selectedExpenseCategory == TransactionCategoryType.dining,
                activeColor: expenseColor,
                onTap: () => setState(() => _selectedExpenseCategory = TransactionCategoryType.dining),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCategoryCard(
                title: 'Groceries',
                subtitle: _selectedExpenseCategory == TransactionCategoryType.groceries ? 'Selected' : 'Cap: 65K',
                icon: Icons.shopping_bag_outlined,
                iconColor: const Color(0xFFF59E0B),
                iconBg: const Color(0xFF2E2419),
                isSelected: _selectedExpenseCategory == TransactionCategoryType.groceries,
                activeColor: expenseColor,
                onTap: () => setState(() => _selectedExpenseCategory = TransactionCategoryType.groceries),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCategoryCard(
                title: 'Transport',
                subtitle: _selectedExpenseCategory == TransactionCategoryType.transport ? 'Selected' : 'Cap: 30K',
                icon: Icons.directions_car_filled_rounded,
                iconColor: const Color(0xFF38BDF8),
                iconBg: const Color(0xFF162738),
                isSelected: _selectedExpenseCategory == TransactionCategoryType.transport,
                activeColor: expenseColor,
                onTap: () => setState(() => _selectedExpenseCategory = TransactionCategoryType.transport),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildCategoryCard(
                title: 'Shopping',
                subtitle: _selectedExpenseCategory == TransactionCategoryType.shopping ? 'Selected' : 'Cap: 25K',
                icon: Icons.shopping_basket_outlined,
                iconColor: const Color(0xFF06B6D4),
                iconBg: const Color(0xFF162B33),
                isSelected: _selectedExpenseCategory == TransactionCategoryType.shopping,
                activeColor: expenseColor,
                onTap: () => setState(() => _selectedExpenseCategory = TransactionCategoryType.shopping),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCategoryCard(
                title: 'Bills / CEB',
                subtitle: _selectedExpenseCategory == TransactionCategoryType.bills ? 'Selected' : 'Fixed Bills',
                icon: Icons.bolt_rounded,
                iconColor: const Color(0xFFFBBF24),
                iconBg: const Color(0xFF302616),
                isSelected: _selectedExpenseCategory == TransactionCategoryType.bills,
                activeColor: expenseColor,
                onTap: () => setState(() => _selectedExpenseCategory = TransactionCategoryType.bills),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCategoryCard(
                title: 'Savings',
                subtitle: _selectedExpenseCategory == TransactionCategoryType.savings ? 'Selected' : 'Goal Fund',
                icon: Icons.track_changes_rounded,
                iconColor: const Color(0xFF8CE827),
                iconBg: const Color(0xFF1D2C12),
                isSelected: _selectedExpenseCategory == TransactionCategoryType.savings,
                activeColor: expenseColor,
                onTap: () => setState(() => _selectedExpenseCategory = TransactionCategoryType.savings),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 6 Income Categories Grid
  Widget _buildIncomeCategoriesGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCategoryCard(
                title: 'Salary',
                subtitle: _selectedIncomeCategory == TransactionCategoryType.salary ? 'Selected' : 'Monthly Pay',
                icon: Icons.lock_outline_rounded,
                iconColor: const Color(0xFF38BDF8),
                iconBg: const Color(0xFF162738),
                isSelected: _selectedIncomeCategory == TransactionCategoryType.salary,
                activeColor: incomeColor,
                onTap: () => setState(() => _selectedIncomeCategory = TransactionCategoryType.salary),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCategoryCard(
                title: 'Freelance',
                subtitle: _selectedIncomeCategory == TransactionCategoryType.freelance ? 'Selected' : 'Consulting',
                icon: Icons.laptop_mac_rounded,
                iconColor: const Color(0xFF60A5FA),
                iconBg: const Color(0xFF1A263D),
                isSelected: _selectedIncomeCategory == TransactionCategoryType.freelance,
                activeColor: incomeColor,
                onTap: () => setState(() => _selectedIncomeCategory = TransactionCategoryType.freelance),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCategoryCard(
                title: 'Dividends',
                subtitle: _selectedIncomeCategory == TransactionCategoryType.dividends ? 'Selected' : 'Stocks / Units',
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFFF59E0B),
                iconBg: const Color(0xFF2E2419),
                isSelected: _selectedIncomeCategory == TransactionCategoryType.dividends,
                activeColor: incomeColor,
                onTap: () => setState(() => _selectedIncomeCategory = TransactionCategoryType.dividends),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildCategoryCard(
                title: 'Rental',
                subtitle: _selectedIncomeCategory == TransactionCategoryType.rental ? 'Selected' : 'Tenant Rent',
                icon: Icons.home_rounded,
                iconColor: const Color(0xFFA855F7),
                iconBg: const Color(0xFF281E38),
                isSelected: _selectedIncomeCategory == TransactionCategoryType.rental,
                activeColor: incomeColor,
                onTap: () => setState(() => _selectedIncomeCategory = TransactionCategoryType.rental),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCategoryCard(
                title: 'Rewards',
                subtitle: _selectedIncomeCategory == TransactionCategoryType.rewards ? 'Selected' : 'Cashback',
                icon: Icons.star_rounded,
                iconColor: const Color(0xFF2DD4BF),
                iconBg: const Color(0xFF122C28),
                isSelected: _selectedIncomeCategory == TransactionCategoryType.rewards,
                activeColor: incomeColor,
                onTap: () => setState(() => _selectedIncomeCategory = TransactionCategoryType.rewards),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCategoryCard(
                title: 'Transfers',
                subtitle: _selectedIncomeCategory == TransactionCategoryType.transfers ? 'Selected' : 'Gifts & Misc',
                icon: Icons.add_rounded,
                iconColor: const Color(0xFF94A3B8),
                iconBg: const Color(0xFF222836),
                isSelected: _selectedIncomeCategory == TransactionCategoryType.transfers,
                activeColor: incomeColor,
                onTap: () => setState(() => _selectedIncomeCategory = TransactionCategoryType.transfers),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B221B) : darkCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.darkBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isSelected ? activeColor : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: activeColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF0C0F14),
                    size: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Expense Secondary Card: "Capture Receipt"
  Widget _buildCaptureReceiptCard() {
    return GestureDetector(
      onTap: _openReceiptScanner,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: darkInputBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: expenseColor.withValues(alpha: 0.6), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: expenseColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: expenseColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Capture Receipt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Take a photo to auto-extract details',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2E15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Scan',
                style: TextStyle(
                  color: expenseColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Income Secondary Card: "Deposit into Commercial Bank"
  Widget _buildDepositAccountCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: darkInputBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: incomeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.credit_card_rounded,
              color: incomeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deposit into Commercial Bank (••4821)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Current Balance: LKR 1,845,000',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
