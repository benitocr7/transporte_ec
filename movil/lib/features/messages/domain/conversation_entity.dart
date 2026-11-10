import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  const ConversationEntity({
    required this.id,
    required this.contactId,
    required this.contactName,
    required this.route,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  final String id;
  final String contactId;
  final String contactName;
  final String route;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;

  @override
  List<Object?> get props =>
      [id, contactId, contactName, route, lastMessage, time, unreadCount];
}

class MessageEntity extends Equatable {
  const MessageEntity({
    required this.id,
    required this.text,
    required this.time,
    required this.isMe,
  });

  final String id;
  final String text;
  final String time;
  final bool isMe;

  @override
  List<Object?> get props => [id, text, time, isMe];
}
