// lib/repository/hooks/use_supervisor.dart

import 'package:flutter/material.dart';
import '../models/supervisor_model.dart';
import '../supervisor_repository.dart';

class UseSupervisor extends ValueNotifier<List<SupervisorModel>> {
  final SupervisorRepository repository;
  bool isLoading = false;
  String? error;

  UseSupervisor(this.repository) : super([]);

  Future<void> carregarSupervisores() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      value = await repository.listarTodos();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> adicionar({
    required String username,
    required String email,
    required String telefone,
    List<int> condominios = const [],
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final novo = await repository.criar(
        username: username,
        email: email,
        telefone: telefone,
        condominios: condominios,
      );
      value = [...value, novo];
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> remover(int id) async {
    try {
      await repository.deletar(id);
      value = value.where((s) => s.id != id).toList();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
