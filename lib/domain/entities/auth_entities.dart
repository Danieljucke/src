class UserEntity {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isVerified;

  UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isVerified,
  });
}

class AuthResult {
  final bool success;
  final UserEntity? user;
  final String? error;

  AuthResult({
    required this.success,
    this.user,
    this.error,
  });
}
