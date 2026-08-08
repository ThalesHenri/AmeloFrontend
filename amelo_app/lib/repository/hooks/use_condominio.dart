// lib/repository/hooks/use_condominio.dart

import 'package:flutter/material.dart';
import '../models/condominio_model.dart';
import '../condominio_repository.dart';

class UseCondominio extends ValueNotifier<List<CondominioModel>> {
  final CondominioRepository repository;
  bool isLoading = false;
  String? error;

  UseCondominio(this.repository) : super([]);

  Future<void> carregarCondominios() async {
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

  Future<bool> cadastrar(CondominioModel condominio) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final novo = await repository.criar(condominio);
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
}
