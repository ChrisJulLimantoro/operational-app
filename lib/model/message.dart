class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderType; // 'user' or 'store'
  final String content;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversation_id'] ?? json['conversationId'],
      senderId: json['sender_id'] ?? json['senderId'],
      senderType: json['sender_type'] ?? json['senderType'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
    );
  }
}
