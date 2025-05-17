import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// Enhanced reusable empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? subMessage;
  final double verticalPadding;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final String? lottieAsset;
  final IconData? alternateIcon;
  final Color? iconColor;
  final double iconSize;
  final ScrollPhysics? physics;

  const EmptyStateWidget({
    super.key,
    this.message = 'No conversations yet',
    this.subMessage,
    this.verticalPadding = 60.0,
    this.onActionPressed,
    this.actionLabel,
    this.lottieAsset = 'animations/empty_state.json',
    this.alternateIcon,
    this.iconColor,
    this.iconSize = 80.0,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    // Using SingleChildScrollView to handle scrolling more efficiently
    // for an empty state instead of a ListView with a single child
    return SingleChildScrollView(
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVisual(context, isDarkMode),
              const SizedBox(height: 24),
              _buildMessage(context, isDarkMode),
              if (subMessage != null) ...[
                const SizedBox(height: 8),
                _buildSubMessage(context, isDarkMode),
              ],
              if (onActionPressed != null && actionLabel != null) ...[
                const SizedBox(height: 24),
                _buildActionButton(context, primaryColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisual(BuildContext context, bool isDarkMode) {
    // If we have a Lottie animation, use it
    if (lottieAsset != null && alternateIcon == null) {
      return Lottie.asset(
        lottieAsset!,
        width: MediaQuery.of(context).size.width * 0.75,
        height: 250,
        fit: BoxFit.contain,
      );
    }

    // Otherwise use the icon
    return Container(
      width: iconSize * 1.5,
      height: iconSize * 1.5,
      decoration: BoxDecoration(
        color: (iconColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        alternateIcon ?? Icons.inbox_outlined,
        size: iconSize,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildMessage(BuildContext context, bool isDarkMode) {
    return Text(
      message,
      style: TextStyle(
        fontSize: 20,
        color: isDarkMode ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubMessage(BuildContext context, bool isDarkMode) {
    return Text(
      subMessage!,
      style: TextStyle(
        fontSize: 16,
        color: isDarkMode ? Colors.white70 : Colors.black54,
        fontWeight: FontWeight.normal,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton(BuildContext context, Color primaryColor) {
    return ElevatedButton(
      onPressed: onActionPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        actionLabel!,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}