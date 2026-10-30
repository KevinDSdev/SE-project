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

  void _showEditDialog(CustomCategoryItem item, Color cardBg, Color borderColor, Color textPrimary, Color textSecondary, Color subContainer, Color accentColor) {
    final controller = TextEditingController(text: item.name);
    Color selectedColor = item.color;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: borderColor),
          ),
          title: Text(
            'Edit ${_activeTab == CustomizationTab.incomeMethods ? "Income Source" : "Expense Category"}',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: subContainer,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Card Accent Color',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _palette.map((c) {
                  final isSel = selectedColor.toARGB32() == c.toARGB32();
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() => selectedColor = c);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: isSel
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
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
              child: Text(
                'Cancel',
                style: TextStyle(color: textSecondary),
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
                backgroundColor: accentColor,
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

  void _showAddDialog(Color cardBg, Color borderColor, Color textPrimary, Color textSecondary, Color subContainer, Color accentColor) {
    final controller = TextEditingController();
    Color selectedColor = _palette.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: borderColor),
          ),
          title: Text(
            'Add ${_activeTab == CustomizationTab.incomeMethods ? "Income Source" : "Expense Category"}',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Title',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller,
                autofocus: true,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Dividend Income, Investments',
                  hintStyle: TextStyle(
                    color: textSecondary.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: subContainer,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Color Theme',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _palette.map((c) {
                  final isSel = selectedColor.toARGB32() == c.toARGB32();
                  return GestureDetector(
                    onTap: () {
                      setDialogState(() => selectedColor = c);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: isSel
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
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
              child: Text(
                'Cancel',
                style: TextStyle(color: textSecondary),
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
                backgroundColor: accentColor,
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.getBg(isDark);
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final subContainer = AppColors.getSubContainer(isDark);

    final isIncome = _activeTab == CustomizationTab.incomeMethods;
    final currentItems = isIncome ? incomeItems : expenseItems;

    return Scaffold(
      backgroundColor: bg,
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
                        color: cardBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: textPrimary,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Analytics Customization',
                    style: TextStyle(
                      color: textPrimary,
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
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customize Sectors & Categories',
                      style: TextStyle(
                        color: textPrimary,
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
                                    : subContainer,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isIncome
                                      ? accentColor
                                      : borderColor,
                                  width: isIncome ? 1.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Income Methods',
                                  style: TextStyle(
                                    color: isIncome
                                        ? accentColor
                                        : textSecondary,
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
                                    : subContainer,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: !isIncome
                                      ? accentColor
                                      : borderColor,
                                  width: !isIncome ? 1.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Expense Categories',
                                  style: TextStyle(
                                    color: !isIncome
                                        ? accentColor
                                        : textSecondary,
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
                                onTap: () => _showEditDialog(item, cardBg, borderColor, textPrimary, textSecondary, subContainer, accentColor),
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
                      onTap: () => _showAddDialog(cardBg, borderColor, textPrimary, textSecondary, subContainer, accentColor),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: cardBg,
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
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Apply Layout to All 3 Sub-Dashboards',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: applyToSub,
                      activeColor: Colors.white,
                      activeTrackColor: accentColor,
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
                        backgroundColor: cardBg,
                        content: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: accentColor,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Customization applied successfully.',
                                style: TextStyle(
                                  color: textPrimary,
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
