// lib/repository/models/profissional_model.dart

class ProfissionalModel {
  final int id;
  final String nome;
  final String especialidade;
  final String? telefone;
  final String? usernameAcesso;
  final bool portalHabilitado;

  ProfissionalModel({
    required this.id,
    required this.nome,
    required this.especialidade,
    this.telefone,
    this.usernameAcesso,
    this.portalHabilitado = false,
  });

  factory ProfissionalModel.fromJson(Map<String, dynamic> json) {
    return ProfissionalModel(
      id: json['id'],
      nome: json['nome'] ?? 'Profissional Sem Nome',
      especialidade: json['especialidade'] ?? 'Geral',
      telefone: json['telefone'],
      usernameAcesso: json['usernameAcesso'] as String?,
      portalHabilitado: json['portalHabilitado'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'especialidade': especialidade,
    'telefone': telefone,
    'usernameAcesso': usernameAcesso,
    'portalHabilitado': portalHabilitado,
  };
}
