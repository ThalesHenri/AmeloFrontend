import 'package:flutter/material.dart';
import '../../theme.dart';

class DemandasCondominioScreen extends StatelessWidget {
  const DemandasCondominioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
        {};

    final nome = args['nome'] as String? ?? 'Condomínio';
    final endereco = args['endereco'] as String? ?? 'Endereço não informado';
    final abertas = args['abertas'] as int? ?? 0;
    final urgentes = args['urgentes'] as int? ?? 0;
    final concluidas = args['concluidas'] as int? ?? 0;

    final demandas = [
      _DemandaResumo(
        titulo: 'Elevador com barulho no andar 12',
        descricao: 'Solicitação aberta para manutenção preventiva.',
        status: 'Aberta',
        cor: AmeloTheme.statusAbertas,
      ),
      _DemandaResumo(
        titulo: 'Vazamento na garagem do bloco B',
        descricao: 'Problema urgente reportado por diversos moradores.',
        status: 'Urgente',
        cor: AmeloTheme.statusUrgente,
      ),
      _DemandaResumo(
        titulo: 'Limpeza do jardim principal',
        descricao: 'Tarefa concluída e aguardando validação final.',
        status: 'Concluída',
        cor: AmeloTheme.statusConcluido,
      ),
      _DemandaResumo(
        titulo: 'Troca de lâmpadas da área comum',
        descricao: 'Solicitação em andamento para o setor de manutenção.',
        status: 'Aberta',
        cor: AmeloTheme.statusAbertas,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Demandas por condomínio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  endereco,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AmeloTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ResumoChip(
                      label: '$abertas abertas',
                      color: AmeloTheme.statusAbertas,
                    ),
                    const SizedBox(width: 8),
                    _ResumoChip(
                      label: '$urgentes urgentes',
                      color: AmeloTheme.statusUrgente,
                    ),
                    const SizedBox(width: 8),
                    _ResumoChip(
                      label: '$concluidas concluídas',
                      color: AmeloTheme.statusConcluido,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: demandas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final demanda = demandas[index];
                return Card(
                  elevation: 0,
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                demanda.titulo,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: demanda.cor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                demanda.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: demanda.cor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          demanda.descricao,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AmeloTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
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

class _ResumoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ResumoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _DemandaResumo {
  final String titulo;
  final String descricao;
  final String status;
  final Color cor;

  const _DemandaResumo({
    required this.titulo,
    required this.descricao,
    required this.status,
    required this.cor,
  });
}
