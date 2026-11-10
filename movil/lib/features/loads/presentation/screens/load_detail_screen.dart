import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/rl_button.dart';
import '../../../../core/widgets/rl_common_widgets.dart';
import '../../domain/load_entity.dart';
import '../cubit/loads_cubit.dart';
import '../cubit/loads_state.dart';

class LoadDetailScreen extends StatefulWidget {
  const LoadDetailScreen({super.key, required this.loadId});
  final String loadId;

  @override
  State<LoadDetailScreen> createState() => _LoadDetailScreenState();
}

class _LoadDetailScreenState extends State<LoadDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LoadsCubit>().loadDetail(widget.loadId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<LoadsCubit, LoadsState>(
        builder: (context, state) {
          if (state is LoadDetailLoading) return _buildLoading();
          if (state is LoadDetailLoaded) return _buildDetail(state.load);
          if (state is LoadsError) return _buildError(state.message);
          return _buildLoading();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError(String message) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: EmptyStateWidget(
        icon: Icons.error_outline_rounded,
        title: 'Error al cargar',
        subtitle: message,
        actionLabel: 'Volver',
        onAction: () => context.pop(),
      ),
    );
  }

  Widget _buildDetail(LoadEntity load) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(load),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRouteCard(load).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),
                const SizedBox(height: 12),
                _buildDetailsCard(load).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05, end: 0),
                const SizedBox(height: 12),
                _buildCompanyCard(load).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0),
                if (load.description != null) ...[
                  const SizedBox(height: 12),
                  _buildDescriptionCard(load.description!)
                      .animate()
                      .fadeIn(delay: 250.ms)
                      .slideY(begin: 0.05, end: 0),
                ],
                const SizedBox(height: 24),
                _buildActions(load).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(LoadEntity load) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              load.isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              key: ValueKey(load.isSaved),
              color: Colors.white,
            ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.read<LoadsCubit>().toggleSave(load.id, load.isSaved);
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.button],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${load.origin} → ${load.destination}',
                  style: AppTextStyles.headlineLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  load.date,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteCard(LoadEntity load) {
    return _DetailCard(
      title: 'Ruta',
      icon: Icons.route_rounded,
      child: Row(
        children: [
          Expanded(
            child: _RoutePoint(
              label: 'Origen',
              city: load.origin,
              icon: Icons.radio_button_checked_rounded,
              color: AppColors.accent,
            ),
          ),
          Column(
            children: [
              ...List.generate(3, (_) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Icon(Icons.circle, size: 4, color: AppColors.divider),
              )),
            ],
          ),
          Expanded(
            child: _RoutePoint(
              label: 'Destino',
              city: load.destination,
              icon: Icons.location_on_rounded,
              color: AppColors.primary,
              alignRight: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(LoadEntity load) {
    return _DetailCard(
      title: 'Detalles de la carga',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.local_shipping_outlined,
            label: 'Vehículo requerido',
            value: load.vehicleType,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.scale_outlined,
            label: 'Peso',
            value: '${load.weightTons} toneladas',
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.inventory_2_outlined,
            label: 'Tipo de mercancía',
            value: load.cargoType,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.attach_money_rounded,
            label: 'Precio ofertado',
            value: '\$${load.priceUsd.toStringAsFixed(0)} USD',
            valueStyle: AppTextStyles.headlineSmall.copyWith(color: AppColors.button),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(LoadEntity load) {
    return _DetailCard(
      title: 'Empresa cargadora',
      icon: Icons.business_outlined,
      child: Row(
        children: [
          RlAvatar(name: load.companyName, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(load.companyName, style: AppTextStyles.headlineSmall),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text('Empresa verificada', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return _DetailCard(
      title: 'Instrucciones adicionales',
      icon: Icons.notes_rounded,
      child: Text(description, style: AppTextStyles.bodyMedium),
    );
  }

  Widget _buildActions(LoadEntity load) {
    return Column(
      children: [
        RlButton(
          label: 'Contactar empresa',
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.push('/messages/chat/${load.companyId}',
                extra: {'name': load.companyName});
          },
          icon: Icons.chat_bubble_outline_rounded,
        ),
        const SizedBox(height: 10),
        RlButton(
          label: load.isSaved ? 'Guardado' : 'Guardar carga',
          onPressed: () => context.read<LoadsCubit>().toggleSave(load.id, load.isSaved),
          variant: load.isSaved ? RlButtonVariant.outlined : RlButtonVariant.ghost,
          icon: load.isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(title, style: AppTextStyles.labelLarge),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.label,
    required this.city,
    required this.icon,
    required this.color,
    this.alignRight = false,
  });

  final String label;
  final String city;
  final IconData icon;
  final Color color;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!alignRight) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
            ],
            Text(label, style: AppTextStyles.labelSmall),
            if (alignRight) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 14, color: color),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          city,
          style: AppTextStyles.headlineSmall,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textHint),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: AppTextStyles.bodyMedium),
        ),
        Text(
          value,
          style: valueStyle ?? AppTextStyles.labelLarge,
        ),
      ],
    );
  }
}
