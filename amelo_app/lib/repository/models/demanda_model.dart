class DemandaModel {
  final int id;
  final String titulo;
  final String descricao;
  final String status;
  final String urgencia;
  final String dataAbertura;
  final String? previsaoConclusao;
  final String? observacoes;
  final int? condominioId;
  final String condominioNome;
  final int? profissionalId;
  final String profissionalNome;
  final int? criadoPorId;
  final String criadoPorNome;

  DemandaModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.status,
    required this.urgencia,
    required this.dataAbertura,
    this.previsaoConclusao,
    this.observacoes,
    this.condominioId,
    required this.condominioNome,
    this.profissionalId,
    this.profissionalNome = '',
    this.criadoPorId,
    this.criadoPorNome = '',
  });

  factory DemandaModel.fromJson(Map<String, dynamic> json) {
    final condominio = json['condominio'];
    final profissional = json['profissionalAcionado'];
    final criadoPor = json['criadoPor'];

    return DemandaModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      titulo: (json['titulo'] as String?) ?? 'Demanda',
      descricao: (json['descricao'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'PENDENTE',
      urgencia: (json['urgencia'] as String?) ?? 'NAO_URGENTE',
      dataAbertura: (json['dataAbertura'] as String?) ?? '',
      previsaoConclusao: json['previsaoConclusao'] as String?,
      observacoes: json['observacoes'] as String?,
      condominioId: condominio is Map<String, dynamic>
          ? (condominio['id'] as num?)?.toInt()
          : null,
      condominioNome: condominio is Map<String, dynamic>
          ? (condominio['nome'] as String?) ?? 'Condomínio'
          : 'Condomínio',
      profissionalId: profissional is Map<String, dynamic>
          ? (profissional['id'] as num?)?.toInt()
          : null,
      profissionalNome: profissional is Map<String, dynamic>
          ? (profissional['nome'] as String?) ?? ''
          : '',
      criadoPorId: criadoPor is Map<String, dynamic>
          ? (criadoPor['id'] as num?)?.toInt()
          : null,
      criadoPorNome: criadoPor is Map<String, dynamic>
          ? (criadoPor['nome'] as String?) ?? ''
          : '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descricao': descricao,
    'status': status,
    'urgencia': urgencia,
    'dataAbertura': dataAbertura,
    'previsaoConclusao': previsaoConclusao,
    'observacoes': observacoes,
    'condominioId': condominioId,
    'condominioNome': condominioNome,
    'profissionalAcionado': profissionalId,
    'profissionalNome': profissionalNome,
    'criadoPor': criadoPorId,
  };
}
