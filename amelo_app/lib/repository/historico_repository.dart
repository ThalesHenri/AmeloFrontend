// lib/repository/historico_repository.dart

import 'models/historico_model.dart';
import 'services/api_service.dart';

class HistoricoRepository {
  final ApiService _apiService;

  HistoricoRepository(this._apiService);

  Future<List<HistoricoModel>> listarPorDemanda(int demandaId) async {
    final List<dynamic> data = await _apiService.get(
      '/demandas/$demandaId/historicos',
    );
    return data.map((json) => HistoricoModel.fromJson(json)).toList();
  }

  Future<HistoricoModel> adicionarRegistro({
    required int demandaId,
    required String descricao,
  }) async {
    final data = await _apiService.post('/demandas/$demandaId/historicos', {
      'descricao': descricao,
    });
    return HistoricoModel.fromJson(data);
  }
}
