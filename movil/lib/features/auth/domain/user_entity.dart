import 'package:equatable/equatable.dart';

enum UserRole { carrier, operator, shipper }

extension UserRoleExtension on UserRole {
  String get code {
    switch (this) {
      case UserRole.carrier:
        return 'carrier';
      case UserRole.operator:
        return 'operator';
      case UserRole.shipper:
        return 'shipper';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.carrier:
        return 'Transportista';
      case UserRole.operator:
        return 'Operador Logístico';
      case UserRole.shipper:
        return 'Cargador';
    }
  }

  static UserRole fromCode(String code) {
    switch (code) {
      case 'operator':
        return UserRole.operator;
      case 'shipper':
        return UserRole.shipper;
      default:
        return UserRole.carrier;
    }
  }
}

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.activeRole,
    this.isVerified = false,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final UserRole activeRole;
  final bool isVerified;
  final String? avatarUrl;

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? activeRole,
    bool? isVerified,
    String? avatarUrl,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      activeRole: activeRole ?? this.activeRole,
      isVerified: isVerified ?? this.isVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, email, activeRole, isVerified, avatarUrl];
}
