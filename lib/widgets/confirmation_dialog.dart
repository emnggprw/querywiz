import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color iconColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.iconColor,
  });

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        icon: icon,
        iconColor: iconColor,
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: iconColor),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("Confirm", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
