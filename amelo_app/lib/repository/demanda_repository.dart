// lib/repository/demanda_repository.dart

import 'models/demanda_model.dart';
import 'services/api_service.dart';

class DemandaRepository {
  final ApiService _apiService;

  DemandaRepository(this._apiService);

  Future<List<DemandaModel>> listarTodas({int? condominioId}) async {
    final endpoint = condominioId != null
        ? '/demandas?condominio_id=$condominioId'
        : '/demandas';
    final List<dynamic> data = await _apiService.get(endpoint);
    return data.map((json) => DemandaModel.fromJson(json)).toList();
  }

  Future<DemandaModel> buscarPorId(int id) async {
    final data = await _apiService.get('/demandas/$id');
    return DemandaModel.fromJson(data);
  }

  Future<DemandaModel> criar(Map<String, dynamic> demandaPayload) async {
    final data = await _apiService.post('/demandas', demandaPayload);
    return DemandaModel.fromJson(data);
  }
}
