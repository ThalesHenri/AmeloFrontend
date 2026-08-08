// lib/repository/usuario_repository.dart

import 'models/usuario_model.dart';
import 'services/api_service.dart';

class UsuarioRepository {
  final ApiService _apiService;

  UsuarioRepository(this._apiService);

  /// Faz login do usuário e retorna o modelo de usuário com o token JWT
  Future<UsuarioModel> login(String username, String password) async {
    final response = await _apiService.post('/auth/token/', {
      'username': username,
      'password': password,
    });

    final token = response['access'] as String?;
    if (token == null || token.trim().isEmpty) {
      throw Exception('Token de autenticação inválido.');
    }

    _apiService.setToken(token);

    final perfil = await _apiService.get('/auth/me');
    final usuario = UsuarioModel.fromJson(perfil).copyWith(token: token);

    return usuario;
  }

  void logout() {
    _apiService.clearToken();
  }

  /// Obtem o perfil do usuário logado
  Future<UsuarioModel> obterPerfil() async {
    final data = await _apiService.get('/auth/me');
    return UsuarioModel.fromJson(data);
  }
}
