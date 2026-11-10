import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/rl_button.dart';
import '../../domain/user_entity.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterStep2Screen extends StatefulWidget {
  const RegisterStep2Screen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  UserRole? _selectedRole;

  final _roles = [
    _RoleOption(
      role: UserRole.carrier,
      icon: Icons.local_shipping_outlined,
      title: 'Soy transportista',
      subtitle: 'Busco cargas para mis vehículos',
      tag: 'Cargas',
      color: AppColors.carrier,
    ),
    _RoleOption(
      role: UserRole.operator,
      icon: Icons.business_center_outlined,
      title: 'Soy operador logístico',
      subtitle: 'Gestiono vehículos y cargas',
      tag: 'Vehículos y cargas',
      color: AppColors.operator_,
    ),
    _RoleOption(
      role: UserRole.shipper,
      icon: Icons.inventory_2_outlined,
      title: 'Soy cargador',
      subtitle: 'Publico cargas para transportar',
      tag: 'Vehículos',
      color: AppColors.shipper,
    ),
  ];

  void _register() {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona tu rol para continuar')),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    context.read<AuthCubit>().register(
          name: widget.name,
          email: widget.email,
          password: widget.password,
          role: _selectedRole!,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Crear cuenta'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildStepIndicator(),
                const SizedBox(height: 28),
                _buildHeader(),
                const SizedBox(height: 28),
                ..._roles.asMap().entries.map((e) {
                  final index = e.key;
                  final option = e.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RoleCard(
                      option: option,
                      isSelected: _selectedRole == option.role,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedRole = option.role);
                      },
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (200 + index * 80).ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                  );
                }),
                const SizedBox(height: 24),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return RlButton(
                      label: 'Crear cuenta',
                      onPressed: state is AuthLoading ? null : _register,
                      isLoading: state is AuthLoading,
                      icon: Icons.check_circle_outline_rounded,
                    ).animate().fadeIn(duration: 400.ms, delay: 450.ms);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _StepDot(step: 1, isActive: false, isCompleted: true),
        _StepLine(isCompleted: true),
        _StepDot(step: 2, isActive: true, isCompleted: false),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tu rol en RutaLink', style: AppTextStyles.displayMedium)
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.1, end: 0),
        const SizedBox(height: 6),
        Text(
          'Selecciona cómo usarás la plataforma. Podrás cambiarlo después.',
          style: AppTextStyles.bodyMedium,
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 150.ms)
            .slideY(begin: 0.1, end: 0),
      ],
    );
  }
}

class _RoleOption {
  const _RoleOption({
    required this.role,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.color,
  });

  final UserRole role;
  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final Color color;
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _RoleOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? option.color.withOpacity(0.06) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? option.color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: option.color.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? option.color : option.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                option.icon,
                color: isSelected ? Colors.white : option.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.title, style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 2),
                  Text(option.subtitle, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: option.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      option.tag,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: option.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? option.color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? option.color : AppColors.divider,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.step,
    required this.isActive,
    required this.isCompleted,
  });

  final int step;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final color = isActive || isCompleted ? AppColors.button : AppColors.divider;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? AppColors.button : isCompleted ? AppColors.accent : AppColors.inputFill,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : Text(
                '$step',
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textHint,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.isCompleted});
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isCompleted ? AppColors.accent : AppColors.divider,
      ),
    );
  }
}
