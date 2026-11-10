import 'package:equatable/equatable.dart';
import '../../domain/conversation_entity.dart';

abstract class MessagesState extends Equatable {
  const MessagesState();
  @override
  List<Object?> get props => [];
}

class MessagesInitial extends MessagesState {
  const MessagesInitial();
}

class MessagesLoading extends MessagesState {
  const MessagesLoading();
}

class MessagesLoaded extends MessagesState {
  const MessagesLoaded(this.conversations);
  final List<ConversationEntity> conversations;
  @override
  List<Object?> get props => [conversations];
}

class MessagesError extends MessagesState {
  const MessagesError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class ChatLoaded extends MessagesState {
  const ChatLoaded({
    required this.contactId,
    required this.contactName,
    required this.messages,
  });
  final String contactId;
  final String contactName;
  final List<MessageEntity> messages;
  @override
  List<Object?> get props => [contactId, contactName, messages];
}
