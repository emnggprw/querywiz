class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.status,
  });
}

enum MessageStatus {
  pending,      // User message is waiting to be sent (UI feedback)
  sent,         // User message has been sent to backend
  failed,       // Sending failed (API/network issues)
  generating,   // AI is generating the response (loading indicator)
  responded,    // AI response has been received
  error,        // AI failed to respond (server error, invalid response, etc.)
}

