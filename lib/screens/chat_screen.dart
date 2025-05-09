import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:querywiz/data/theme_provider.dart';
import 'package:querywiz/models/conversation.dart';
import 'package:querywiz/models/message.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:querywiz/widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  bool _isLoading = false;
  bool _hasText = false; // Track if the input field has text
  int? _pendingMessageIndex; // Track which message is currently pending

  // Format timestamp to show time
  String _formatTimestamp(DateTime timestamp) {
    // Format as HH:MM (24-hour format)
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';

    // Alternative: For AM/PM format, uncomment below and comment out the above
    // final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    // final hourStr = hour == 0 ? '12' : hour.toString();
    // final minute = timestamp.minute.toString().padLeft(2, '0');
    // final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    // return '$hourStr:$minute $period';
  }

  final String apiUrl = "https://api.example.com/chat";
  final apiKey = dotenv.env['API_KEY'];

  @override
  void initState() {
    super.initState();
    // Add listener to text controller to update send button state
    _controller.addListener(_updateInputState);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateInputState);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Update the state tracking whether input has text
  void _updateInputState() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _startTypingAnimation() {
    setState(() {
      _isLoading = true;
    });
  }

  void _stopTypingAnimation() {
    setState(() {
      _isLoading = false;
    });
  }

  void _insertMessage(Message msg) {
    widget.conversation.messages.add(msg);
    _listKey.currentState?.insertItem(widget.conversation.messages.length - 1);
  }

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    final userMsg = Message(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent, // User message is considered sent
    );

    setState(() {
      _isLoading = true;
    });

    _controller.clear();
    _insertMessage(userMsg);

    // Set this message as pending (or tracking index for updates)
    setState(() {
      _pendingMessageIndex = widget.conversation.messages.length - 1;
    });

    _scrollToBottom();
    _startTypingAnimation();

    try {
      // Insert placeholder AI message with generating status
      final botTypingMsg = Message(
        text: '...',
        isUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.generating,
      );
      _insertMessage(botTypingMsg);
      final aiMsgIndex = widget.conversation.messages.length - 1;

      final response = await _fetchResponse(message);

      final botMsg = Message(
        text: response ?? 'No response received.',
        isUser: false,
        timestamp: DateTime.now(),
        status: response != null ? MessageStatus.responded : MessageStatus.error,
      );

      // Replace the placeholder with final response
      setState(() {
        widget.conversation.messages[aiMsgIndex] = botMsg;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e", backgroundColor: Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
        _pendingMessageIndex = null;
      });
      _stopTypingAnimation();
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
        title: Text(
          'QueryWiz 💬',
          style: TextStyle(
            color: isDarkMode ? Colors.cyan.shade700 : Colors.cyanAccent,
          ),
        ),
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
            child: AnimatedList(
              key: _listKey,
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              initialItemCount: widget.conversation.messages.length,
              itemBuilder: (context, index, animation) {
                final msg = widget.conversation.messages[index];

                // Format the timestamp
                final timeString = _formatTimestamp(msg.timestamp);

                // Check if this message is pending
                final isPending = _pendingMessageIndex != null &&
                    index == _pendingMessageIndex &&
                    msg.isUser;

                // Create the message bubble
                final bubble = BubbleNormal(
                  text: msg.text,
                  isSender: msg.isUser,
                  color: msg.isUser
                      ? (isDarkMode ? Colors.cyan.shade700 : Colors.cyanAccent)
                      : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                  tail: true,
                  textStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                );

                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: Column(
                      crossAxisAlignment: msg.isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            bubble,
                            if (isPending)
                              Positioned(
                                bottom: 8,
                                right: msg.isUser ? 10 : null,
                                left: msg.isUser ? null : 10,
                                child: SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDarkMode ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: msg.isUser ? 0 : 12,
                            right: msg.isUser ? 12 : 0,
                            top: 2,
                            bottom: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                timeString,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              if (isPending)
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Text(
                                    "sending...",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 4.0),
              child: TypingIndicator(
                isTyping: _isLoading,
                backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade400,
                dotColor: isDarkMode ? Colors.cyanAccent : Colors.cyan,
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
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
                      filled: true,
                      fillColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _hasText ? _sendMessage() : null,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _hasText ? _sendMessage : null,
                  backgroundColor: _hasText
                      ? Colors.cyanAccent
                      : isDarkMode ? Colors.grey.shade800 : Colors.grey.shade400,
                  child: Icon(
                    Icons.send,
                    color: _hasText
                        ? Colors.black
                        : isDarkMode ? Colors.grey.shade600 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}