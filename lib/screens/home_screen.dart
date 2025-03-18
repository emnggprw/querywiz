import 'package:flutter/material.dart';
import 'package:querywiz/screens/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> _conversations = [
    {'id': '1', 'title': 'Chat with QueryWiz', 'subtitle': 'Yesterday'},
    {'id': '2', 'title': 'AI Assistant', 'subtitle': '2 days ago'},
    {'id': '3', 'title': 'Science & Tech Talk', 'subtitle': 'Last week'},
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
      MaterialPageRoute(builder: (context) => const ChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QueryWiz 💬', style: TextStyle(color: Colors.cyanAccent)),
        centerTitle: true,
        backgroundColor: Colors.black54,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(color: Colors.black),
        child: ListView.builder(
          itemCount: _conversations.length,
          itemBuilder: (context, index) {
            final conversation = _conversations[index];
            return Card(
              color: Colors.grey.shade900,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                title: Text(
                  conversation['title']!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                subtitle: Text(
                  conversation['subtitle']!,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.cyanAccent,
                  child: Icon(Icons.chat, color: Colors.black),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.cyanAccent),
                onTap: () => _openConversation(conversation['id']!),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewConversation,
        backgroundColor: Colors.cyanAccent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
