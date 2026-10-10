// lib/repository/models/user_role.dart

enum UserRole { admin, supervisor, sindico }

extension UserRoleExtension on UserRole {
  bool get podeExcluir => this == UserRole.admin;
  bool get podeEditarStatus =>
      this == UserRole.admin || this == UserRole.supervisor;
  bool get podeCriarDemanda =>
      this == UserRole.admin || this == UserRole.supervisor;
}
