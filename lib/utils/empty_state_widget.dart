import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final double verticalPadding;

  const EmptyStateWidget({
    super.key,
    this.message = 'No conversations yet',
    this.verticalPadding = 60.0,
  });

  @override
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min, // important
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'animations/empty_state.json',
              width: MediaQuery.of(context).size.width * 0.75,
              height: 250, // <<< LIMIT the height to avoid overflow
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

}
