// lib/ui/screens/historico_atualizacoes_screen.dart

import 'package:flutter/material.dart';
import '../../theme.dart';

class HistoricoAtualizacoesScreen extends StatelessWidget {
  const HistoricoAtualizacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dados Fake por agora
    final historicoMock = [
      {
        'id': 1,
        'usuario': 'Carlos Silva (Supervisor)',
        'data': '22/07/2026 - 14:30',
        'descricao':
            'Status alterado para "Em andamento". Profissional acionado: Hidráulico João.',
        'hasAnexo': true,
        'anexoNome': 'foto_vazamento_reparado.jpg',
      },
      {
        'id': 2,
        'usuario': 'Ana Paula (Gestora)',
        'data': '21/07/2026 - 09:15',
        'descricao':
            'Observação adicionada: Material comprado na loja central. Entrega prevista para a tarde.',
        'hasAnexo': false,
        'anexoNome': null,
      },
      {
        'id': 3,
        'usuario': 'Carlos Silva (Supervisor)',
        'data': '20/07/2026 - 16:00',
        'descricao': 'Demanda criada e classificada como "Urgente".',
        'hasAnexo': true,
        'anexoNome': 'laudo_inicial.pdf',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Histórico de Atualizações',
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
        ],
      ),
      body: Column(
        children: [
          // Cabeçalho informativo da demanda
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: theme.colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Demanda #1042',
                  style: TextStyle(
                    fontSize: 12,
                    color: AmeloTheme.primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Vazamento na Garagem B2',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Edifício Maria Carolina',
                  style: TextStyle(
                    fontSize: 13,
                    color: AmeloTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Linha do Tempo (Timeline view)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: historicoMock.length,
              itemBuilder: (context, index) {
                final item = historicoMock[index];
                final isLast = index == historicoMock.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Coluna do Ícone + Linha Conectora
                      Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AmeloTheme.primaryNavy,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.history_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: theme.dividerColor.withOpacity(0.3),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Card da Atualização
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.dividerColor.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['usuario'].toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    item['data'].toString(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AmeloTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['descricao'].toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.85),
                                ),
                              ),
                              if (item['hasAnexo'] == true) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AmeloTheme.primaryGold.withOpacity(
                                      0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.attach_file_rounded,
                                        size: 14,
                                        color: AmeloTheme.primaryNavy,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['anexoNome'].toString(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AmeloTheme.primaryNavy,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
