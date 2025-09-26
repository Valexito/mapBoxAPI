enum UserRole { user, provider, admin, unknown }

UserRole parseRole(String? value) {
  switch ((value ?? '').trim().toLowerCase()) {
    case 'user':
      return UserRole.user;
    case 'provider':
      return UserRole.provider;
    case 'admin':
      return UserRole.admin;
    default:
      return UserRole.unknown;
  }
}
