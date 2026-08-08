class DemandaModel {
  final int id;
  final String status;
  final String urgencia;
  final int condominioId;
  final String condominioNome;
  final String descricao;
  final String dataAbertura;
  final String? previsaoConclusao;
  final int profissionalId;
  final String profissionalNome;
  final String criadoPor;

  DemandaModel({
    required this.id,
    required this.status,
    required this.urgencia,
    required this.condominioId,
    required this.condominioNome,
    required this.descricao,
    required this.dataAbertura,
    this.previsaoConclusao,
    required this.profissionalId,
    required this.profissionalNome,
    required this.criadoPor,
  });

  factory DemandaModel.fromJson(Map<String, dynamic> json) {
    return DemandaModel(
      id: json['id'],
      status: json['status'],
      urgencia: json['urgencia'],
      condominioId: json['condominioId'],
      condominioNome: json['condominioNome'],
      descricao: json['descricao'],
      dataAbertura: json['dataAbertura'],
      previsaoConclusao: json['previsaoConclusao'],
      profissionalId: json['profissionalId'],
      profissionalNome: json['profissionalNome'],
      criadoPor: json['criadoPor'],
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'urgencia': urgencia,
    'condominioId': condominioId,
    'condominioNome': condominioNome,
    'descricao': descricao,
    'dataAbertura': dataAbertura,
    'previsaoConclusao': previsaoConclusao,
    'profissionalId': profissionalId,
    'profissionalNome': profissionalNome,
    'criadoPor': criadoPor,
  };
}
