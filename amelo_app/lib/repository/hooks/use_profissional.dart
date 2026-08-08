// lib/repository/hooks/use_profissional.dart

import 'package:flutter/material.dart';
import '../models/profissional_model.dart';
import '../profissional_repository.dart';

class UseProfissional extends ValueNotifier<List<ProfissionalModel>> {
  final ProfissionalRepository repository;
  bool isLoading = false;
  String? error;

  UseProfissional(this.repository) : super([]);

  Future<void> carregarProfissionais() async {
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
    required String nome,
    required String especialidade,
    String? telefone,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final novo = await repository.criar(
        nome: nome,
        especialidade: especialidade,
        telefone: telefone,
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
      value = value.where((p) => p.id != id).toList();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
