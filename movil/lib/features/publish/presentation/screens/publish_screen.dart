import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/rl_button.dart';
import '../../../../core/widgets/rl_text_field.dart';
import '../../../auth/domain/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/publish_cubit.dart';
import '../cubit/publish_state.dart';

class PublishScreen extends StatelessWidget {
  const PublishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final role = state.user.activeRole;
        return BlocProvider(
          create: (_) => PublishCubit(),
          child: _PublishContent(role: role),
        );
      },
    );
  }
}

class _PublishContent extends StatefulWidget {
  const _PublishContent({required this.role});
  final UserRole role;

  @override
  State<_PublishContent> createState() => _PublishContentState();
}

class _PublishContentState extends State<_PublishContent> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<PublishCubit, PublishState>(
      listener: (context, state) {
        if (state is PublishSuccess) {
          HapticFeedback.mediumImpact();
          _showSuccessDialog(context, state.message);
        }
        if (state is PublishError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text('Publicar')),
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (widget.role) {
      case UserRole.carrier:
        return _CarrierPublishView();
      case UserRole.operator:
        return _OperatorPublishView();
      case UserRole.shipper:
        return _ShipperPublishView();
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 36),
            ),
            const SizedBox(height: 16),
            Text('Publicación exitosa', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(message,
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<PublishCubit>().reset();
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 44)),
              child: const Text('Listo'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==== CARRIER VIEW: read-only info ====
class _CarrierPublishView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.info, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Como transportista, busca cargas disponibles en la pestaña Cargas y contacta directamente a las empresas.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}

// ==== OPERATOR FORM ====
class _OperatorPublishView extends StatefulWidget {
  @override
  State<_OperatorPublishView> createState() => _OperatorPublishViewState();
}

class _OperatorPublishViewState extends State<_OperatorPublishView> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedVehicle;
  final _availabilityCtrl = TextEditingController();
  final _routeCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();

  @override
  void dispose() {
    _availabilityCtrl.dispose();
    _routeCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildVehicleDropdown(),
            const SizedBox(height: 16),
            RlTextField(
              label: 'Disponibilidad',
              hint: 'Ej. 15 Nov 2026 – 30 Nov 2026',
              controller: _availabilityCtrl,
              prefixIcon: Icons.calendar_today_outlined,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Indica la disponibilidad' : null,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),
            RlTextField(
              label: 'Ruta preferida',
              hint: 'Ej. Quito – Costa',
              controller: _routeCtrl,
              prefixIcon: Icons.route_rounded,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Indica la ruta' : null,
            ).animate().fadeIn(delay: 240.ms),
            const SizedBox(height: 16),
            RlTextField(
              label: 'Capacidad (toneladas)',
              hint: 'Ej. 10',
              controller: _capacityCtrl,
              prefixIcon: Icons.scale_outlined,
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Indica la capacidad' : null,
            ).animate().fadeIn(delay: 280.ms),
            const SizedBox(height: 32),
            BlocBuilder<PublishCubit, PublishState>(
              builder: (context, state) {
                return RlButton(
                  label: 'Publicar vehículo',
                  isLoading: state is PublishLoading,
                  onPressed: state is PublishLoading
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate() &&
                              _selectedVehicle != null) {
                            context.read<PublishCubit>().publishVehicle(
                                  vehicleType: _selectedVehicle!,
                                  availability: _availabilityCtrl.text,
                                  route: _routeCtrl.text,
                                  capacity: _capacityCtrl.text,
                                );
                          } else if (_selectedVehicle == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Selecciona el tipo de vehículo')),
                            );
                          }
                        },
                  icon: Icons.publish_rounded,
                ).animate().fadeIn(delay: 350.ms);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Publicar vehículo', style: AppTextStyles.headlineLarge)
            .animate()
            .fadeIn(duration: 400.ms),
        const SizedBox(height: 4),
        Text('Ofrece tu vehículo para rutas disponibles',
                style: AppTextStyles.bodyMedium)
            .animate()
            .fadeIn(duration: 400.ms, delay: 80.ms),
      ],
    );
  }

  Widget _buildVehicleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedVehicle,
      decoration: const InputDecoration(
        labelText: 'Tipo de vehículo',
        prefixIcon: Icon(Icons.local_shipping_outlined,
            color: AppColors.textHint, size: 20),
      ),
      items: AppConstants.vehicleTypes
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: (v) => setState(() => _selectedVehicle = v),
      validator: (v) => v == null ? 'Selecciona el vehículo' : null,
    ).animate().fadeIn(delay: 160.ms);
  }
}

