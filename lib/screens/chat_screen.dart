import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:querywiz/main.dart';
import 'package:querywiz/models/conversation.dart';
import 'package:querywiz/models/message.dart';
import 'package:chat_bubbles/chat_bubbles.dart'; // Import the chat_bubbles package

class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final String apiUrl = "https://api.example.com/chat";
  final String apiKey = "api_from_env_here";

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      widget.conversation.messages.add(Message(text: message, isUser: true, timestamp: DateTime.now()));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await _fetchResponse(message);
      setState(() {
        widget.conversation.messages.add(Message(
          text: response ?? 'No response received.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e", backgroundColor: Colors.red);
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  Future<String?> _fetchResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({"prompt": userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'Unexpected response format.';
      } else {
        return 'Error: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Error fetching response.';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('QueryWiz 💬', style: TextStyle(color: isDarkMode ? Colors.cyan.shade700 : Colors.cyanAccent)),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black54 : Colors.cyan,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: widget.conversation.messages.length,
              itemBuilder: (context, index) {
                final msg = widget.conversation.messages[index];
                return BubbleNormal(
                  text: msg.text,
                  isSender: msg.isUser,
                  color: msg.isUser
                      ? (isDarkMode ? Colors.cyan.shade700 : Colors.cyanAccent)
                      : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                  tail: true, // chat bubble tail
                  textStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black ),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'QueryWiz is thinking...',
                style: TextStyle(
                  color: isDarkMode ? Colors.cyanAccent : Colors.black,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Ask something magical...',
                      hintStyle: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700),
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
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
}
