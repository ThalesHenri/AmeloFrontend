// lib/repository/profissional_repository.dart

import 'models/profissional_model.dart';
import 'services/api_service.dart';

class ProfissionalRepository {
  final ApiService _apiService;

  ProfissionalRepository(this._apiService);

  /// Lista todos os profissionais cadastrados
  Future<List<ProfissionalModel>> listarTodos() async {
    final response = await _apiService.get('/profissionais/');
    final List<dynamic> data = response is Map && response['results'] is List
        ? response['results'] as List<dynamic>
        : response as List<dynamic>;
    return data.map((json) => ProfissionalModel.fromJson(json)).toList();
  }

  /// Cria um novo profissional
  Future<ProfissionalModel> criar({
    required String nome,
    required String especialidade,
    String telefone = '',
  }) async {
    final data = await _apiService.post('/profissionais/', {
      'nome': nome,
      'especialidade': especialidade,
      'telefone': telefone,
    });
    return ProfissionalModel.fromJson(data);
  }

  // Deleta um profissional pelo ID
  Future<void> deletar(int id) async {
    await _apiService.delete('/profissionais/$id/');
  }

  // Edita um profissional pelo ID
  Future<ProfissionalModel> editar({
    required int id,
    required String nome,
    required String especialidade,
    String? telefone,
  }) async {
    final data = await _apiService.put('/profissionais/$id/', {
      'nome': nome,
      'especialidade': especialidade,
      'telefone': telefone,
    });
    return ProfissionalModel.fromJson(data);
  }
}
