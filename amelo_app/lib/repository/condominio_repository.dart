// lib/repository/condominio_repository.dart

import 'models/condominio_model.dart';
import 'services/api_service.dart';

class CondominioRepository {
  final ApiService _apiService;

  CondominioRepository(this._apiService);

  /// Lista todos os condomínios cadastrados
  Future<List<CondominioModel>> listarTodos() async {
    final List<dynamic> data = await _apiService.get('/condominios');
    return data.map((json) => CondominioModel.fromJson(json)).toList();
  }

  /// Busca os detalhes de um condomínio específico pelo ID
  Future<CondominioModel> buscarPorId(int id) async {
    final data = await _apiService.get('/condominios/$id');
    return CondominioModel.fromJson(data);
  }

  /// Cadastra um novo condomínio
  Future<CondominioModel> criar(CondominioModel condominio) async {
    final data = await _apiService.post('/condominios', condominio.toJson());
    return CondominioModel.fromJson(data);
  }

  /// Atualiza os dados de um condomínio existente
  Future<CondominioModel> atualizar(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final data = await _apiService.put('/condominios/$id', payload);
    return CondominioModel.fromJson(data);
  }

  /// Remove um condomínio do sistema
  Future<void> deletar(int id) async {
    await _apiService.delete('/condominios/$id');
  }
}
