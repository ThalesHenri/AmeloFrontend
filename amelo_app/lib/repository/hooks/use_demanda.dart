// lib/repository/hooks/use_demanda.dart

import 'package:flutter/material.dart';
import '../models/demanda_model.dart';
import '../demanda_repository.dart';

class UseDemanda extends ValueNotifier<List<DemandaModel>> {
  final DemandaRepository repository;
  bool isLoading = false;
  String? error;

  UseDemanda(this.repository) : super([]);

  Future<void> carregarDemandas({int? condominioId}) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      value = await repository.listarTodas(condominioId: condominioId);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> criarDemanda(Map<String, dynamic> payload) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final novaDemanda = await repository.criar(payload);
      value = [...value, novaDemanda];
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
