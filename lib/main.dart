import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const QueryWizApp());
}

class QueryWizApp extends StatelessWidget {
  const QueryWizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _isDarkMode = true;

  // API Configuration Variables
  final String apiUrl = "https://api.example.com/chat";
  final String apiKey = "your_api_key_here";

  // Function to send user message and fetch bot response
  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _messages.add({'user': message});
        _isLoading = true;
      });
      _controller.clear();

      try {
        final response = await _fetchResponse(message);
        if (response != null) {
          setState(() {
            _messages.add({'bot': response});
          });
        } else {
          setState(() {
            _messages.add({'bot': 'Failed to get a valid response.'});
          });
        }
      } catch (e) {
        setState(() {
          _messages.add({'bot': 'Error: $e'});
        });
      } finally {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  // API call to get response
  Future<String?> _fetchResponse(String userMessage) async {
    try {
      // Prepare request headers and body
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey'
      };
      final body = jsonEncode({"prompt": userMessage});

      debugPrint("[API Request] URL: $apiUrl, Message: $userMessage");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      debugPrint("[API Response] Status: ${response.statusCode}, Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'No valid response received.';
      } else {
        return 'Error: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      debugPrint("[API Error] $e");
      return null;
    }
  }

  // Scroll to bottom after message is sent
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // Toggle Light/Dark Theme
  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'QueryWiz 💬',
            style: TextStyle(color: Colors.cyanAccent),
          ),
          centerTitle: true,
          backgroundColor: Colors.black54,
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
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
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: CircularProgressIndicator(color: Colors.cyanAccent),
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
      ),
    );
  }
}
