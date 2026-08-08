class AnexoModel {
  final int id;
  final int demandaId;
  final String nome;
  final int? historicoId;
  final String dataCriacao;

  AnexoModel({
    required this.id,
    required this.demandaId,
    this.nome = 'Sem nome de anexo',
    this.historicoId,
    required this.dataCriacao,
  });

  factory AnexoModel.fromJson(Map<String, dynamic> json) {
    return AnexoModel(
      id: json['id'],
      demandaId: json['demandaId'],
      nome: json['nome'] ?? 'Anexo da demanda${json['demandaId']}',
      historicoId: json['historicoId'] ?? 0,
      dataCriacao: json['dataCriacao'] != null
          ? DateTime.parse(json['dataCriacao']).toString()
          : DateTime.now().toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'demandaId': demandaId,
    'nome': nome,
    'historicoId': historicoId,
    'dataCriacao': dataCriacao,
  };
}
