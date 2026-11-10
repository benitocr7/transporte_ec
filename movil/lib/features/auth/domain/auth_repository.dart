import 'user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String email,
    required String password,
  });

  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  Future<UserEntity?> getCurrentUser();

  Future<void> updateActiveRole(UserRole role);

  Future<void> logout();
}
