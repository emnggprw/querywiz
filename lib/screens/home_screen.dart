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
        Message(
          text: "Hello!",
          isUser: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          status: MessageStatus.sent,
        ),
        Message(
          text: "Hi there! How can I assist you?",
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
          status: MessageStatus.responded,
        ),
      ],
      isFavorite: false,
      isPinned: false,
    ),
    Conversation(
      messages: [
        Message(
          text: "What's the weather today?",
          isUser: true,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          status: MessageStatus.sent,
        ),
        Message(
          text: "It's sunny and 75°F.",
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 2)),
          status: MessageStatus.responded,
        ),
      ],
      isFavorite: false,
      isPinned: false,
    ),
  ];

  bool _isSearching = false;
  String _searchQuery = "";
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Bulk actions - new variables
  bool _isInSelectionMode = false;
  Set<int> _selectedIndices = {};

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
    if (_isInSelectionMode) {
      _toggleSelection(index);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(conversation: _conversations[index]),
        ),
      ).then((_) => setState(() {}));
    }
  }

  void _toggleFavorite(int index) {
    setState(() {
      _conversations[index].isFavorite = !_conversations[index].isFavorite;
    });
  }

  void _sortByTimestamp() {
    setState(() {
      _sortConversations();
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

  Future<void> _handleRefresh() async {
    // Simulate delay (mimicking network request)
    await Future.delayed(const Duration(seconds: 2));

    final now = DateTime.now();

    for (var conv in _conversations) {
      // Option 1: Just update the lastUpdated timestamp directly
      conv.lastUpdated = now;

      // Option 2: Optionally, simulate a new message if desired
      // conv.addMessage(Message(content: 'Refreshed!', timestamp: now));
    }

    if (!mounted) return;
    setState(() {});
  }

  TextSpan _highlightMatch(String text, String query, TextStyle normalStyle, TextStyle highlightStyle) {
    if (query.isEmpty) return TextSpan(text: text, style: normalStyle);

    final matches = RegExp(RegExp.escape(query), caseSensitive: false).allMatches(text);

    if (matches.isEmpty) {
      return TextSpan(text: text, style: normalStyle);
    }

    List<TextSpan> spans = [];
    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start), style: normalStyle));
      }

      spans.add(TextSpan(text: match.group(0), style: highlightStyle));
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex), style: normalStyle));
    }

    return TextSpan(children: spans);
  }

  // Bulk action methods
  void _toggleSelectionMode() {
    setState(() {
      _isInSelectionMode = !_isInSelectionMode;
      if (!_isInSelectionMode) {
        _selectedIndices.clear();
      }
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }

      // If all selections are cleared, exit selection mode
      if (_selectedIndices.isEmpty && _isInSelectionMode) {
        _isInSelectionMode = false;
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedIndices.length == _filteredConversations().length) {
        // If all are selected, deselect all
        _selectedIndices.clear();
      } else {
        // Select all
        _selectedIndices = Set<int>.from(List<int>.generate(_filteredConversations().length, (i) => i));
      }
    });
  }

  void _togglePin(int index) {
    setState(() {
      _conversations[index].isPinned = !_conversations[index].isPinned;
      _sortConversations(); // Re-sort to move pinned items to top
    });
  }

  void _sortByPinned() {
    _sortConversations();
  }

  void _sortConversations() {
    setState(() {
      _conversations.sort((a, b) {
        // First sort by pinned status
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;

        // Within the same pin status group, sort by timestamp
        DateTime aTimestamp = a.messages.isNotEmpty ? a.messages.last.timestamp : DateTime.now();
        DateTime bTimestamp = b.messages.isNotEmpty ? b.messages.last.timestamp : DateTime.now();
        return bTimestamp.compareTo(aTimestamp);
      });
    });
  }

  Future<void> _deleteSelected() async {
    final bool confirmed = await ConfirmationDialog.show(
      context: context,
      title: "Delete Conversations",
      content: "Are you sure you want to delete ${_selectedIndices.length} conversation(s)?",
      icon: Icons.delete,
      iconColor: Colors.red,
    );

    if (confirmed) {
      setState(() {
        // Sort indices in descending order to avoid index shifting issues
        final sortedIndices = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));

        for (final index in sortedIndices) {
          if (index < _conversations.length) {
            _conversations.removeAt(index);
          }
        }

        _selectedIndices.clear();
        _isInSelectionMode = false;
      });

      // Show a snackbar to confirm deletion
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted selected conversations'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _toggleFavoriteForSelected() async {
    final bool confirmed = await ConfirmationDialog.show(
      context: context,
      title: "Toggle Favorite Status",
      content: "Do you want to change favorite status for ${_selectedIndices.length} conversation(s)?",
      icon: Icons.star,
      iconColor: Colors.amber,
    );

    if (confirmed) {
      setState(() {
        // Determine if we should make all favorites or all non-favorites
        // If any selected conversation is not a favorite, make all favorites
        bool makeAllFavorites = _selectedIndices.any(
                (index) => index < _conversations.length && !_conversations[index].isFavorite
        );

        for (final index in _selectedIndices) {
          if (index < _conversations.length) {
            _conversations[index].isFavorite = makeAllFavorites;
          }
        }

        _selectedIndices.clear();
        _isInSelectionMode = false;
      });

      // Show a snackbar to confirm action
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated favorite status for selected conversations'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final filteredList = _filteredConversations();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Colors.black54 : Colors.cyan,
        automaticallyImplyLeading: false,
        title: !_isInSelectionMode
            ? Row(
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
                _isSearching ? _stopSearch() : _startSearch();
              },
            ),
            IconButton(
              icon: const Icon(Icons.select_all, color: Colors.white),
              onPressed: _toggleSelectionMode,
            ),
            IconButton(
              icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
              onPressed: () => themeProvider.toggleTheme(),
            ),
          ],
        )
            : Row(  // Selection mode title
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _toggleSelectionMode,
            ),
            Expanded(
              child: Text(
                '${_selectedIndices.length} selected',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.select_all, color: Colors.white),
              onPressed: _selectAll,
              tooltip: _selectedIndices.length == filteredList.length ? 'Deselect All' : 'Select All',
            ),
          ],
        ),
        actions: _isInSelectionMode ? [
          IconButton(
            icon: const Icon(Icons.star, color: Colors.amber),
            onPressed: _selectedIndices.isNotEmpty ? _toggleFavoriteForSelected : null,
            tooltip: 'Toggle Favorites',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _selectedIndices.isNotEmpty ? _deleteSelected : null,
            tooltip: 'Delete Selected',
          ),
        ] : null,
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
                const SizedBox(width: 10),
                TapFeedbackWrapper(
                  onTap: _sortByPinned,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.push_pin, color: themeProvider.isDarkMode ? Colors.white : Colors.black),
                    label: Text("Pinned", style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black)),
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
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: filteredList.isEmpty
                  ? ListView(children: [EmptyStateWidget()])
                  : SmoothScrollWrapper(
                controller: _scrollController,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final conversation = filteredList[index];
                    final lastMessage = conversation.messages.isNotEmpty
                        ? conversation.messages.last.text
                        : "Start a new conversation";
                    final isSelected = _selectedIndices.contains(index);

                    return _isInSelectionMode
                        ? _buildSelectableListItem(index, conversation, lastMessage, themeProvider, isSelected)
                        : _buildDismissibleListItem(index, conversation, lastMessage, themeProvider);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _isInSelectionMode
          ? null  // Hide the FAB in selection mode
          : FloatingActionButton(
        onPressed: _startNewConversation,
        backgroundColor: Colors.cyanAccent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildSelectableListItem(int index, Conversation conversation, String lastMessage, ThemeProvider themeProvider, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleSelection(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (themeProvider.isDarkMode ? Colors.cyan.shade900.withOpacity(0.3) : Colors.cyan.shade100)
              : (themeProvider.isDarkMode ? Colors.black.withOpacity(0.6) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: themeProvider.isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(2, 4),
            ),
          ],
          border: isSelected
              ? Border.all(color: themeProvider.isDarkMode ? Colors.cyan.shade700 : Colors.cyanAccent, width: 2)
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: CircleAvatar(
            backgroundColor: isSelected
                ? Colors.cyan
                : (themeProvider.isDarkMode ? Colors.cyan.shade700 : Colors.cyanAccent),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white)
                : const Icon(Icons.chat, color: Colors.black),
          ),
          title: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: _highlightMatch(
              lastMessage,
              _searchQuery,
              TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              const TextStyle(
                backgroundColor: Colors.yellow,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
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
              Icon(
                conversation.isFavorite ? Icons.star : Icons.star_border,
                color: conversation.isFavorite ? Colors.amber : Colors.grey,
              ),
              const SizedBox(width: 8),
              Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleSelection(index),
                activeColor: Colors.cyan,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissibleListItem(int index, Conversation conversation, String lastMessage, ThemeProvider themeProvider) {
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
        child: Row(
          children: const [
            Icon(Icons.star, color: Colors.white),
            SizedBox(width: 8),
            Text('Favorite', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () => _openConversation(index),
        onLongPress: () {
          _toggleSelectionMode();
          _toggleSelection(index);
        },
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
            title: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: _highlightMatch(
                lastMessage,
                _searchQuery,
                TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                const TextStyle(
                  backgroundColor: Colors.yellow,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                    conversation.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: conversation.isPinned ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () => _togglePin(index),
                ),
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
  }
}