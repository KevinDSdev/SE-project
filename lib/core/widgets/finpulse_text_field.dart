import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class FinPulseTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final Widget? prefixWidget;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool isUppercaseLabel;

  const FinPulseTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.isPassword = false,
    this.prefixWidget,
    this.prefixIcon,
    this.suffixWidget,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.isUppercaseLabel = false,
  });

  @override
  State<FinPulseTextField> createState() => _FinPulseTextFieldState();
}

class _FinPulseTextFieldState extends State<FinPulseTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isUppercaseLabel
              ? widget.label.toUpperCase()
              : widget.label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: widget.isUppercaseLabel ? 11 : 13,
            fontWeight: FontWeight.w600,
            letterSpacing: widget.isUppercaseLabel ? 0.6 : 0.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkInput,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder, width: 1),
          ),
          child: Row(
            children: [
              if (widget.prefixWidget != null) ...[
                widget.prefixWidget!,
                const SizedBox(width: 8),
              ] else if (widget.prefixIcon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Icon(
                    widget.prefixIcon,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ] else ...[
                const SizedBox(width: 16),
              ],
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  obscureText: widget.isPassword ? _obscureText : false,
                  keyboardType: widget.keyboardType,
                  validator: widget.validator,
                  onChanged: widget.onChanged,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(
                      color: Color(0xFF5A606D),
                      fontSize: 14,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              if (widget.isPassword)
                IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscureText = !_obscureText);
                  },
                )
              else if (widget.suffixWidget != null)
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: widget.suffixWidget!,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
