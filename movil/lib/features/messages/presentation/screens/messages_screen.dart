import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/rl_common_widgets.dart';
import '../../../../core/widgets/rl_shimmer.dart';
import '../cubit/messages_cubit.dart';
import '../cubit/messages_state.dart';
import '../../domain/conversation_entity.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MessagesCubit>().loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mensajes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<MessagesCubit, MessagesState>(
        builder: (context, state) {
          if (state is MessagesLoading) return _buildShimmer();
          if (state is MessagesLoaded) {
            if (state.conversations.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Sin conversaciones',
                subtitle: 'Contacta transportistas o empresas desde las cargas disponibles.',
              );
            }
            return _buildList(state.conversations);
          }
          return _buildShimmer();
        },
      ),
    );
  }

  Widget _buildList(List<ConversationEntity> convs) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: convs.length,
      separatorBuilder: (_, __) =>
          const Divider(indent: 76, endIndent: 0, height: 1),
      itemBuilder: (context, i) {
        return _ConversationTile(
          conversation: convs[i],
          onTap: () => context.push(
            '/messages/chat/${convs[i].contactId}',
            extra: {'name': convs[i].contactName},
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (i * 40).ms)
            .slideX(begin: 0.03, end: 0, curve: Curves.easeOut);
      },
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, __) => const RlConversationShimmer(),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  final ConversationEntity conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Stack(
                children: [
                  RlAvatar(name: conversation.contactName, radius: 24),
                  if (conversation.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.contactName,
                            style: AppTextStyles.labelLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(conversation.time, style: AppTextStyles.caption),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      conversation.route,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.accent),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation.unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${conversation.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
