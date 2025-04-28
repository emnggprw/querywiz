import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:querywiz/data/theme_provider.dart';
import 'package:querywiz/models/conversation.dart';
import 'package:querywiz/models/message.dart';
import 'package:querywiz/screens/chat_screen.dart';
import 'package:querywiz/widgets/tap_feedback_wrapper.dart';
import 'package:querywiz/widgets/smooth_scroll_wrapper.dart';
import 'package:querywiz/widgets/confirmation_dialog.dart';
import 'package:querywiz/utils/empty_state_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final List<Conversation> _conversations = [
    Conversation(
      messages: [
        Message(text: "Hello!", isUser: true, timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
        Message(text: "Hi there! How can I assist you?", isUser: false, timestamp: DateTime.now().subtract(const Duration(minutes: 4))),
      ],
      isFavorite: false,
    ),
    Conversation(
      messages: [
        Message(text: "What's the weather today?", isUser: true, timestamp: DateTime.now().subtract(const Duration(hours: 1))),
        Message(text: "It's sunny and 75°F.", isUser: false, timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 2))),
      ],
      isFavorite: false,
    ),
  ];

  bool _isSearching = false;
  String _searchQuery = "";
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
    _animationController.forward();
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = "";
      _searchController.clear();
    });
    _animationController.reverse();
  }

  void _startNewConversation() {
    setState(() {
      _conversations.add(Conversation(messages: []));
    });
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

  void _toggleFavorite(int index) {
    setState(() {
      _conversations[index].isFavorite = !_conversations[index].isFavorite;
    });
  }

  void _sortByTimestamp() {
    setState(() {
      _conversations.sort((a, b) {
        DateTime aTimestamp = a.messages.isNotEmpty ? a.messages.last.timestamp : DateTime.now();
        DateTime bTimestamp = b.messages.isNotEmpty ? b.messages.last.timestamp : DateTime.now();
        return bTimestamp.compareTo(aTimestamp);
      });
    });
  }

  void _sortByFavorite() {
    setState(() {
      _conversations.sort((a, b) {
        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;
        return 0;
      });
    });
  }

  void _deleteConversation(int index) {
    setState(() {
      Conversation.deleteConversationAt(_conversations, index);
    });
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

  List<Conversation> _filteredConversations() {
    if (_searchQuery.isEmpty) {
      return _conversations;
    }
    return _conversations.where((conversation) {
      return conversation.messages.any((message) => message.text.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Colors.black54 : Colors.cyan,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment: _isSearching ? Alignment.centerLeft : Alignment.center,
                child: Text(
                  'QueryWiz 💬',
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.cyan.shade700 : Colors.cyanAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizeTransition(
              sizeFactor: _animation,
              axis: Axis.horizontal,
              axisAlignment: -1,
              child: SizedBox(
                width: 200,
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
              onPressed: () {
                if (_isSearching) {
                  _stopSearch();
                } else {
                  _startSearch();
                }
              },
            ),
            IconButton(
              icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
              onPressed: () => themeProvider.toggleTheme(),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                TapFeedbackWrapper(
                  onTap: _sortByTimestamp,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.access_time, color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                    label: Text("Recent", style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black)),
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.isDarkMode ? Colors.cyan.shade700 : Colors.cyanAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                TapFeedbackWrapper(
                  onTap: _sortByFavorite,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.star, color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                    label: Text("Favorites", style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black)),
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeProvider.isDarkMode ? Colors.cyan.shade700 : Colors.cyanAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredConversations().isEmpty
                ? EmptyStateWidget()
                : SmoothScrollWrapper(
              controller: _scrollController,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _filteredConversations().length,
                itemBuilder: (context, index) {
                  final conversation = _filteredConversations()[index];
                  final lastMessage = conversation.messages.isNotEmpty
                      ? conversation.messages.last.text
                      : "Start a new conversation";

                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.horizontal,
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        return await ConfirmationDialog.show(
                          context: context,
                          title: "Favorite Conversation",
                          content: "Are you sure you want to toggle favorite status?",
                          icon: Icons.star,
                          iconColor: Colors.amber,
                        ).then((confirmed) {
                          if (confirmed) _toggleFavorite(index);
                          return false;
                        });
                      } else if (direction == DismissDirection.endToStart) {
                        return await ConfirmationDialog.show(
                          context: context,
                          title: "Delete Conversation",
                          content: "Are you sure you want to delete this conversation?",
                          icon: Icons.delete,
                          iconColor: Colors.red,
                        ).then((confirmed) {
                          if (confirmed) _deleteConversation(index);
                          return false;
                        });
                      }
                      return false;
                    },
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      color: Colors.amber,
                      child: const Icon(Icons.star, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: GestureDetector(
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
                            _formatDate(conversation.lastUpdated),
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.grey.shade400 : Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  conversation.isFavorite ? Icons.star : Icons.star_border,
                                  color: conversation.isFavorite ? Colors.amber : Colors.grey,
                                ),
                                onPressed: () => _toggleFavorite(index),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewConversation,
        backgroundColor: Colors.cyanAccent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
