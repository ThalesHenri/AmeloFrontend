// lib/repository/models/historico_model.dart

import 'anexo_model.dart';

class HistoricoModel {
  final int id;
  final int demandaId;
  final String usuarioNome;
  final String descricao;
  final DateTime dataCriacao;
  final List<AnexoModel> anexos;

  HistoricoModel({
    required this.id,
    required this.demandaId,
    required this.usuarioNome,
    required this.descricao,
    required this.dataCriacao,
    this.anexos = const [],
  });

  factory HistoricoModel.fromJson(Map<String, dynamic> json) {
    return HistoricoModel(
      id: json['id'],
      demandaId: json['demanda_id'] ?? json['demandaId'],
      usuarioNome:
          json['usuario_nome'] ??
          json['usuarioNome'] ??
          json['usuario'] ??
          'Usuário',
      descricao: json['descricao'] ?? '',
      dataCriacao: json['data_criacao'] != null
          ? DateTime.parse(json['data_criacao'])
          : (json['dataCriacao'] != null
                ? DateTime.parse(json['dataCriacao'])
                : DateTime.now()),
      anexos: json['anexos'] != null
          ? (json['anexos'] as List)
                .map((item) => AnexoModel.fromJson(item))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'demanda_id': demandaId,
    'usuario_nome': usuarioNome,
    'descricao': descricao,
    'data_criacao': dataCriacao.toIso8601String(),
    'anexos': anexos.map((a) => a.toJson()).toList(),
  };
}
