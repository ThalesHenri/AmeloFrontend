// lib/repository/usuario_repository.dart

import 'models/usuario_model.dart';
import 'services/api_service.dart';

class UsuarioRepository {
  final ApiService _apiService;

  UsuarioRepository(this._apiService);

  /// Faz login do usuário e registra os tokens JWT (Access e Refresh)
  Future<UsuarioModel> login(String username, String password) async {
    final response = await _apiService.post('/auth/token/', {
      'username': username,
      'password': password,
    });

    final accessToken = response['access'] as String?;
    final refreshToken =
        response['refresh'] as String?; // 🧙‍♂️ Captura o token de renovação!

    if (accessToken == null || accessToken.trim().isEmpty) {
      throw Exception('Token de autenticação inválido.');
    }

    // ⚡ Registra AMBOS os tokens no ApiService para habilitar a renovação automática!
    _apiService.setTokens(accessToken: accessToken, refreshToken: refreshToken);

    final perfil = await _apiService.get('/auth/me/');

    final usuario = UsuarioModel.fromJson(perfil).copyWith(token: accessToken);

    _apiService.setUserRole(usuario.perfil);
    _apiService.setSenhaRedefinida(perfil['senha_redefinida'] == true);

    return usuario;
  }

  void logout() {
    _apiService.clearToken();
  }

  /// Obtém o perfil do usuário logado
  Future<UsuarioModel> obterPerfil() async {
    final data = await _apiService.get('/auth/me/');
    return UsuarioModel.fromJson(data);
  }
}
