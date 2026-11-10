import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/auth_repository.dart';
import '../../domain/user_entity.dart';
import '../../../../core/constants/app_constants.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;
  final _uuid = const Uuid();

  // Mock registered users store (in-memory for demo)
  static final Map<String, Map<String, String>> _mockUsers = {
    AppConstants.demoEmail: {
      'id': 'demo-user-001',
      'name': AppConstants.demoName,
      'password': AppConstants.demoPassword,
      'role': AppConstants.roleCarrier,
    },
  };

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final user = _mockUsers[email.toLowerCase()];
    if (user == null || user['password'] != password) {
      throw Exception('Correo o contraseña incorrectos');
    }

    final entity = UserEntity(
      id: user['id']!,
      name: user['name']!,
      email: email,
      activeRole: UserRoleExtension.fromCode(user['role']!),
      isVerified: email == AppConstants.demoEmail,
    );

    await _persistUser(entity);
    return entity;
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final lowerEmail = email.toLowerCase();
    if (_mockUsers.containsKey(lowerEmail)) {
      throw Exception('Ya existe una cuenta con este correo');
    }

    final id = _uuid.v4();
    _mockUsers[lowerEmail] = {
      'id': id,
      'name': name,
      'password': password,
      'role': role.code,
    };

    final entity = UserEntity(
      id: id,
      name: name,
      email: lowerEmail,
      activeRole: role,
    );

    await _persistUser(entity);
    return entity;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final isLoggedIn = _prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;

    final id = _prefs.getString(AppConstants.keyUserId);
    final name = _prefs.getString(AppConstants.keyUserName);
    final email = _prefs.getString(AppConstants.keyUserEmail);
    final roleCode = _prefs.getString(AppConstants.keyUserRole);

    if (id == null || name == null || email == null) return null;

    return UserEntity(
      id: id,
      name: name,
      email: email,
      activeRole: UserRoleExtension.fromCode(roleCode ?? AppConstants.roleCarrier),
      isVerified: email == AppConstants.demoEmail,
    );
  }

  @override
  Future<void> updateActiveRole(UserRole role) async {
    await _prefs.setString(AppConstants.keyUserRole, role.code);
  }

  @override
  Future<void> logout() async {
    await _prefs.remove(AppConstants.keyIsLoggedIn);
    await _prefs.remove(AppConstants.keyUserId);
    await _prefs.remove(AppConstants.keyUserName);
    await _prefs.remove(AppConstants.keyUserEmail);
    await _prefs.remove(AppConstants.keyUserRole);
  }

  Future<void> _persistUser(UserEntity entity) async {
    await _prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await _prefs.setString(AppConstants.keyUserId, entity.id);
    await _prefs.setString(AppConstants.keyUserName, entity.name);
    await _prefs.setString(AppConstants.keyUserEmail, entity.email);
    await _prefs.setString(AppConstants.keyUserRole, entity.activeRole.code);
  }
}
