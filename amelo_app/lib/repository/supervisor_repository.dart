// lib/repository/supervisor_repository.dart

import 'models/supervisor_model.dart';
import 'services/api_service.dart';

class SupervisorRepository {
  final ApiService _apiService;

  SupervisorRepository(this._apiService);

  Future<List<SupervisorModel>> listarTodos() async {
    final List<dynamic> data = await _apiService.get('/supervisores/');
    return data.map((json) => SupervisorModel.fromJson(json)).toList();
  }

  Future<SupervisorModel> criar({
    required String username,
    required String email,
    required String telefone,
    List<int> condominios = const [],
  }) async {
    final data = await _apiService.post('/supervisores/', {
      'usuario': {
        'username': username,
        'email': email,
        'telefone': telefone,
        'role': 'SUPERVISOR',
      },
      'condominios': condominios,
    });
    return SupervisorModel.fromJson(data);
  }

  Future<void> deletar(int id) async {
    await _apiService.delete('/supervisores/$id/');
  }
}
