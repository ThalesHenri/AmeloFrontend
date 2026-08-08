// lib/repository/models/usuario_model.dart

class UsuarioModel {
  final int id;
  final String nome;
  final String email;
  final String? perfil; // Ex: 'ADMIN', 'SUPERVISOR', 'GESTOR'
  final String? telefone;
  final String? token; // Preenchido no login após validação do JWT

  UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    this.perfil,
    this.telefone,
    this.token,
  });

  UsuarioModel copyWith({
    int? id,
    String? nome,
    String? email,
    String? perfil,
    String? telefone,
    String? token,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      perfil: perfil ?? this.perfil,
      telefone: telefone ?? this.telefone,
      token: token ?? this.token,
    );
  }

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final int parsedId = rawId is int
        ? rawId
        : rawId is String
        ? int.tryParse(rawId) ?? 0
        : 0;

    final rawNome = json['nome'] ?? json['name'] ?? json['username'];
    final rawFirstName = json['first_name'];
    final rawLastName = json['last_name'];

    String nome = '';
    if (rawNome is String && rawNome.trim().isNotEmpty) {
      nome = rawNome;
    } else {
      final firstName = rawFirstName is String ? rawFirstName : '';
      final lastName = rawLastName is String ? rawLastName : '';
      final fullName = [
        firstName,
        lastName,
      ].where((part) => part.trim().isNotEmpty).join(' ');
      nome = fullName.isNotEmpty
          ? fullName
          : (json['username'] as String? ?? '');
    }

    final perfil = json['perfil'] ?? json['role'] ?? json['role_name'];

    return UsuarioModel(
      id: parsedId,
      nome: nome,
      email: (json['email'] as String?) ?? '',
      perfil: perfil is String ? perfil : null,
      telefone: json['telefone'] as String? ?? json['phone'] as String?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'email': email,
    'perfil': perfil,
    'telefone': telefone,
    if (token != null) 'token': token,
  };
}
