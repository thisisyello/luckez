import 'package:flutter/material.dart';
import 'package:luckez/theme/app_colors.dart';

enum AppButtonVariant {
  primary,
  secondary,
  danger,
}

class AppButton extends StatelessWidget {
  const AppButton._({
    super.key,
    required this.label,
    required this.onPressed,
    required this.variant,
    this.icon,
    this.isLoading = false,
    this.height = 52,
  });

  const AppButton.primary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double height = 52,
  }) : this._(
          key: key,
          label: label,
          onPressed: onPressed,
          variant: AppButtonVariant.primary,
          icon: icon,
          isLoading: isLoading,
          height: height,
        );

  const AppButton.secondary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double height = 52,
  }) : this._(
          key: key,
          label: label,
          onPressed: onPressed,
          variant: AppButtonVariant.secondary,
          icon: icon,
          isLoading: isLoading,
          height: height,
        );

  const AppButton.danger({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    double height = 52,
  }) : this._(
          key: key,
          label: label,
          onPressed: onPressed,
          variant: AppButtonVariant.danger,
          icon: icon,
          isLoading: isLoading,
          height: height,
        );

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double height;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    return SizedBox(
      height: height,
      child: switch (variant) {
        AppButtonVariant.primary => ElevatedButton(
            onPressed: effectiveOnPressed,
            child: _ButtonContent(
              label: label,
              icon: icon,
              isLoading: isLoading,
            ),
          ),
        AppButtonVariant.secondary => OutlinedButton(
            onPressed: effectiveOnPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: mainColor,
              side: const BorderSide(color: mainColor),
            ),
            child: _ButtonContent(
              label: label,
              icon: icon,
              isLoading: isLoading,
            ),
          ),
        AppButtonVariant.danger => OutlinedButton(
            onPressed: effectiveOnPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: redColor,
              side: const BorderSide(color: redColor),
            ),
            child: _ButtonContent(
              label: label,
              icon: icon,
              isLoading: isLoading,
            ),
          ),
      },
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.isLoading,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (icon == null) {
      return Text(label);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
