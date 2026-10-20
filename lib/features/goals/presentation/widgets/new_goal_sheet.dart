import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/goal_model.dart';
import '../../providers/goals_provider.dart';

class NewGoalSheet extends ConsumerStatefulWidget {
  const NewGoalSheet({super.key});

  @override
  ConsumerState<NewGoalSheet> createState() => _NewGoalSheetState();
}

class _NewGoalSheetState extends ConsumerState<NewGoalSheet> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  final _monthlyController = TextEditingController();

  int _selectedColorIndex = 0;
  int _selectedIconIndex = 0;

  final List<Color> _colorOptions = const [
    AppColors.primary,
    Color(0xFFC084FC),
    Color(0xFF38BDF8),
    Color(0xFFFBBF24),
    Color(0xFFF43F5E),
  ];

  final List<IconData> _iconOptions = const [
    Icons.shield_outlined,
    Icons.flight_rounded,
    Icons.lock_outline_rounded,
    Icons.directions_car_rounded,
    Icons.home_outlined,
    Icons.laptop_chromebook_rounded,
    Icons.school_outlined,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a goal title'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final target = double.tryParse(_targetController.text.trim()) ?? 100000;
    final current = double.tryParse(_currentController.text.trim()) ?? 0;
    final monthly = double.tryParse(_monthlyController.text.trim()) ?? 10000;
    final subtitle = _subtitleController.text.trim().isEmpty
        ? 'Target Savings • Auto-saving'
        : _subtitleController.text.trim();

    final selectedColor = _colorOptions[_selectedColorIndex];
    final selectedIcon = _iconOptions[_selectedIconIndex];

    final pct = target > 0 ? ((current / target) * 100).round() : 0;

    final newGoal = GoalModel(
      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subtitle: subtitle,
      currentAmount: current,
      targetAmount: target,
      monthlyContribution: monthly,
      color: selectedColor,
      iconBg: selectedColor.withValues(alpha: 0.15),
      icon: selectedIcon,
      badgeText: pct >= 100 ? '100% Done' : '$pct% Saved',
      isAutoSaving: true,
    );

    ref.read(goalsProvider.notifier).addGoal(newGoal);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Goal "$title" created!'),
        backgroundColor: const Color(0xFF1B2E15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF121620),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFF1E2332), width: 1.5),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF262B36),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Create New Goal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Goal Title Input
            _buildTextField(
              controller: _titleController,
              label: 'Goal Name',
              hint: 'e.g. Wedding Fund, New Laptop',
            ),
            const SizedBox(height: 14),

            // Subtitle / Note
            _buildTextField(
              controller: _subtitleController,
              label: 'Details / Description',
              hint: 'e.g. Ella Retreat • Dec 2026',
            ),
            const SizedBox(height: 14),

            // Target Amount & Initial Saved
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _targetController,
                    label: 'Target (LKR)',
                    hint: '500,000',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _currentController,
                    label: 'Current Saved (LKR)',
                    hint: '50,000',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Monthly Contribution
            _buildTextField(
              controller: _monthlyController,
              label: 'Monthly Contribution (LKR)',
              hint: '25,000',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),

            // Color Selector
            const Text(
              'Accent Color',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(_colorOptions.length, (index) {
                final color = _colorOptions[index];
                final isSelected = _selectedColorIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 2.5)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded, color: Colors.black, size: 20)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),

            // Icon Selector
            const Text(
              'Icon',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_iconOptions.length, (index) {
                  final icon = _iconOptions[index];
                  final isSelected = _selectedIconIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _colorOptions[_selectedColorIndex].withValues(alpha: 0.2)
                            : const Color(0xFF1E2332),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? _colorOptions[_selectedColorIndex]
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? _colorOptions[_selectedColorIndex]
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: const Color(0xFF0C0F14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Create Goal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF262C3D)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF646B79),
                fontSize: 13,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
