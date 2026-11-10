class AppConstants {
  AppConstants._();

  static const String appName = 'RutaLink';
  static const String appVersion = '1.0.0';

  // Demo credentials
  static const String demoEmail = 'demo@rutalink.com';
  static const String demoPassword = 'rutalink123';
  static const String demoName = 'Demo Usuario';

  // SharedPreferences keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyUserRole = 'user_role';
  static const String keyUserId = 'user_id';

  // Roles
  static const String roleCarrier = 'carrier';
  static const String roleOperator = 'operator';
  static const String roleShipper = 'shipper';

  // Load statuses
  static const String statusAvailable = 'available';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Pagination
  static const int pageSize = 20;

  // Animation durations
  static const int animFast = 200;
  static const int animNormal = 300;
  static const int animSlow = 500;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 100.0;

  // Ecuador cities for mock data
  static const List<String> ecuadorCities = [
    'Quito',
    'Guayaquil',
    'Cuenca',
    'Ambato',
    'Manta',
    'Loja',
    'Ibarra',
    'Esmeraldas',
    'Santo Domingo',
    'Riobamba',
    'Machala',
    'Portoviejo',
  ];

  // Vehicle types
  static const List<String> vehicleTypes = [
    'Camión de 5 ton',
    'Camión de 10 ton',
    'Camión de 20 ton',
    'Furgoneta',
    'Tráiler',
    'Volquete',
    'Refrigerado',
    'Cisterna',
  ];

  // Cargo types
  static const List<String> cargoTypes = [
    'Alimentos',
    'Materiales de construcción',
    'Maquinaria',
    'Textiles',
    'Productos agrícolas',
    'Productos químicos',
    'Electrodomésticos',
    'Combustible',
    'Carga general',
  ];
}
