import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/settings_provider.dart';

class SetReminderDialog extends ConsumerStatefulWidget {
  const SetReminderDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SetReminderDialog(),
    );
  }

  @override
  ConsumerState<SetReminderDialog> createState() => _SetReminderDialogState();
}

class _SetReminderDialogState extends ConsumerState<SetReminderDialog> {
  final TextEditingController _titleController =
      TextEditingController(text: 'Log Daily Expenses');
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  String _selectedRecurrence = 'Everyday';

  final List<String> _recurrenceOptions = [
    'Everyday',
    'Weekdays',
    'Weekends',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = ref.watch(accentColorProvider).color;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Set Custom Reminder',
                style: TextStyle(
                  color: AppColors.lightTextPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.lightTextSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Text(
            'Receive reminders to review budgets or log cash transactions.',
            style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'REMINDER TITLE',
            style: TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: AppColors.lightTextPrimary, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.lightSubContainer,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.lightBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: accentColor),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Time Picker
          const Text(
            'REMINDER TIME',
            style: TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (picked != null) {
                setState(() => _selectedTime = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.lightSubContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          color: accentColor, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(
                          color: AppColors.lightTextPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Change',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Recurrence
          const Text(
            'RECURRENCE',
            style: TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: _recurrenceOptions.map((opt) {
              final isSel = _selectedRecurrence == opt;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRecurrence = opt),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSel
                          ? accentColor.withValues(alpha: 0.15)
                          : AppColors.lightSubContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSel ? accentColor : AppColors.lightBorder,
                        width: isSel ? 1.6 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        opt,
                        style: TextStyle(
                          color: isSel ? accentColor : AppColors.lightTextSecondary,
                          fontSize: 13,
                          fontWeight:
                              isSel ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final title = _titleController.text.trim();
                if (title.isNotEmpty) {
                  ref.read(customRemindersProvider.notifier).addReminder(
                        title,
                        _selectedTime,
                        _selectedRecurrence,
                      );
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.white,
                    content: Text(
                      'Reminder "$title" scheduled at ${_selectedTime.format(context)} ($_selectedRecurrence).',
                      style: const TextStyle(color: AppColors.lightTextPrimary, fontSize: 13),
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: accentColor),
                    ),
                  ),
                );
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
                'Save Reminder',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
