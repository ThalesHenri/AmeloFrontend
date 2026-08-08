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
      if (usuario.token == null || usuario.token!.trim().isEmpty) {
        throw Exception('Token de autenticação inválido.');
      }

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
