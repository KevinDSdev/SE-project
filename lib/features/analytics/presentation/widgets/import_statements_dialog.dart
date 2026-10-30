import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../settings/providers/settings_provider.dart';

class ImportStatementsDialog extends ConsumerStatefulWidget {
  const ImportStatementsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ImportStatementsDialog(),
    );
  }

  @override
  ConsumerState<ImportStatementsDialog> createState() => _ImportStatementsDialogState();
}

class _ImportStatementsDialogState extends ConsumerState<ImportStatementsDialog> {
  String _selectedFormat = 'PDF';
  String _selectedBank = 'Bank of Ceylon (BOC)';
  String? _selectedFileName;
  bool _isLoading = false;

  final List<String> _banks = [
    'Bank of Ceylon (BOC)',
    'Commercial Bank of Ceylon',
    'Hatton National Bank (HNB)',
    'Sampath Bank',
    'Nations Trust Bank',
  ];

  @override
  Widget build(BuildContext context) {
    final accentColor = ref.watch(accentColorProvider).color;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCard(isDark);
    final borderColor = AppColors.getBorder(isDark);
    final textPrimary = AppColors.getTextPrimary(isDark);
    final textSecondary = AppColors.getTextSecondary(isDark);
    final subContainer = AppColors.getSubContainer(isDark);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: borderColor, width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Import Statements',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Text(
            'Upload your e-statement (PDF or Excel) to automatically synchronize transactions.',
            style: TextStyle(
              color: textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // File Format Selector
          Text(
            'STATEMENT FORMAT',
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildFormatChip(label: 'PDF Statement', format: 'PDF', icon: Icons.picture_as_pdf_rounded, color: const Color(0xFFF43F5E), subContainer: subContainer, borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary),
              const SizedBox(width: 12),
              _buildFormatChip(label: 'Excel (.XLSX)', format: 'XLSX', icon: Icons.table_chart_rounded, color: accentColor, subContainer: subContainer, borderColor: borderColor, textPrimary: textPrimary, textSecondary: textSecondary),
            ],
          ),
          const SizedBox(height: 18),

          // Bank Template
          Text(
            'ISSUING BANK / TEMPLATE',
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: subContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBank,
                isExpanded: true,
                dropdownColor: cardBg,
                style: TextStyle(color: textPrimary, fontSize: 14),
                icon: Icon(Icons.keyboard_arrow_down, color: accentColor),
                items: _banks
                    .map((bank) => DropdownMenuItem(value: bank, child: Text(bank)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBank = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Upload Area / Selected File
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedFileName = _selectedFormat == 'PDF'
                    ? 'BOC_Oct2026_Statement.pdf'
                    : 'BOC_Transactions_Q3.xlsx';
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                color: subContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedFileName != null
                      ? accentColor
                      : borderColor,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _selectedFileName != null
                        ? Icons.check_circle_rounded
                        : Icons.cloud_upload_outlined,
                    color: _selectedFileName != null
                        ? accentColor
                        : const Color(0xFF00E5FF),
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedFileName ?? 'Tap to select statement file',
                    style: TextStyle(
                      color: _selectedFileName != null ? textPrimary : textSecondary,
                      fontSize: 14,
                      fontWeight: _selectedFileName != null ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (_selectedFileName == null)
                    Text(
                      'Supports standard PDF bank statements & XLSX files',
                      style: TextStyle(color: textSecondary, fontSize: 11),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Import Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      final nav = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      setState(() => _isLoading = true);
                      await Future.delayed(const Duration(milliseconds: 1000));
                      if (!mounted) return;
                      setState(() => _isLoading = false);
                      nav.pop();

                      messenger.showSnackBar(
                        SnackBar(
                          backgroundColor: cardBg,
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: accentColor, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Import completed: 142 records parsed & ready in Analytics.',
                                  style: TextStyle(color: textPrimary, fontSize: 13),
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
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: const Color(0xFF0C0F14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF0C0F14),
                      ),
                    )
                  : const Text(
                      'Import & Process',
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

  Widget _buildFormatChip({
    required String label,
    required String format,
    required IconData icon,
    required Color color,
    required Color subContainer,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final isSelected = _selectedFormat == format;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFormat = format;
            _selectedFileName = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : subContainer,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : borderColor,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? color : textSecondary, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? textPrimary : textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
