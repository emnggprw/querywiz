import 'package:querywiz/models/message.dart';

class Conversation {
  final List<Message> messages;
  DateTime lastUpdated;

  Conversation({required this.messages}) : lastUpdated = messages.isNotEmpty ? messages.last.timestamp : DateTime.now();

  void addMessage(Message message) {
    messages.add(message);
    lastUpdated = message.timestamp;
  }
}