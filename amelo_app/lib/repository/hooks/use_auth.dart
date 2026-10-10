// lib/repository/hooks/use_auth.dart

import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../usuario_repository.dart';

class UseAuth extends ValueNotifier<UsuarioModel?> {
  final UsuarioRepository repository;
  bool isLoading = false;
  String? error;

  UseAuth(this.repository) : super(null);

  Future<bool> login(String username, String senha) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final usuario = await repository.login(username, senha);

      // 1. Valida se veio o token principal
      if (usuario.token == null || usuario.token!.trim().isEmpty) {
        throw Exception('Token de autenticação inválido.');
      }

      // 2. Se o seu UsuarioModel já tem o refreshToken, passe ambos para o ApiService:
      // Exemplo: ApiService().setTokens(accessToken: usuario.token!, refreshToken: usuario.refreshToken);

      value = usuario;
      return true;
    } catch (e) {
      value = null;
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    repository.logout();
    value = null;
    error = null;
    isLoading = false;
    notifyListeners();
  }
}
