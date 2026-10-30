import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/analytics_provider.dart';

class ExportModuleDefinition {
  final String id;
  final String title;
  final Color cardColor;
  final IconData icon;

  const ExportModuleDefinition({
    required this.id,
    required this.title,
    required this.cardColor,
    required this.icon,
  });
}

class SelectExportRequirementScreen extends ConsumerWidget {
  const SelectExportRequirementScreen({super.key});

  static const List<ExportModuleDefinition> allModules = [
    ExportModuleDefinition(
      id: 'trans_history',
      title: 'Transaction History',
      cardColor: Color(0xFFB088F6),
      icon: Icons.sync_alt_rounded,
    ),
    ExportModuleDefinition(
      id: 'inc_analysis',
      title: 'Income Analysis',
      cardColor: Color(0xFF98E836),
      icon: Icons.price_check_rounded,
    ),
    ExportModuleDefinition(
      id: 'exp_analysis',
      title: 'Expenses Analysis',
      cardColor: Color(0xFFFF5268),
      icon: Icons.payments_rounded,
    ),
    ExportModuleDefinition(
      id: 'goal_savings',
      title: 'Goal Savings Analysis',
      cardColor: Color(0xFF38BDF8),
      icon: Icons.track_changes_rounded,
    ),
    ExportModuleDefinition(
      id: 'inc_pred',
      title: 'Income Prediction Analysis',
      cardColor: Color(0xFF98E836),
      icon: Icons.manage_search_rounded,
    ),
    ExportModuleDefinition(
      id: 'exp_pred',
      title: 'Expenses Prediction Analysis',
      cardColor: Color(0xFFFF5268),
      icon: Icons.troubleshoot_rounded,
    ),
    ExportModuleDefinition(
      id: 'debt_invest',
      title: 'Debt, BNPL & Investments',
      cardColor: Color(0xFFD9822B),
      icon: Icons.account_balance_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportPrefs = ref.watch(exportPreferencesProvider);
    final accentColor = ref.watch(accentColorProvider).color;
    final selectedSet = exportPrefs.selectedRequirements;
    final selectedCount = selectedSet.length;
    final totalCount = allModules.length;
    final allSelected = selectedCount == totalCount;

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                        'Select Requirement',
                        style: TextStyle(
                          color: AppColors.lightTextPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(exportPreferencesProvider.notifier)
                          .selectAll(allModules.map((m) => m.id).toList());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        allSelected ? 'Deselect All' : 'Select All',
                        style: const TextStyle(
                          color: Color(0xFF0C0F14),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Selected Counter Pill
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    '$selectedCount of $totalCount modules selected',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Module Cards List
              ...allModules.map((mod) {
                final isChecked = selectedSet.contains(mod.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(exportPreferencesProvider.notifier)
                          .toggleRequirement(mod.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: mod.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              mod.icon,
                              color: const Color(0xFF0C0F14),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              mod.title,
                              style: const TextStyle(
                                color: Color(0xFF0C0F14),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isChecked
                                  ? const Color(0xFF0C0F14)
                                  : Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: isChecked
                                ? const Center(
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
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
                    'Confirm',
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
