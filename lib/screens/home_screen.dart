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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QueryWiz 💬', style: TextStyle(color: Colors.cyanAccent)),
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
        padding: const EdgeInsets.all(10),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          final lastMessage = conversation.messages.isNotEmpty ? conversation.messages.last.text : "New conversation";
          return Card(
            color: themeProvider.isDarkMode ? Colors.grey.shade900 : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: Text(
                lastMessage,
                style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                conversation.lastUpdated.toLocal().toString(),
                style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey.shade500 : Colors.black54, fontSize: 12),
              ),
              onTap: () => _openConversation(index),
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
