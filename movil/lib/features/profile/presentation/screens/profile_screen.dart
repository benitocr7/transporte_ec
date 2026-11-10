import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/rl_button.dart';
import '../../../../core/widgets/rl_common_widgets.dart';
import '../../../auth/domain/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return _ProfileContent(user: state.user);
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user});
  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mi perfil')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(context).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 20),
            _buildRoleSection(context).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            const SizedBox(height: 20),
            _buildAccountSection(context).animate().fadeIn(duration: 400.ms, delay: 180.ms),
            const SizedBox(height: 20),
            _buildLogoutButton(context).animate().fadeIn(duration: 400.ms, delay: 260.ms),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.button],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          RlAvatar(
            name: user.name,
            radius: 32,
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                if (user.isVerified)
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        'Cuenta verificada',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSection(BuildContext context) {
    final roles = [
      _RoleCardData(
        role: UserRole.carrier,
        icon: Icons.local_shipping_outlined,
        title: 'Transportista',
        subtitle: 'Busco cargas para mis vehículos',
        color: AppColors.carrier,
      ),
      _RoleCardData(
        role: UserRole.operator,
        icon: Icons.business_center_outlined,
        title: 'Operador logístico',
        subtitle: 'Gestiono vehículos y cargas',
        color: AppColors.operator_,
      ),
      _RoleCardData(
        role: UserRole.shipper,
        icon: Icons.inventory_2_outlined,
        title: 'Cargador',
        subtitle: 'Publico cargas para transportar',
        color: AppColors.shipper,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RlSectionHeader(title: 'Rol activo'),
        const SizedBox(height: 4),
        Text(
          'Cambia tu rol para acceder a funciones diferentes',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 14),
        ...roles.asMap().entries.map((e) {
          final rd = e.value;
          final isActive = user.activeRole == rd.role;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RoleSelectionCard(
              data: rd,
              isActive: isActive,
              onTap: () {
                if (!isActive) {
                  HapticFeedback.mediumImpact();
                  context.read<AuthCubit>().updateRole(rd.role);
                }
              },
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: (e.key * 60).ms)
                .slideY(begin: 0.05, end: 0),
          );
        }),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RlSectionHeader(title: 'Cuenta'),
        const SizedBox(height: 10),
        _SettingsTile(
          icon: Icons.notifications_none_rounded,
          label: 'Notificaciones',
          onTap: () {},
        ),
        _SettingsTile(
          icon: Icons.security_rounded,
          label: 'Seguridad',
          onTap: () {},
        ),
        _SettingsTile(
          icon: Icons.help_outline_rounded,
          label: 'Ayuda y soporte',
          onTap: () {},
        ),
        _SettingsTile(
          icon: Icons.info_outline_rounded,
          label: 'Acerca de RutaLink',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return RlButton(
      label: 'Cerrar sesión',
      onPressed: () => _confirmLogout(context),
      variant: RlButtonVariant.danger,
      icon: Icons.logout_rounded,
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthCubit>().logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

class _RoleCardData {
  const _RoleCardData({
    required this.role,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final UserRole role;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}

class _RoleSelectionCard extends StatelessWidget {
  const _RoleSelectionCard({
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  final _RoleCardData data;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive ? data.color.withOpacity(0.07) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? data.color : AppColors.divider,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? data.color : data.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon,
                  color: isActive ? Colors.white : data.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title, style: AppTextStyles.labelLarge),
                  Text(data.subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: data.color,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Activo',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(
                  'Cambiar',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textSecondary, size: 22),
        title: Text(label, style: AppTextStyles.bodyLarge),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppColors.textHint, size: 20),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
