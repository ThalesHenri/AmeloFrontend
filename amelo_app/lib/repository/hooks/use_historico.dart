// lib/repository/hooks/use_historico.dart

import 'package:flutter/material.dart';
import '../models/historico_model.dart';
import '../historico_repository.dart';

class UseHistorico extends ValueNotifier<List<HistoricoModel>> {
  final HistoricoRepository repository;
  bool isLoading = false;
  String? error;

  UseHistorico(this.repository) : super([]);

  Future<void> carregarHistorico(int demandaId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      value = await repository.listarPorDemanda(demandaId);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registrarAlteracao({
    required int demandaId,
    required String descricao,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final novoRegistro = await repository.adicionarRegistro(
        demandaId: demandaId,
        descricao: descricao,
      );
      value = [novoRegistro, ...value]; // Adiciona no topo da lista
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
