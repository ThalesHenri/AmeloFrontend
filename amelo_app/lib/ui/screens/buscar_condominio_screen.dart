// lib/ui/screens/buscar_condominio_screen.dart

import 'package:flutter/material.dart';
import '../../app_routes.dart';
import '../../theme.dart';

class BuscarCondominioScreen extends StatelessWidget {
  const BuscarCondominioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buscar Condomínio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // 🔘 Botão de troca de tema
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
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
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

          // --- TÍTULO DA LISTA ---
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

          // --- LISTA DE CONDOMÍNIOS ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: const [
                _CondominioCardItem(
                  nome: 'Edifício Maria Carolina',
                  endereco: 'Rua das Acácias, 320',
                  abertas: 12,
                  urgentes: 4,
                  concluidas: 8,
                ),
                _CondominioCardItem(
                  nome: 'Residencial Jardim das Flores',
                  endereco: 'Av. das Flores, 1050',
                  abertas: 18,
                  urgentes: 6,
                  concluidas: 12,
                ),
                _CondominioCardItem(
                  nome: 'Condomínio Vila do Sol',
                  endereco: 'Rua do Sol, 200',
                  abertas: 9,
                  urgentes: 2,
                  concluidas: 7,
                ),
                _CondominioCardItem(
                  nome: 'Edifício Parque Central',
                  endereco: 'Av. Central, 450',
                  abertas: 15,
                  urgentes: 3,
                  concluidas: 12,
                ),
                _CondominioCardItem(
                  nome: 'Residencial das Palmeiras',
                  endereco: 'Rua das Palmeiras, 780',
                  abertas: 10,
                  urgentes: 1,
                  concluidas: 9,
                ),
              ],
            ),
          ),

          // --- LEGENDA NO RODAPÉ ---
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

// ─── WIDGETS AUXILIARES DA LISTA ─────────────────────────────────────────────

class _CondominioCardItem extends StatelessWidget {
  final String nome;
  final String endereco;
  final int abertas;
  final int urgentes;
  final int concluidas;

  const _CondominioCardItem({
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
