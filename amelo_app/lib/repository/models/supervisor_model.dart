// lib/repository/models/supervisor_model.dart

class SupervisorModel {
  final int id;
  final String nome;
  final String? telefone;
  final DateTime dataCriacao;

  SupervisorModel({
    required this.id,
    required this.nome,
    this.telefone,
    required this.dataCriacao,
  });

  factory SupervisorModel.fromJson(Map<String, dynamic> json) {
    return SupervisorModel(
      id: json['id'],
      nome: json['username'] ?? 'Supervisor Sem Nome',
      telefone: json['telefone'],
      dataCriacao: json['data_criacao'] != null
          ? DateTime.parse(json['data_criacao'])
          : (json['dataCriacao'] != null
                ? DateTime.parse(json['dataCriacao'])
                : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'telefone': telefone,
    'data_criacao': dataCriacao.toIso8601String(),
  };
}
