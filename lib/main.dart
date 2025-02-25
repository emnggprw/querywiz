import 'package:flutter/material.dart';

void main() {
  runApp(const QueryWizApp());
}

class QueryWizApp extends StatefulWidget {
  const QueryWizApp({super.key});

  @override
  State<QueryWizApp> createState() => _QueryWizAppState();
}

class _QueryWizAppState extends State<QueryWizApp> {
  bool _isDarkTheme = true;

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkTheme
          ? ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        scaffoldBackgroundColor: Colors.black,
      )
          : ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: ChatScreen(toggleTheme: _toggleTheme, isDarkTheme: _isDarkTheme),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkTheme;

  const ChatScreen({super.key, required this.toggleTheme, required this.isDarkTheme});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _messages.add({'user': message});
        _isLoading = true; // Show loading indicator
      });
      _controller.clear();

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _messages.add({'bot': "Here's a sample answer for: '$message'"});
          _isLoading = false; // Hide loading indicator
        });
        _scrollToBottom(); // Auto-scroll after response
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QueryWiz 💬',
          style: TextStyle(color: Colors.cyanAccent),
        ),
        centerTitle: true,
        backgroundColor: Colors.black54,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.containsKey('user');
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.cyan.shade700 : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isUser ? msg['user']! : msg['bot']!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ask something magical...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade900,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: Colors.cyanAccent,
                  child: const Icon(Icons.send, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
