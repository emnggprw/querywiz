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

  static void deleteConversationAt(List<Conversation> list, int index) {
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
    }
  }
}
