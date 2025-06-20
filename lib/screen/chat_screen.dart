// Main Chat Screen
import 'package:flutter/material.dart';
import 'package:operational_app/api/chat.dart';
import 'package:operational_app/model/conversation.dart';
import 'package:operational_app/model/message.dart';
import 'package:operational_app/theme/colors.dart';

class StoreChatScreen extends StatefulWidget {
  @override
  _StoreChatScreenState createState() => _StoreChatScreenState();
}

class _StoreChatScreenState extends State<StoreChatScreen> {
  ChatService? _chatService;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Conversation> conversations = [];
  List<Conversation> filteredConversations = [];
  Conversation? selectedConversation;
  List<Message> messages = [];

  bool isLoading = true;
  bool isLoadingMessages = false;
  bool isSending = false;
  ConnectionStatus connectionStatus = ConnectionStatus.connecting;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(context);
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    if (_chatService == null) return;

    await _chatService!.initialize();

    // Listen to streams
    _chatService!.conversationsStream.listen((convs) {
      setState(() {
        conversations = convs;
        _filterConversations();
        isLoading = false;
      });
    });

    _chatService!.newMessageStream.listen((message) {
      // Add message if it's for current conversation
      if (selectedConversation != null &&
          message.conversationId == selectedConversation!.id) {
        setState(() {
          messages.add(message);
        });
        _scrollToBottom();
      }
    });

    _chatService!.connectionStatusStream.listen((status) {
      setState(() {
        connectionStatus = status;
      });
    });

    // Load initial data
    await _chatService!.loadConversations();
  }

  void _filterConversations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredConversations =
          conversations.where((conv) {
            final name = conv.user?.name?.toLowerCase() ?? '';
            final email = conv.user?.email?.toLowerCase() ?? '';
            return name.contains(query) || email.contains(query);
          }).toList();
    });
  }

  Future<void> _openChat(Conversation conversation) async {
    setState(() {
      selectedConversation = conversation;
      messages = [];
      isLoadingMessages = true;
    });

    // Join chat room
    _chatService!.joinChat(conversation.userId);

    try {
      final loadedMessages = await _chatService!.loadMessages(
        conversation.userId,
      );
      setState(() {
        messages = loadedMessages;
        isLoadingMessages = false;
      });
      _scrollToBottom();
    } catch (error) {
      setState(() {
        isLoadingMessages = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load messages: $error')),
      );
    }
  }

  void _goBack() {
    if (selectedConversation != null) {
      _chatService!.leaveChat(selectedConversation!.userId);
    }
    setState(() {
      selectedConversation = null;
      messages = [];
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty ||
        isSending ||
        selectedConversation == null)
      return;

    final content = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      isSending = true;
    });

    try {
      final message = await _chatService!.sendMessage(
        selectedConversation!.userId,
        content,
      );

      setState(() {
        messages.add(message);
        isSending = false;
      });
      _scrollToBottom();
    } catch (error) {
      setState(() {
        isSending = false;
      });
      _messageController.text = content; // Restore message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message: $error')));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedConversation == null
              ? 'Customer Messages'
              : selectedConversation!.user?.name ?? 'Customer',
        ),
        leading:
            selectedConversation != null
                ? IconButton(icon: Icon(Icons.arrow_back), onPressed: _goBack)
                : null,
        actions: [
          if (selectedConversation == null)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => _chatService!.loadConversations(),
            ),
          // Connection status indicator
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getConnectionColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  connectionStatus.toString().split('.').last,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body:
          selectedConversation == null
              ? _buildConversationsList()
              : _buildChatView(),
    );
  }

  Color _getConnectionColor() {
    switch (connectionStatus) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.yellow;
      case ConnectionStatus.disconnected:
      case ConnectionStatus.error:
        return Colors.red;
    }
  }

  Widget _buildConversationsList() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search conversations...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (_) => _filterConversations(),
          ),
        ),

        // Conversations list
        Expanded(
          child:
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredConversations.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.bluePrimary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No conversations yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    itemCount: filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = filteredConversations[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            conversation.user?.name
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'C',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                        title: Text(
                          conversation.user?.name ?? 'Unknown Customer',
                        ),
                        subtitle: Text(conversation.user?.email ?? ''),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatRelativeTime(conversation.updatedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            if (conversation.messages?.isNotEmpty == true)
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.bluePrimary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${conversation.messages!.length}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () => _openChat(conversation),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        // Messages
        Expanded(
          child:
              isLoadingMessages
                  ? Center(child: CircularProgressIndicator())
                  : messages.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Start the conversation',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isStore = message.senderType == 'store';

                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment:
                              isStore
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isStore) ...[
                              CircleAvatar(
                                radius: 16,
                                child: Text(
                                  selectedConversation?.user?.name
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                      'C',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              SizedBox(width: 8),
                            ],

                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isStore
                                          ? AppColors.bluePrimary
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ).copyWith(
                                    bottomLeft: Radius.circular(
                                      isStore ? 20 : 4,
                                    ),
                                    bottomRight: Radius.circular(
                                      isStore ? 4 : 20,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.content,
                                      style: TextStyle(
                                        color:
                                            isStore
                                                ? Colors.white
                                                : Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _formatTime(message.createdAt),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color:
                                            isStore
                                                ? Colors.white70
                                                : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            if (isStore) ...[
                              SizedBox(width: 8),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.bluePrimary,
                                child: Icon(
                                  Icons.store,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
        ),

        // Message input
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      autocorrect: false,
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bluePrimary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon:
                        isSending
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: isSending ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    dateTime = dateTime.add(const Duration(hours: 7));
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  void dispose() {
    _chatService!.dispose();
    _searchController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
