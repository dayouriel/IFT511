import 'hive_service.dart';

class AuthService {
  static const String _driverIdKey = 'driver_id';
  static const String _driverNameKey = 'driver_name';
  static const String _routeKey = 'route';

  // Mock credentials for proof-of-concept
  static final Map<String, Map<String, String>> _mockDrivers = {
    'DRV001': {'name': 'Emeka Okafor', 'route': 'PH North'},
    'DRV002': {'name': 'Chioma Eze', 'route': 'PH South'},
    'DRV003': {'name': 'Tunde Adeyemi', 'route': 'Trans Amadi'},
    'DEMO': {'name': 'Demo Driver', 'route': 'Demo Route'},
  };

  static Future<AuthResult> login(String driverId, String pin) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock auth: accept any 4-digit PIN for valid driver IDs
    final upperId = driverId.trim().toUpperCase();
    if (!_mockDrivers.containsKey(upperId)) {
      return AuthResult.failure('Driver ID not found. Try DRV001, DRV002, or DEMO.');
    }

    if (pin.length < 4) {
      return AuthResult.failure('PIN must be at least 4 digits.');
    }

    final driver = _mockDrivers[upperId]!;
    final box = HiveService.settings;
    await box.put(_driverIdKey, upperId);
    await box.put(_driverNameKey, driver['name']);
    await box.put(_routeKey, driver['route']);

    return AuthResult.success(
      driverId: upperId,
      driverName: driver['name']!,
      route: driver['route']!,
    );
  }

  static Future<void> logout() async {
    final box = HiveService.settings;
    await box.delete(_driverIdKey);
    await box.delete(_driverNameKey);
    await box.delete(_routeKey);
  }

  static String? get currentDriverId {
    return HiveService.settings.get(_driverIdKey);
  }

  static String get currentDriverName {
    return HiveService.settings.get(_driverNameKey) ?? 'Driver';
  }

  static String get currentRoute {
    return HiveService.settings.get(_routeKey) ?? 'Route';
  }

  static bool get isLoggedIn => currentDriverId != null;
}

class AuthResult {
  final bool success;
  final String? error;
  final String? driverId;
  final String? driverName;
  final String? route;

  const AuthResult._({
    required this.success,
    this.error,
    this.driverId,
    this.driverName,
    this.route,
  });

  factory AuthResult.success({
    required String driverId,
    required String driverName,
    required String route,
  }) {
    return AuthResult._(
      success: true,
      driverId: driverId,
      driverName: driverName,
      route: route,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(success: false, error: error);
  }
}
