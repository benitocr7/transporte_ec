import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/rl_common_widgets.dart';
import '../../../../core/widgets/rl_shimmer.dart';
import '../../domain/load_entity.dart';
import '../cubit/loads_cubit.dart';
import '../cubit/loads_state.dart';

class LoadsScreen extends StatefulWidget {
  const LoadsScreen({super.key});

  @override
  State<LoadsScreen> createState() => _LoadsScreenState();
}

class _LoadsScreenState extends State<LoadsScreen> {
  final _searchCtrl = TextEditingController();
  bool _showFilters = false;
  String? _selectedOrigin;
  String? _selectedDestination;
  String? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    context.read<LoadsCubit>().loadLoads();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Cargas disponibles'),
          actions: [
            BlocBuilder<LoadsCubit, LoadsState>(
              builder: (context, state) {
                final hasFilters = state is LoadsLoaded && state.hasActiveFilters;
                return IconButton(
                  icon: Badge(
                    isLabelVisible: hasFilters,
                    smallSize: 8,
                    backgroundColor: AppColors.accent,
                    child: const Icon(Icons.tune_rounded),
                  ),
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: _showFilters ? _buildFilterPanel() : const SizedBox.shrink(),
            ),
            Expanded(
              child: BlocBuilder<LoadsCubit, LoadsState>(
                builder: (context, state) {
                  if (state is LoadsLoading) return _buildShimmer();
                  if (state is LoadsError) return _buildError(state.message);
                  if (state is LoadsLoaded) {
                    if (state.loads.isEmpty) return _buildEmpty(state.hasActiveFilters);
                    return _buildList(state.loads);
                  }
                  return _buildShimmer();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: _searchCtrl,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Buscar por ciudad, empresa o mercancía...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    context.read<LoadsCubit>().search('');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (v) {
          setState(() {});
          context.read<LoadsCubit>().search(v);
        },
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Text('Filtros', style: AppTextStyles.labelLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FilterDropdown(
                  label: 'Origen',
                  value: _selectedOrigin,
                  items: AppConstants.ecuadorCities,
                  onChanged: (v) => setState(() => _selectedOrigin = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FilterDropdown(
                  label: 'Destino',
                  value: _selectedDestination,
                  items: AppConstants.ecuadorCities,
                  onChanged: (v) => setState(() => _selectedDestination = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _FilterDropdown(
            label: 'Tipo de vehículo',
            value: _selectedVehicle,
            items: AppConstants.vehicleTypes,
            onChanged: (v) => setState(() => _selectedVehicle = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedOrigin = null;
                      _selectedDestination = null;
                      _selectedVehicle = null;
                      _searchCtrl.clear();
                    });
                    context.read<LoadsCubit>().clearFilters();
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<LoadsCubit>().applyFilters(
                          origin: _selectedOrigin,
                          destination: _selectedDestination,
                          vehicleType: _selectedVehicle,
                        );
                    setState(() => _showFilters = false);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.05, end: 0);
  }

  Widget _buildList(List<LoadEntity> loads) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: loads.length,
      itemBuilder: (context, index) {
        return LoadCard(
          load: loads[index],
          onDetail: () => context.push('/loads/${loads[index].id}'),
          onSave: () => context.read<LoadsCubit>().toggleSave(
                loads[index].id,
                loads[index].isSaved,
              ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 50).ms)
            .slideY(begin: 0.05, end: 0, curve: Curves.easeOut);
      },
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => const RlLoadCardShimmer(),
    );
  }

  Widget _buildError(String message) {
    return EmptyStateWidget(
      icon: Icons.wifi_off_rounded,
      title: 'Algo salió mal',
      subtitle: message,
      actionLabel: 'Reintentar',
      onAction: () => context.read<LoadsCubit>().loadLoads(),
    );
  }

  Widget _buildEmpty(bool hasFilters) {
    return EmptyStateWidget(
      icon: hasFilters ? Icons.search_off_rounded : Icons.local_shipping_outlined,
      title: hasFilters ? 'Sin resultados' : 'Sin cargas disponibles',
      subtitle: hasFilters
          ? 'No encontramos cargas con esos filtros. Intenta con otros criterios.'
          : 'Aún no hay cargas publicadas. Vuelve pronto.',
      actionLabel: hasFilters ? 'Limpiar filtros' : null,
      onAction: hasFilters
          ? () {
              setState(() {
                _selectedOrigin = null;
                _selectedDestination = null;
                _selectedVehicle = null;
                _searchCtrl.clear();
              });
              context.read<LoadsCubit>().clearFilters();
            }
          : null,
    );
  }
}

class LoadCard extends StatelessWidget {
  const LoadCard({
    super.key,
    required this.load,
    required this.onDetail,
    required this.onSave,
  });

  final LoadEntity load;
  final VoidCallback onDetail;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onDetail,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _buildRoute(),
                const SizedBox(height: 10),
                _buildDetails(),
                const SizedBox(height: 14),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.local_shipping_outlined,
              color: AppColors.accent, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(load.companyName,
                  style: AppTextStyles.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(load.date, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        RlBadge(
          label: load.status.displayName,
          color: load.status == LoadStatus.available
              ? AppColors.success
              : load.status == LoadStatus.inProgress
                  ? AppColors.warning
                  : AppColors.textHint,
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onSave,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              load.isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              key: ValueKey(load.isSaved),
              color: load.isSaved ? AppColors.button : AppColors.textHint,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoute() {
    return Row(
      children: [
        const Icon(Icons.circle, size: 8, color: AppColors.accent),
        const SizedBox(width: 6),
        Expanded(child: Text(load.origin, style: AppTextStyles.bodyLarge)),
        const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textHint),
        const SizedBox(width: 6),
        const Icon(Icons.location_on_rounded, size: 10, color: AppColors.primary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            load.destination,
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Row(
      children: [
        _DetailChip(
          icon: Icons.local_shipping_outlined,
          label: load.vehicleType,
        ),
        const SizedBox(width: 8),
        _DetailChip(
          icon: Icons.scale_outlined,
          label: '${load.weightTons} ton',
        ),
        const SizedBox(width: 8),
        _DetailChip(
          icon: Icons.inventory_2_outlined,
          label: load.cargoType,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Text(
          '\$${load.priceUsd.toStringAsFixed(0)}',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.button),
        ),
        const SizedBox(width: 4),
        Text('USD', style: AppTextStyles.bodySmall),
        const Spacer(),
        ElevatedButton(
          onPressed: onDetail,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(100, 36),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Ver detalle'),
        ),
      ],
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.textHint),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      isExpanded: true,
      style: AppTextStyles.bodyLarge,
      items: [
        const DropdownMenuItem<String>(value: null, child: Text('Todos')),
        ...items.map((city) => DropdownMenuItem(value: city, child: Text(city))),
      ],
      onChanged: onChanged,
    );
  }
}
