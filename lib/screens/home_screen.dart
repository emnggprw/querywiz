import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:querywiz/main.dart';
import 'package:querywiz/models/conversation.dart';
import 'package:querywiz/models/message.dart';
import 'package:querywiz/screens/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Conversation> _conversations = [
    Conversation(messages: [
      Message(text: "Hello!", isUser: true, timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
      Message(text: "Hi there! How can I assist you?", isUser: false, timestamp: DateTime.now().subtract(const Duration(minutes: 4))),
    ]),
    Conversation(messages: [
      Message(text: "What's the weather today?", isUser: true, timestamp: DateTime.now().subtract(const Duration(hours: 1))),
      Message(text: "It's sunny and 75°F.", isUser: false, timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 2))),
    ]),
  ];

  void _startNewConversation() {
    setState(() {
      _conversations.add(Conversation(messages: []));
    });

    // Navigate immediately to the newly created conversation
    _openConversation(_conversations.length - 1);
  }

  void _openConversation(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(conversation: _conversations[index]),
      ),
    ).then((_) => setState(() {}));
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Today • ${TimeOfDay.fromDateTime(date).format(context)}";
    } else if (difference.inDays == 1) {
      return "Yesterday • ${TimeOfDay.fromDateTime(date).format(context)}";
    } else {
      return "${date.toLocal().toString().split(' ')[0]}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('QueryWiz 💬', style: TextStyle(color: themeProvider.isDarkMode ? Colors.cyan.shade700 : Colors.cyanAccent)),
        centerTitle: true,
        backgroundColor: themeProvider.isDarkMode ? Colors.black54 : Colors.cyan,
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          final lastMessage = conversation.messages.isNotEmpty
              ? conversation.messages.last.text
              : "Start a new conversation";

          return GestureDetector(
            onTap: () => _openConversation(index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? Colors.black.withOpacity(0.6) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: themeProvider.isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: CircleAvatar(
                  backgroundColor: themeProvider.isDarkMode ? Colors.cyan.shade700 : Colors.cyanAccent,
                  child: const Icon(Icons.chat, color: Colors.black),
                ),
                title: Text(
                  lastMessage,
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  _formatDate(conversation.lastUpdated), // Helper function for better date formatting
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewConversation,
        backgroundColor: Colors.cyanAccent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
