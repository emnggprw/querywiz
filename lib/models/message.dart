import 'package:flutter/material.dart';

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  error,
  generating,
  responded
}

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;
  final String? formattedContent; // Added for rich text support

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.status,
    this.formattedContent, // Optional formatted content (JSON Delta)
  });
}