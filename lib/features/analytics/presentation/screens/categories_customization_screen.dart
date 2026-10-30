import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/analytics_provider.dart';

enum CustomizationTab { incomeMethods, expenseCategories }

class CategoriesCustomizationScreen extends ConsumerStatefulWidget {
  final CustomizationTab initialTab;

  const CategoriesCustomizationScreen({
    super.key,
    this.initialTab = CustomizationTab.incomeMethods,
  });

  @override
  ConsumerState<CategoriesCustomizationScreen> createState() =>
      _CategoriesCustomizationScreenState();
}

class _CategoriesCustomizationScreenState
    extends ConsumerState<CategoriesCustomizationScreen> {
  late CustomizationTab _activeTab;

  final List<Color> _palette = const [
    Color(0xFF98E836), // Lime green
    Color(0xFFF43F5E), // Rose red
    Color(0xFF38BDF8), // Sky blue
    Color(0xFF9353D3), // Purple
    Color(0xFFF59E0B), // Amber
    Color(0xFF38BDF8), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF10B981), // Emerald
  ];

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  void _showEditDialog(CustomCategoryItem item) {
    final controller = TextEditingController(text: item.name);
    Color selectedColor = item.color;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: AppColors.lightBorder),
          ),
          title: Text(
            'Edit ${_activeTab == CustomizationTab.incomeMethods ? "Income Source" : "Expense Category"}',
            style: const TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Name',
                style: TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller,
                style: const TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.lightSubContainer,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lightBorder),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Card Accent Color',
                style: TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _palette.map((col) {
                  final isSel = col.toARGB32() == selectedColor.toARGB32();
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = col),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: col,
                        shape: BoxShape.circle,
                        border: isSel
                            ? Border.all(color: AppColors.lightTextPrimary, width: 2.5)
                            : Border.all(color: AppColors.lightBorder, width: 1),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.lightTextSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                if (_activeTab == CustomizationTab.incomeMethods) {
                  ref.read(incomeMethodsProvider.notifier).remove(item.id);
                } else {
                  ref.read(expenseCategoriesProvider.notifier).remove(item.id);
                }
                Navigator.of(ctx).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFF43F5E)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  if (_activeTab == CustomizationTab.incomeMethods) {
                    ref.read(incomeMethodsProvider.notifier).update(
                          item.id,
                          text,
                          selectedColor,
                        );
                  } else {
                    ref.read(expenseCategoriesProvider.notifier).update(
                          item.id,
                          text,
                          selectedColor,
                        );
                  }
                }
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF98E836),
                foregroundColor: const Color(0xFF0C0F14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog() {
    final controller = TextEditingController();
    Color selectedColor = _palette.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: AppColors.lightBorder),
          ),
          title: Text(
            'Add ${_activeTab == CustomizationTab.incomeMethods ? "Income Source" : "Expense Category"}',
            style: const TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Title',
                style: TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Dividend Payouts / Subscriptions',
                  hintStyle: const TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: AppColors.lightSubContainer,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lightBorder),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Badge Color',
                style: TextStyle(
                  color: AppColors.lightTextSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _palette.map((col) {
                  final isSel = col.toARGB32() == selectedColor.toARGB32();
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = col),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: col,
                        shape: BoxShape.circle,
                        border: isSel
                            ? Border.all(color: AppColors.lightTextPrimary, width: 2.5)
                            : Border.all(color: AppColors.lightBorder, width: 1),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.lightTextSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  if (_activeTab == CustomizationTab.incomeMethods) {
                    ref.read(incomeMethodsProvider.notifier).add(text, selectedColor);
                  } else {
                    ref.read(expenseCategoriesProvider.notifier).add(text, selectedColor);
                  }
                }
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF98E836),
                foregroundColor: const Color(0xFF0C0F14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incomeItems = ref.watch(incomeMethodsProvider);
    final expenseItems = ref.watch(expenseCategoriesProvider);
    final applyToSub = ref.watch(applySubDashboardsLayoutProvider);
    final accentColor = ref.watch(accentColorProvider).color;

    final isIncome = _activeTab == CustomizationTab.incomeMethods;
    final currentItems = isIncome ? incomeItems : expenseItems;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.lightTextPrimary,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Analytics Customization',
                    style: TextStyle(
                      color: AppColors.lightTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Main Customization Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customize Sectors & Categories',
                      style: TextStyle(
                        color: AppColors.lightTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Two segmented tabs
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _activeTab = CustomizationTab.incomeMethods),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isIncome
                                    ? accentColor.withValues(alpha: 0.15)
                                    : AppColors.lightSubContainer,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isIncome
                                      ? accentColor
                                      : AppColors.lightBorder,
                                  width: isIncome ? 1.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Income Methods',
                                  style: TextStyle(
                                    color: isIncome
                                        ? accentColor
                                        : AppColors.lightTextSecondary,
                                    fontSize: 13,
                                    fontWeight: isIncome
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() =>
                                _activeTab = CustomizationTab.expenseCategories),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isIncome
                                    ? accentColor.withValues(alpha: 0.15)
                                    : AppColors.lightSubContainer,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: !isIncome
                                      ? accentColor
                                      : AppColors.lightBorder,
                                  width: !isIncome ? 1.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Expense Categories',
                                  style: TextStyle(
                                    color: !isIncome
                                        ? accentColor
                                        : AppColors.lightTextSecondary,
                                    fontSize: 13,
                                    fontWeight: !isIncome
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Category Cards List
                    ...currentItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    color: Color(0xFF0C0F14),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showEditDialog(item),
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: Color(0xFF0C0F14),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Add Custom Button
                    GestureDetector(
                      onTap: _showAddDialog,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: accentColor,
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            isIncome
                                ? '+ Add Custom Income Source or Category'
                                : '+ Add Custom Expense Source or Category',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Apply Layout to All 3 Sub-Dashboards Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Apply Layout to All 3 Sub-Dashboards',
                        style: TextStyle(
                          color: AppColors.lightTextPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch(
                      value: applyToSub,
                      onChanged: (val) {
                        ref
                            .read(applySubDashboardsLayoutProvider.notifier)
                            .setVal(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Save & Apply Customization Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.white,
                        content: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: accentColor,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Customization applied successfully.',
                                style: TextStyle(
                                  color: AppColors.lightTextPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: accentColor),
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: const Color(0xFF0C0F14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save & Apply Customization',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
