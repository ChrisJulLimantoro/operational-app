// Chat Service
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:operational_app/bloc/auth_bloc.dart';
import 'package:operational_app/model/conversation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

import 'package:operational_app/model/message.dart';

enum ConnectionStatus { connecting, connected, disconnected, error }

class ChatService {
  static String baseURL = '${dotenv.env['CHAT_URL']}/api';
  static String chatServiceURL = '${dotenv.env['CHAT_URL']}';

  late final Dio _dio;
  IO.Socket? socket;
  String? storeId;
  ConnectionStatus connectionStatus = ConnectionStatus.connecting;
  final BuildContext context;

  // Stream controllers for real-time updates
  final StreamController<List<Conversation>> _conversationsController =
      StreamController<List<Conversation>>.broadcast();
  final StreamController<Message> _newMessageController =
      StreamController<Message>.broadcast();
  final StreamController<ConnectionStatus> _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();

  // Getters for streams
  Stream<List<Conversation>> get conversationsStream =>
      _conversationsController.stream;
  Stream<Message> get newMessageStream => _newMessageController.stream;
  Stream<ConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  ChatService(this.context) {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseURL,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          debugPrint('❌ Dio Error: ${error.message}');
          debugPrint('❌ Response: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );
  }

  Future<void> initialize() async {
    _loadStoreData();
    if (storeId != null) {
      _initializeSocket();
    }
  }

  void _loadStoreData() {
    final authCubit = context.read<AuthCubit>();
    storeId = authCubit.state.storeId;
    debugPrint('Store ID loaded from AuthCubit: $storeId');
  }

  void updateStoreId() {
    final authCubit = context.read<AuthCubit>();
    final newStoreId = authCubit.state.storeId;

    if (storeId != newStoreId) {
      debugPrint('Store ID changed from $storeId to $newStoreId');

      // Disconnect current socket if exists
      if (socket != null) {
        socket!.disconnect();
        socket = null;
      }

      storeId = newStoreId;

      // Reinitialize socket with new store ID
      if (storeId != null && storeId!.isNotEmpty) {
        _initializeSocket();
      }
    }
  }

  void _initializeSocket() {
    if (storeId == null) return;

    _updateConnectionStatus(ConnectionStatus.connecting);

    socket = IO.io(
      '$chatServiceURL/chat',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': storeId!, 'userType': 'store'})
          .setReconnectionDelay(1000)
          .setReconnectionAttempts(3)
          .build(),
    );

    socket!.onConnect((_) {
      debugPrint('✅ Connected to chat server');
      debugPrint('Socket ID: ${socket!.id}');
      _updateConnectionStatus(ConnectionStatus.connected);
    });

    socket!.onConnectError((error) {
      debugPrint('❌ Socket connection error: $error');
      _updateConnectionStatus(ConnectionStatus.error);
    });

    socket!.onDisconnect((reason) {
      debugPrint('🔌 Disconnected from chat server. Reason: $reason');
      _updateConnectionStatus(ConnectionStatus.disconnected);
    });

    socket!.onReconnect((attemptNumber) {
      debugPrint('🔄 Reconnected after $attemptNumber attempts');
      _updateConnectionStatus(ConnectionStatus.connected);
    });

    // Listen for new messages
    socket!.on('new_message', (data) {
      final message = Message.fromJson(data);
      // Only process messages from customers (not from this store)
      debugPrint('Messages received $message');
      // if (message.senderType != 'store') {
      _newMessageController.add(message);
      // Refresh conversations list
      // loadConversations();
      // }
    });

    socket!.on('conversation_updated', (_) {
      debugPrint('🔄 Conversation updated');
      loadConversations();
    });

    socket!.on('joined_chat', (data) {
      debugPrint('✅ Joined chat room: $data');
    });

    socket!.connect();
  }

  void _updateConnectionStatus(ConnectionStatus status) {
    connectionStatus = status;
    _connectionStatusController.add(status);
  }

  void joinChat(String userId) {
    if (socket != null && storeId != null) {
      debugPrint('🚪 Joining chat room: userId=$userId, storeId=$storeId');
      socket!.emit('join_chat', {'userId': userId, 'storeId': storeId});
    }
  }

  void leaveChat(String userId) {
    if (socket != null && storeId != null) {
      debugPrint('👋 Leaving chat room: userId=$userId, storeId=$storeId');
      socket!.emit('leave_chat', {'userId': userId, 'storeId': storeId});
    }
  }

  Future<List<Conversation>> loadConversations() async {
    if (storeId == null) return [];

    try {
      debugPrint('📋 Loading conversations for store: $storeId');

      final response = await _dio.get('/chat/conversations/store/$storeId');

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint('Data $data');
        if (data['success']) {
          final conversations =
              (data['data'] as List)
                  .map((conv) => Conversation.fromJson(conv))
                  .toList();

          debugPrint('✅ Loaded ${conversations.length} conversations');
          _conversationsController.add(conversations);
          return conversations;
        }
      }

      throw Exception('Failed to load conversations');
    } catch (error) {
      debugPrint('❌ Failed to fetch conversations: $error');
      return [];
    }
  }

  Future<List<Message>> loadMessages(String userId) async {
    if (storeId == null) return [];

    try {
      debugPrint(
        '💬 Loading messages for conversation: userId=$userId, storeId=$storeId',
      );

      final response = await _dio.get(
        '/chat/conversations/$userId/$storeId/messages',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success']) {
          final messages =
              (data['data']['messages'] as List)
                  .map((msg) => Message.fromJson(msg))
                  .toList();

          debugPrint('✅ Loaded ${messages.length} messages');
          return messages;
        }
      }

      throw Exception('Failed to load messages');
    } catch (error) {
      debugPrint('❌ Failed to fetch messages: $error');
      rethrow;
    }
  }

  Future<Message> sendMessage(String userId, String content) async {
    if (storeId == null) throw Exception('Store ID not found');

    try {
      debugPrint('📤 Sending message: $content');

      final payload = {
        'user_id': userId,
        'store_id': storeId,
        'sender_id': storeId,
        'sender_type': 'store',
        'content': content,
      };

      final response = await _dio.post('/chat/messages', data: payload);
      debugPrint('Response data: $response');
      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success']) {
          final message = Message.fromJson(data['data']);
          debugPrint('✅ Message sent successfully');
          return message;
        }
      }

      throw Exception('Failed to send message');
    } catch (error) {
      debugPrint('❌ Failed to send message: $error');
      rethrow;
    }
  }

  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    _conversationsController.close();
    _newMessageController.close();
    _connectionStatusController.close();
  }
}
