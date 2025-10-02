// lib/features/users/models/user_role.dart
enum UserRole { user, provider, admin, unknown }

UserRole parseRole(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'provider':
    case 'owner':
      return UserRole.provider;
    case 'user':
      return UserRole.user;
    default:
      return UserRole.unknown;
  }
}

// alias backward-compat
UserRole roleFromString(String? v) => parseRole(v);
