import 'package:flutter/material.dart';
import 'package:querywiz/screens/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> _conversations = [
    {'id': '1', 'title': 'Chat with QueryWiz - Yesterday'},
    {'id': '2', 'title': 'AI Assistant - 2 days ago'},
    {'id': '3', 'title': 'Science & Tech Talk - Last week'},
  ];

  void _startNewConversation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatScreen()),
    );
  }

  void _openConversation(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatScreen()), // Future: Pass chat ID when integrating database
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QueryWiz Conversations'),
        backgroundColor: Colors.black54,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return Card(
            child: ListTile(
              title: Text(conversation['title']!),
              onTap: () => _openConversation(conversation['id']!),
              trailing: const Icon(Icons.arrow_forward_ios),
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