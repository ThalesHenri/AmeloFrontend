// lib/repository/models/profissional_model.dart

class ProfissionalModel {
  final int id;
  final String nome;
  final String especialidade;
  final String? telefone;

  ProfissionalModel({
    required this.id,
    required this.nome,
    required this.especialidade,
    this.telefone,
  });

  factory ProfissionalModel.fromJson(Map<String, dynamic> json) {
    return ProfissionalModel(
      id: json['id'],
      nome: json['nome'] ?? 'Profissional Sem Nome',
      especialidade: json['especialidade'] ?? 'Geral',
      telefone: json['telefone'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'especialidade': especialidade,
    'telefone': telefone,
  };
}
