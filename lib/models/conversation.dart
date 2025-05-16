import 'package:querywiz/models/message.dart';

class Conversation {
  final List<Message> messages;
  DateTime lastUpdated;
  bool isFavorite;
  bool isPinned;

  Conversation({
    required this.messages,
    this.isFavorite = false,
    this.isPinned = false,
  }) : lastUpdated = DateTime.now();

  void addMessage(Message message) {
    messages.add(message);
    lastUpdated = message.timestamp;
  }

  /// Edits a message at the specified index with new content
  /// Returns true if successful, false if index is out of bounds
  bool editMessageAt(int index, String newText) {
    if (index >= 0 && index < messages.length) {
      final oldMessage = messages[index];
      messages[index] = Message(
        id: oldMessage.id,
        text: newText,
        isUser: oldMessage.isUser,
        timestamp: DateTime.now(), // Update timestamp when editing
      );
      lastUpdated = messages[index].timestamp;
      return true;
    }
    return false;
  }

  /// Edits a message with the specified ID with new content
  /// Returns true if successful, false if message not found
  bool editMessageById(String messageId, String newText) {
    final index = messages.indexWhere((message) => message.id == messageId);
    return index != -1 ? editMessageAt(index, newText) : false;
  }

  /// Deletes a message at the specified index
  /// Returns true if successful, false if index is out of bounds
  bool deleteMessageAt(int index) {
    if (index >= 0 && index < messages.length) {
      messages.removeAt(index);
      lastUpdated = DateTime.now();
      return true;
    }
    return false;
  }

  /// Deletes a message with the specified ID
  /// Returns true if successful, false if message not found
  bool deleteMessageById(String messageId) {
    final index = messages.indexWhere((message) => message.id == messageId);
    return index != -1 ? deleteMessageAt(index) : false;
  }

  static void deleteConversationAt(List<Conversation> list, int index) {
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
    }
  }
}