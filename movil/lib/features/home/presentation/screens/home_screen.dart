import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/rl_common_widgets.dart';
import '../../../auth/domain/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../loads/data/mock_loads.dart';
import '../../../loads/presentation/screens/loads_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return _HomeContent(user: state.user);
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.user});
  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildQuickActions(context)),
            SliverToBoxAdapter(child: _buildRecommendedSection(context)),
            SliverToBoxAdapter(child: _buildRecentActivity(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Buenos días'
        : hour < 18
            ? 'Buenas tardes'
            : 'Buenas noches';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.button],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    ).animate().fadeIn(duration: 400.ms),
                    Text(
                      user.name.split(' ').first,
                      style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
                    ).animate().fadeIn(duration: 400.ms, delay: 80.ms).slideY(begin: 0.1, end: 0),
                  ],
                ),
              ),
              RlAvatar(
                name: user.name,
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.2),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ],
          ),
          const SizedBox(height: 14),
          _RoleBadgeRow(role: user.activeRole)
              .animate()
              .fadeIn(duration: 400.ms, delay: 150.ms),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = _quickActionsForRole(user.activeRole, context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RlSectionHeader(title: 'Accesos rápidos'),
          const SizedBox(height: 14),
          Row(
            children: actions
                .asMap()
                .entries
                .map(
                  (e) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: e.key < actions.length - 1 ? 10 : 0),
                      child: _QuickActionCard(action: e.value)
                          .animate()
                          .fadeIn(duration: 350.ms, delay: (e.key * 70).ms)
                          .slideY(begin: 0.08, end: 0, curve: Curves.easeOut),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection(BuildContext context) {
    final recommended = mockLoads.take(3).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RlSectionHeader(
            title: 'Cargas recomendadas',
            actionLabel: 'Ver todas',
            onAction: () => context.go('/loads'),
          ),
          const SizedBox(height: 14),
          ...recommended.asMap().entries.map((e) {
            return LoadCard(
              load: e.value,
              onDetail: () => context.push('/loads/${e.value.id}'),
              onSave: () {},
            )
                .animate()
                .fadeIn(duration: 350.ms, delay: (e.key * 60).ms)
                .slideY(begin: 0.05, end: 0, curve: Curves.easeOut);
          }),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RlSectionHeader(title: 'Actividad reciente'),
          const SizedBox(height: 14),
          _ActivityItem(
            icon: Icons.bookmark_rounded,
            color: AppColors.button,
            title: 'Guardaste una carga',
            subtitle: 'Quito → Guayaquil · hace 2h',
          ).animate().fadeIn(duration: 350.ms, delay: 100.ms),
          _ActivityItem(
            icon: Icons.chat_bubble_outline_rounded,
            color: AppColors.accent,
            title: 'Nuevo mensaje',
            subtitle: 'Distribuidora El Norte · hace 3h',
          ).animate().fadeIn(duration: 350.ms, delay: 160.ms),
          _ActivityItem(
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
            title: 'Perfil completado',
            subtitle: 'Tu cuenta está verificada',
          ).animate().fadeIn(duration: 350.ms, delay: 220.ms),
        ],
      ),
    );
  }

  List<_QuickAction> _quickActionsForRole(UserRole role, BuildContext context) {
    switch (role) {
      case UserRole.carrier:
        return [
          _QuickAction(
            icon: Icons.search_rounded,
            label: 'Buscar cargas',
            color: AppColors.button,
            onTap: () => context.go('/loads'),
          ),
          _QuickAction(
            icon: Icons.bookmark_outline_rounded,
            label: 'Guardadas',
            color: AppColors.accent,
            onTap: () => context.go('/loads'),
          ),
          _QuickAction(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Mensajes',
            color: AppColors.operator_,
            onTap: () => context.go('/messages'),
          ),
        ];
      case UserRole.operator:
        return [
          _QuickAction(
            icon: Icons.local_shipping_outlined,
            label: 'Mis vehículos',
            color: AppColors.operator_,
            onTap: () => context.go('/publish'),
          ),
          _QuickAction(
            icon: Icons.search_rounded,
            label: 'Ver cargas',
            color: AppColors.button,
            onTap: () => context.go('/loads'),
          ),
          _QuickAction(
            icon: Icons.rate_review_outlined,
            label: 'Propuestas',
            color: AppColors.accent,
            onTap: () => context.go('/messages'),
          ),
        ];
      case UserRole.shipper:
        return [
          _QuickAction(
            icon: Icons.add_box_outlined,
            label: 'Publicar carga',
            color: AppColors.shipper,
            onTap: () => context.go('/publish'),
          ),
          _QuickAction(
            icon: Icons.list_alt_rounded,
            label: 'Mis cargas',
            color: AppColors.button,
            onTap: () => context.go('/loads'),
          ),
          _QuickAction(
            icon: Icons.contact_phone_outlined,
            label: 'Contactos',
            color: AppColors.accent,
            onTap: () => context.go('/messages'),
          ),
        ];
    }
  }
}

class _RoleBadgeRow extends StatelessWidget {
  const _RoleBadgeRow({required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_roleIcon(role), size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                role.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.carrier:
        return Icons.local_shipping_outlined;
      case UserRole.operator:
        return Icons.business_center_outlined;
      case UserRole.shipper:
        return Icons.inventory_2_outlined;
    }
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});
  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        action.onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(action.icon, color: action.color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              action.label,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
