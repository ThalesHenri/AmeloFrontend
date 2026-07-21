import 'package:flutter/material.dart';
import '../../theme.dart';

class DetalhesDemandaScreen extends StatelessWidget {
  const DetalhesDemandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Demanda'),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, child) {
              final isDark = mode == ThemeMode.dark;
              return IconButton(
                icon: Icon(
                  isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  color: isDark
                      ? AmeloTheme.primaryGold
                      : AmeloTheme.lightSurface, // Adapta ao tema
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
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BADGE DE URGÊNCIA ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AmeloTheme.statusUrgente.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AmeloTheme.statusUrgente, width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: AmeloTheme.statusUrgente, size: 8),
                  SizedBox(width: 6),
                  Text(
                    'Urgente',
                    style: TextStyle(
                      color: AmeloTheme.statusUrgente,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- TÍTULO E EDIFÍCIO ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vazamento no shaft do 5º andar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Edifício Maria Carolina\nRua das Acácias, 320',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AmeloTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Thumbnail do Edifício
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: theme.colorScheme.surface,
                    child: Icon(
                      Icons.apartment_rounded,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // --- TABELA DE INFORMAÇÕES ---
            _buildInfoRow('Responsável', 'Carlos Silva', theme),
            _buildInfoRow('Profissional acionado', 'Hidráulico João', theme),
            _buildStatusRow(
              'Status da demanda',
              'Em andamento',
              AmeloTheme.statusAndamento,
              theme,
            ),
            _buildInfoRow('Data de abertura', '12/05/2024 09:30', theme),
            _buildInfoRow('Previsão de conclusão', '15/05/2024', theme),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // --- DESCRIÇÃO ---
            Text(
              'Descrição',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Vazamento constante no shaft do banheiro do apartamento 504, causando infiltração no 4º andar.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // --- OBSERVAÇÕES ---
            Text(
              'Observações',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Aguardando troca da peça que está em falta no fornecedor.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            // --- GALERIA DE ANEXOS ---
            Text(
              'Anexos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildAnexoThumbnail(Icons.build_rounded, theme),
                const SizedBox(width: 8),
                _buildAnexoThumbnail(Icons.plumbing_rounded, theme),
                const SizedBox(width: 8),
                _buildAnexoThumbnail(Icons.description_rounded, theme),
                const SizedBox(width: 8),
                // Foto com Badge +3
                _buildAnexoMoreBadge('+3', theme),
              ],
            ),

            const SizedBox(height: 32),

            // --- BOTÃO EDITAR DEMANDA ---
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AmeloTheme.primaryNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'Editar Demanda',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES DE INFORMAÇÃO ---
  static Widget _buildInfoRow(String label, String valor, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AmeloTheme.textSecondary,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatusRow(
    String label,
    String status,
    Color color,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AmeloTheme.textSecondary,
            ),
          ),
          Row(
            children: [
              Icon(Icons.circle, color: color, size: 8),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildAnexoThumbnail(IconData icone, ThemeData theme) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Icon(icone, color: AmeloTheme.textSecondary),
    );
  }

  static Widget _buildAnexoMoreBadge(String text, ThemeData theme) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
