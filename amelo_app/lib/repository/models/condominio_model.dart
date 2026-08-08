class CondominioModel {
  final int id;
  final String nome;
  final String endereco;
  final String cidade;
  final String estado;
  final String? cep;
  final String? telefone;
  final String? email;
  final String? observacoes;
  final String? imagem;

  CondominioModel({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.cidade,
    required this.estado,
    this.cep,
    this.telefone,
    this.email,
    this.observacoes,
    this.imagem,
  });

  factory CondominioModel.fromJson(Map<String, dynamic> json) {
    return CondominioModel(
      id: json['id'],
      nome: json['nome'],
      endereco: json['endereco'],
      cidade: json['cidade'],
      estado: json['estado'],
      cep: json['cep'],
      telefone: json['telefone'],
      email: json['email'],
      observacoes: json['observacoes'],
      imagem: json['imagem'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'endereco': endereco,
    'cidade': cidade,
    'estado': estado,
    'cep': cep,
    'telefone': telefone,
    'email': email,
    'observacoes': observacoes,
    'imagem': imagem,
  };
}
