import 'package:flutter/material.dart';
import 'package:luckez/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.all(16),
    this.isSelected = false,
    this.selectedBorderColor = mainColor,
    this.backgroundColor = surfaceColor,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final bool isSelected;
  final Color selectedBorderColor;
  final Color backgroundColor;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? selectedBorderColor : borderColor,
          width: isSelected ? 1.4 : 1,
        ),
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
