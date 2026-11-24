// lib/repository/condominio_repository.dart

import 'models/condominio_model.dart';
import 'services/api_service.dart';

class CondominioRepository {
  final ApiService _apiService;

  CondominioRepository(this._apiService);

  /// Lista todos os condomínios cadastrados
  Future<List<CondominioModel>> listarTodos() async {
    final response = await _apiService.get('/condominios/');
    final List<dynamic> data = response is Map && response['results'] is List
        ? response['results'] as List<dynamic>
        : response as List<dynamic>;
    return data.map((json) => CondominioModel.fromJson(json)).toList();
  }

  /// Busca os detalhes de um condomínio específico pelo ID
  Future<CondominioModel> buscarPorId(int id) async {
    final data = await _apiService.get('/condominios/$id/');
    return CondominioModel.fromJson(data);
  }

  /// Cadastra um novo condomínio
  Future<CondominioModel> criar(CondominioModel condominio) async {
    final data = await _apiService.post('/condominios/', condominio.toJson());
    return CondominioModel.fromJson(data);
  }

  /// Cadastra quando a tela não precisa do corpo devolvido pela API.
  Future<void> criarSemLerResposta(CondominioModel condominio) async {
    await _apiService.post(
      '/condominios/',
      condominio.toJson(),
      decodeResponseBody: false,
    );
  }

  /// Cadastra um condomínio enviando sua imagem como arquivo multipart.
  Future<void> criarComImagem(
    CondominioModel condominio,
    String imagemPath,
  ) async {
    await _apiService.postFile(
      '/condominios/',
      filePath: imagemPath,
      fileField: 'imagem',
      fields: {
        'nome': condominio.nome,
        'endereco': condominio.endereco,
        'cidade': condominio.cidade,
        'estado': condominio.estado,
        'cep': condominio.cep ?? '',
        'telefone': condominio.telefone ?? '',
        'email': condominio.email ?? '',
        'observacoes': condominio.observacoes ?? '',
      },
    );
  }

  /// Atualiza os dados de um condomínio existente
  Future<CondominioModel> atualizar(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final data = await _apiService.put('/condominios/$id/', payload);
    return CondominioModel.fromJson(data);
  }

  /// Atualiza sem interpretar o corpo da resposta.
  Future<void> atualizarSemLerResposta(
    int id,
    Map<String, dynamic> payload,
  ) async {
    await _apiService.put(
      '/condominios/$id/',
      payload,
      decodeResponseBody: false,
    );
  }

  /// Atualiza os dados de um condomínio e substitui sua imagem.
  Future<CondominioModel> atualizarComImagem(
    int id,
    Map<String, String> fields,
    String imagemPath,
  ) async {
    final data = await _apiService.putFile(
      '/condominios/$id/',
      filePath: imagemPath,
      fileField: 'imagem',
      fields: fields,
    );
    return CondominioModel.fromJson(data);
  }

  /// Remove um condomínio do sistema
  Future<void> deletar(int id) async {
    await _apiService.delete('/condominios/$id/');
  }
}
