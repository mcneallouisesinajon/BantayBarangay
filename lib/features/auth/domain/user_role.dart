enum UserRole {
  resident,
  official,
  admin;

  static UserRole fromName(String? name) {
    return UserRole.values.firstWhere(
      (r) => r.name == name,
      orElse: () => UserRole.resident,
    );
  }

  bool get isOfficialOrAdmin => this == UserRole.official || this == UserRole.admin;
  bool get isAdmin => this == UserRole.admin;
}
