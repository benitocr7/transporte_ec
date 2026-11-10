import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/conversation_entity.dart';
import '../../data/mock_conversations.dart';
import 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit() : super(const MessagesInitial());

  final _uuid = const Uuid();

  // Local mutable message store
  final Map<String, List<MessageEntity>> _messages = {
    for (var entry in mockMessages.entries) entry.key: List.from(entry.value),
  };
  List<ConversationEntity> _conversations = List.from(mockConversations);

  Future<void> loadConversations() async {
    emit(const MessagesLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(MessagesLoaded(_conversations));
  }

  Future<void> openChat({
    required String contactId,
    required String contactName,
  }) async {
    final messages = _messages[contactId] ?? [];
    emit(ChatLoaded(
      contactId: contactId,
      contactName: contactName,
      messages: List.from(messages),
    ));
  }

  Future<void> sendMessage({
    required String contactId,
    required String contactName,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final msg = MessageEntity(
      id: _uuid.v4(),
      text: text.trim(),
      time: _nowTime(),
      isMe: true,
    );

    _messages[contactId] = [...(_messages[contactId] ?? []), msg];

    // Update conversation last message
    final idx = _conversations.indexWhere((c) => c.contactId == contactId);
    if (idx != -1) {
      final updated = ConversationEntity(
        id: _conversations[idx].id,
        contactId: contactId,
        contactName: contactName,
        route: _conversations[idx].route,
        lastMessage: text.trim(),
        time: _nowTime(),
        unreadCount: 0,
        isOnline: _conversations[idx].isOnline,
      );
      _conversations = [
        ...List.from(_conversations)..removeAt(idx)..insert(0, updated)
      ];
    } else {
      _conversations = [
        ConversationEntity(
          id: _uuid.v4(),
          contactId: contactId,
          contactName: contactName,
          route: '',
          lastMessage: text.trim(),
          time: _nowTime(),
        ),
        ..._conversations,
      ];
    }

    emit(ChatLoaded(
      contactId: contactId,
      contactName: contactName,
      messages: List.from(_messages[contactId]!),
    ));
  }

  String _nowTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
