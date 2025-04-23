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

    return _ScrollControllerWrapper(
      providedController: controller,
      builder: (context, scrollController) {
        return Scrollbar(
          controller: scrollController,
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
                      return isDark
                          ? Colors.cyan.shade300
                          : Colors.cyanAccent.shade700;
                    }
                    return isDark
                        ? Colors.cyan.shade700
                        : Colors.cyanAccent;
                  },
                ),
              ),
            ),
            child: PrimaryScrollController(
              controller: scrollController,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _ScrollControllerWrapper extends StatefulWidget {
  final ScrollController? providedController;
  final Widget Function(BuildContext, ScrollController) builder;

  const _ScrollControllerWrapper({
    super.key,
    required this.providedController,
    required this.builder,
  });

  @override
  State<_ScrollControllerWrapper> createState() => _ScrollControllerWrapperState();
}

class _ScrollControllerWrapperState extends State<_ScrollControllerWrapper> {
  late final ScrollController _internalController;
  bool _usingInternal = false;

  @override
  void initState() {
    super.initState();
    _usingInternal = widget.providedController == null;
    _internalController = ScrollController();
  }

  @override
  void dispose() {
    if (_usingInternal) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      widget.providedController ?? _internalController,
    );
  }
}
