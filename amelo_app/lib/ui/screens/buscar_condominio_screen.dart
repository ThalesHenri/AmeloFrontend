// lib/ui/screens/buscar_condominio_screen.dart

import 'package:flutter/material.dart';
import '../../app_routes.dart';
import '../../repository/condominio_repository.dart';
import '../../repository/models/condominio_model.dart';
import '../../repository/services/api_service.dart';
import '../../theme.dart';

class BuscarCondominioScreen extends StatefulWidget {
  const BuscarCondominioScreen({super.key});

  @override
  State<BuscarCondominioScreen> createState() => _BuscarCondominioScreenState();
}

class _BuscarCondominioScreenState extends State<BuscarCondominioScreen> {
  final _repository = CondominioRepository(ApiService());
  final _apiService = ApiService();
  final _searchController = TextEditingController();

  List<CondominioModel> _condominios = [];
  List<dynamic> _demandasGerais =
      []; // 🧙‍♂️ Armazena todas as demandas para contagem
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  // 🧙‍♂️ Busca Condomínios e Demandas simultaneamente
  Future<void> _carregarDados() async {
    try {
      final responses = await Future.wait([
        _repository.listarTodos(),
        _apiService.get('/demandas/'),
      ]);

      if (!mounted) return;

      setState(() {
        _condominios = responses[0] as List<CondominioModel>;
        // Se a API for paginada, pegue ['results'], senão pega a lista direta
        final demandasResponse = responses[1];
        _demandasGerais =
            (demandasResponse is Map && demandasResponse.containsKey('results'))
            ? demandasResponse['results'] as List<dynamic>
            : demandasResponse as List<dynamic>;

        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtro = _searchController.text.trim().toLowerCase();

    final listagem = _condominios.where((condominio) {
      return condominio.nome.toLowerCase().contains(filtro);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buscar Condomínio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, child) {
              final isDark = mode == ThemeMode.dark;
              return IconButton(
                icon: Icon(
                  isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  color: isDark ? AmeloTheme.primaryGold : Colors.white,
                ),
                tooltip: isDark
                    ? 'Mudar para Modo Claro'
                    : 'Mudar para Modo Escuro',
                onPressed: () {
                  themeNotifier.value = isDark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Digite o nome do condomínio',
                hintStyle: const TextStyle(
                  color: AmeloTheme.textSecondary,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AmeloTheme.textSecondary,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Histórico de demandas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_error!),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: listagem.map((condominio) {
                      // 🧙‍♂️ Lógica de Contagem de Demandas Específicas deste Condomínio
                      int abertas = 0;
                      int urgentes = 0;
                      int concluidas = 0;

                      for (var d in _demandasGerais) {
                        final cond = d['condominio'];
                        // Suporta tanto se a API devolver o objeto condomínio quanto apenas o ID numérico
                        final condId =
                            (cond is Map<String, dynamic> ? cond['id'] : cond)
                                as int?;

                        if (condId == condominio.id) {
                          final status = d['status'] as String? ?? '';
                          final prioridade = d['prioridade'] as String? ?? '';

                          if (status == 'PENDENTE') abertas++;
                          if (status == 'CONCLUIDA' || status == 'CONCLUIDO')
                            concluidas++;
                          if (prioridade == 'ALTA' || prioridade == 'URGENTE')
                            urgentes++;
                        }
                      }

                      return _CondominioCardItem(
                        id: condominio.id, // 🧙‍♂️ Agora passamos o ID!
                        nome: condominio.nome,
                        endereco: condominio.endereco,
                        abertas: abertas,
                        urgentes: urgentes,
                        concluidas: concluidas,
                      );
                    }).toList(),
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendaDot(color: AmeloTheme.statusAbertas, text: 'Abertas'),
                _LegendaDot(color: AmeloTheme.statusUrgente, text: 'Urgentes'),
                _LegendaDot(
                  color: AmeloTheme.statusConcluido,
                  text: 'Concluídas',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CondominioCardItem extends StatelessWidget {
  final int? id; // 🧙‍♂️ Adicionado o ID
  final String nome;
  final String endereco;
  final int abertas;
  final int urgentes;
  final int concluidas;

  const _CondominioCardItem({
    this.id,
    required this.nome,
    required this.endereco,
    required this.abertas,
    required this.urgentes,
    required this.concluidas,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.demandasCondominio,
          arguments: {
            'id': id, // 🧙‍♂️ ID injetado nos argumentos da rota!
            'nome': nome,
            'endereco': endereco,
            'abertas': abertas,
            'urgentes': urgentes,
            'concluidas': concluidas,
          },
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 50,
                  height: 50,
                  color: theme.scaffoldBackgroundColor,
                  child: const Icon(
                    Icons.apartment_rounded,
                    color: AmeloTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      endereco,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AmeloTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPill('$abertas', AmeloTheme.statusAbertas),
                        const SizedBox(width: 8),
                        _buildPill('$urgentes', AmeloTheme.statusUrgente),
                        const SizedBox(width: 8),
                        _buildPill('$concluidas', AmeloTheme.statusConcluido),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 6),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendaDot extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendaDot({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 8),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: AmeloTheme.textSecondary),
        ),
      ],
    );
  }
}
