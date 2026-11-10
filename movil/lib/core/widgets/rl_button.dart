import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum RlButtonVariant { primary, outlined, ghost, danger }

class RlButton extends StatelessWidget {
  const RlButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = RlButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.minWidth = double.infinity,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final RlButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double minWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: minWidth,
      height: height,
      child: _buildButton(),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildButton() {
    switch (variant) {
      case RlButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : _handlePress,
          child: _buildContent(Colors.white),
        );
      case RlButtonVariant.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : _handlePress,
          child: _buildContent(AppColors.button),
        );
      case RlButtonVariant.ghost:
        return TextButton(
          onPressed: isLoading ? null : _handlePress,
          child: _buildContent(AppColors.button),
        );
      case RlButtonVariant.danger:
        return ElevatedButton(
          onPressed: isLoading ? null : _handlePress,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          child: _buildContent(Colors.white),
        );
    }
  }

  Widget _buildContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.labelLarge.copyWith(color: color)),
        ],
      );
    }
    return Text(label, style: AppTextStyles.labelLarge.copyWith(color: color));
  }

  void _handlePress() {
    HapticFeedback.lightImpact();
    onPressed?.call();
  }
}
