import 'package:flutter/material.dart';
import 'package:operational_app/model/message.dart';
import 'package:operational_app/model/user.dart';

class Conversation {
  final String id;
  final String userId;
  final String storeId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final List<Message>? messages;

  Conversation({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.messages,
  });

  Conversation copyWith({id, userId, storeId, createdAt, updatedAt}) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      storeId: storeId ?? this.storeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user,
      messages: messages,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    debugPrint('ID ${json['id']}]');
    debugPrint('messages ${json['messages']}]');
    debugPrint('user ${json['user']}');
    return Conversation(
      id: json['id'],
      userId: json['user_id'] ?? json['userId'],
      storeId: json['store_id'] ?? json['storeId'],
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      messages:
          json['messages'] != null
              ? (json['messages'] as List).map((m) {
                m['conversation_id'] = json['id'];
                m['senderId'] = json['user']['id'];
                return Message.fromJson(m);
              }).toList()
              : null,
    );
  }
}