// ==== SHIPPER FORM ====
class _ShipperPublishView extends StatefulWidget {
  @override
  State<_ShipperPublishView> createState() => _ShipperPublishViewState();
}

class _ShipperPublishViewState extends State<_ShipperPublishView> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedOrigin;
  String? _selectedDestination;
  String? _selectedCargo;
  final _dateCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  void dispose() {
    _dateCtrl.dispose();
    _weightCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildCityDropdowns(),
            const SizedBox(height: 16),
            RlTextField(
              label: 'Fecha de carga',
              hint: 'Ej. 20 Nov 2026',
              controller: _dateCtrl,
              prefixIcon: Icons.calendar_today_outlined,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Indica la fecha' : null,
            ).animate().fadeIn(delay: 220.ms),
            const SizedBox(height: 16),
            _buildCargoDropdown(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RlTextField(
                    label: 'Peso (ton)',
                    hint: 'Ej. 5',
                    controller: _weightCtrl,
                    prefixIcon: Icons.scale_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ).animate().fadeIn(delay: 300.ms),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RlTextField(
                    label: 'Precio (USD)',
                    hint: 'Ej. 350',
                    controller: _priceCtrl,
                    prefixIcon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null,
                  ).animate().fadeIn(delay: 330.ms),
                ),
              ],
            ),
            const SizedBox(height: 32),
            BlocBuilder<PublishCubit, PublishState>(
              builder: (context, state) {
                return RlButton(
                  label: 'Publicar carga',
                  isLoading: state is PublishLoading,
                  onPressed: state is PublishLoading
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          if (_selectedOrigin == null ||
                              _selectedDestination == null ||
                              _selectedCargo == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Completa todos los campos requeridos')),
                            );
                            return;
                          }
                          if (_formKey.currentState!.validate()) {
                            context.read<PublishCubit>().publishLoad(
                                  origin: _selectedOrigin!,
                                  destination: _selectedDestination!,
                                  date: _dateCtrl.text,
                                  cargoType: _selectedCargo!,
                                  weight: _weightCtrl.text,
                                  price: _priceCtrl.text,
                                );
                          }
                        },
                  icon: Icons.publish_rounded,
                ).animate().fadeIn(delay: 380.ms);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Publicar carga', style: AppTextStyles.headlineLarge)
            .animate()
            .fadeIn(duration: 400.ms),
        const SizedBox(height: 4),
        Text('Publica tu carga para que los transportistas la encuentren',
                style: AppTextStyles.bodyMedium)
            .animate()
            .fadeIn(duration: 400.ms, delay: 80.ms),
      ],
    );
  }

  Widget _buildCityDropdowns() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedOrigin,
            decoration: const InputDecoration(labelText: 'Origen'),
            isExpanded: true,
            items: AppConstants.ecuadorCities
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _selectedOrigin = v),
          ).animate().fadeIn(delay: 140.ms),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedDestination,
            decoration: const InputDecoration(labelText: 'Destino'),
            isExpanded: true,
            items: AppConstants.ecuadorCities
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _selectedDestination = v),
          ).animate().fadeIn(delay: 170.ms),
        ),
      ],
    );
  }

  Widget _buildCargoDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCargo,
      decoration: const InputDecoration(
        labelText: 'Tipo de mercancía',
        prefixIcon: Icon(Icons.inventory_2_outlined,
            color: AppColors.textHint, size: 20),
      ),
      items: AppConstants.cargoTypes
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (v) => setState(() => _selectedCargo = v),
    ).animate().fadeIn(delay: 260.ms);
  }
}
