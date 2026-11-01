import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/budget_template_model.dart';
import 'custom_budget_template_screen.dart';
import 'essential_budget_template_screen.dart';
import 'family_budget_template_screen.dart';
import 'student_budget_template_screen.dart';

/// Screen 07 – Budget Template Selection
/// Faithfully reproduces Figma Screen 07 from "07 - Budget Template Selection.png"
class BudgetTemplateSelectionScreen extends ConsumerStatefulWidget {
  const BudgetTemplateSelectionScreen({super.key});

  @override
  ConsumerState<BudgetTemplateSelectionScreen> createState() =>
      _BudgetTemplateSelectionScreenState();
}

class _BudgetTemplateSelectionScreenState
    extends ConsumerState<BudgetTemplateSelectionScreen> {
  // Default selected template matching design is 'student'
  String _selectedTemplateId = 'student';

  void _navigateToTemplate(String templateId) {
    setState(() {
      _selectedTemplateId = templateId;
    });

    Widget destination;
    switch (templateId) {
      case 'essential':
        destination = const EssentialBudgetTemplateScreen();
        break;
      case 'student':
        destination = const StudentBudgetTemplateScreen();
        break;
      case 'family':
        destination = const FamilyBudgetTemplateScreen();
        break;
      case 'custom':
        destination = const CustomBudgetTemplateScreen();
        break;
      default:
        destination = const EssentialBudgetTemplateScreen();
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => destination),
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
                  // Back button '<'
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
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

                  // Title: "Budget Templates"
                  const Text(
                    'Budget Templates',
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

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // 1. Essential Budget Card
                    _buildTemplateCard(
                      template: PredefinedBudgetTemplates.essential,
                      isSelected: _selectedTemplateId == 'essential',
                      accentColor: accentColor,
                      onTap: () => _navigateToTemplate('essential'),
                    ),
                    const SizedBox(height: 14),

                    // 2. Student Budget Card
                    _buildTemplateCard(
                      template: PredefinedBudgetTemplates.student,
                      isSelected: _selectedTemplateId == 'student',
                      accentColor: accentColor,
                      onTap: () => _navigateToTemplate('student'),
                    ),
                    const SizedBox(height: 14),

                    // 3. Family Budget Card
                    _buildTemplateCard(
                      template: PredefinedBudgetTemplates.family,
                      isSelected: _selectedTemplateId == 'family',
                      accentColor: accentColor,
                      onTap: () => _navigateToTemplate('family'),
                    ),
                    const SizedBox(height: 14),

                    // 4. Custom Budget Card
                    _buildTemplateCard(
                      template: PredefinedBudgetTemplates.custom,
                      isSelected: _selectedTemplateId == 'custom',
                      accentColor: accentColor,
                      onTap: () => _navigateToTemplate('custom'),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Button: Preview Template (Solid Lime Green)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: SizedBox(
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
                  onPressed: () => _navigateToTemplate(_selectedTemplateId),
                  child: const Text(
                    'Preview Template',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
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

  Widget _buildTemplateCard({
    required BudgetTemplate template,
    required bool isSelected,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF131722),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFF1E2332),
            width: isSelected ? 1.5 : 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon in white rounded box
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  template.icon,
                  color: template.iconColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Information Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    template.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    template.focusText,
                    style: TextStyle(
                      color: isSelected ? accentColor : const Color(0xFFCBD5E1),
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Selection Radio / Check Indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? accentColor : const Color(0xFF1A1F2C),
                border: Border.all(
                  color: isSelected ? accentColor : const Color(0xFF2E364A),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        color: Color(0xFF0C0F14),
                        size: 16,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
