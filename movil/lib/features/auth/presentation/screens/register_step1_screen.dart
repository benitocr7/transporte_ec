import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/rl_button.dart';
import '../../../../core/widgets/rl_text_field.dart';

class RegisterStep1Screen extends StatefulWidget {
  const RegisterStep1Screen({super.key});

  @override
  State<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends State<RegisterStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.push(
      '/register/step2',
      extra: {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passwordCtrl.text,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
                const SizedBox(height: 32),
                _buildForm(),
                const SizedBox(height: 32),
                RlButton(
                  label: 'Continuar',
                  onPressed: _next,
                  icon: Icons.arrow_forward_rounded,
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿Ya tienes cuenta?', style: AppTextStyles.bodyMedium),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Iniciar sesión'),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 350.ms),
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
        _StepDot(step: 1, isActive: true, isCompleted: false),
        _StepLine(isCompleted: false),
        _StepDot(step: 2, isActive: false, isCompleted: false),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tus datos', style: AppTextStyles.displayMedium)
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.1, end: 0),
        const SizedBox(height: 6),
        Text(
          'Ingresa tu información personal para continuar',
          style: AppTextStyles.bodyMedium,
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 150.ms)
            .slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          RlTextField(
            label: 'Nombre completo',
            hint: 'Ej. Juan Pérez',
            controller: _nameCtrl,
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa tu nombre completo';
              if (v.trim().split(' ').length < 2) return 'Ingresa nombre y apellido';
              return null;
            },
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          const SizedBox(height: 16),
          RlTextField(
            label: 'Correo electrónico',
            hint: 'ejemplo@correo.com',
            controller: _emailCtrl,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.email_outlined,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
              if (!RegExp(r'^[\w\-\.]+@[\w\-\.]+\.[a-z]{2,}$').hasMatch(v.trim())) {
                return 'Correo no válido';
              }
              return null;
            },
          ).animate().fadeIn(duration: 400.ms, delay: 230.ms),
          const SizedBox(height: 16),
          RlPasswordField(
            label: 'Contraseña',
            hint: 'Mínimo 6 caracteres',
            controller: _passwordCtrl,
            focusNode: _passwordFocus,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _next(),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa una contraseña';
              if (v.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
          ).animate().fadeIn(duration: 400.ms, delay: 260.ms),
        ],
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
