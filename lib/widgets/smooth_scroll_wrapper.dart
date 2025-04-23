import 'package:flutter/material.dart';

class SmoothScrollWrapper extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final double thickness;
  final Radius radius;
  final bool alwaysVisible;

  const SmoothScrollWrapper({
    super.key,
    required this.child,
    this.controller,
    this.thickness = 6.0,
    this.radius = const Radius.circular(12),
    this.alwaysVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scrollbar(
      controller: controller,
      thumbVisibility: alwaysVisible,
      radius: radius,
      thickness: thickness,
      interactive: true,
      trackVisibility: alwaysVisible,
      child: Theme(
        data: ThemeData(
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.dragged)) {
                  return isDark ? Colors.cyan.shade300 : Colors.cyanAccent.shade700;
                }
                return isDark ? Colors.cyan.shade700 : Colors.cyanAccent;
              },
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
