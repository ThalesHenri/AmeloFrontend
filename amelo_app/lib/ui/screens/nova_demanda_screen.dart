// lib/ui/screens/nova_demanda_screen.dart

import 'package:flutter/material.dart';
import '../../theme.dart';

class NovaDemandaScreen extends StatefulWidget {
  const NovaDemandaScreen({super.key});

  @override
  State<NovaDemandaScreen> createState() => _NovaDemandaScreenState();
}

class _NovaDemandaScreenState extends State<NovaDemandaScreen> {
  bool _isUrgente = true; // Alternador de urgência

  String? _condominioSelecionado;
  String? _responsavelSelecionado;
  String? _profissionalSelecionado;
  String? _statusSelecionado;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nova Demanda',
          style: TextStyle(
            color: Colors.white, // Cor do Titulo da AppBar
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // 🔘 Botão de Troca de Tema (Sol / Lua)
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CONDOMÍNIO ---
            _buildLabel('Condomínio', theme),
            _buildDropdown(
              hint: 'Selecione o condomínio',
              value: _condominioSelecionado,
              items: [
                'Edifício Maria Carolina',
                'Residencial Jardim das Flores',
                'Condomínio Vila do Sol',
              ],
              onChanged: (val) => setState(() => _condominioSelecionado = val),
              theme: theme,
            ),
            const SizedBox(height: 16),

            // --- TÍTULO DA DEMANDA ---
            _buildLabel('Título da demanda', theme),
            _buildTextField(hint: 'Digite o título', theme: theme),
            const SizedBox(height: 16),

            // --- DESCRIÇÃO ---
            _buildLabel('Descrição da demanda', theme),
            _buildTextField(
              hint: 'Descreva a demanda detalhadamente',
              maxLines: 3,
              theme: theme,
            ),
            const SizedBox(height: 16),

            // --- URGÊNCIA (SELETOR DUPLO) ---
            _buildLabel('Urgência', theme),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isUrgente
                          ? AmeloTheme.statusUrgente
                          : theme.colorScheme.surface,
                      foregroundColor: _isUrgente
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      elevation: _isUrgente ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => setState(() => _isUrgente = true),
                    icon: Icon(
                      Icons.error_outline_rounded,
                      size: 18,
                      color: _isUrgente
                          ? Colors.white
                          : AmeloTheme.statusUrgente,
                    ),
                    label: const Text(
                      'Urgente',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: !_isUrgente
                          ? theme.colorScheme.surface
                          : Colors.transparent,
                      foregroundColor: !_isUrgente
                          ? theme.colorScheme.onSurface
                          : AmeloTheme.textSecondary,
                      side: BorderSide(
                        color: theme.dividerColor.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => setState(() => _isUrgente = false),
                    child: const Text('Não urgente'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- RESPONSÁVEL ---
            _buildLabel('Responsável', theme),
            _buildDropdown(
              hint: 'Selecione o responsável',
              value: _responsavelSelecionado,
              items: ['Carlos Silva (Supervisor)', 'Ana Paula (Supervisora)'],
              onChanged: (val) => setState(() => _responsavelSelecionado = val),
              theme: theme,
            ),
            const SizedBox(height: 16),

            // --- PROFISSIONAL ACIONADO ---
            _buildLabel('Profissional acionado', theme),
            _buildDropdown(
              hint: 'Selecione o profissional',
              value: _profissionalSelecionado,
              items: [
                'Hidráulico João',
                'Eletricista Marcos',
                'Pintor Roberto',
              ],
              onChanged: (val) =>
                  setState(() => _profissionalSelecionado = val),
              theme: theme,
            ),
            const SizedBox(height: 16),

            // --- STATUS DA DEMANDA ---
            _buildLabel('Status da demanda', theme),
            _buildDropdown(
              hint: 'Selecione o status',
              value: _statusSelecionado,
              items: ['Em andamento', 'Aguardando peças', 'Concluída'],
              onChanged: (val) => setState(() => _statusSelecionado = val),
              theme: theme,
            ),
            const SizedBox(height: 16),

            // --- OBSERVAÇÕES ---
            _buildLabel('Observações (opcional)', theme),
            _buildTextField(
              hint: 'Adicione observações',
              maxLines: 2,
              theme: theme,
            ),
            const SizedBox(height: 16),

            // --- CAIXA DE ANEXOS ---
            _buildLabel('Anexos', theme),
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AmeloTheme.textSecondary.withOpacity(0.4),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AmeloTheme.textSecondary,
                    size: 32,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Adicione fotos ou arquivos',
                    style: TextStyle(
                      fontSize: 12,
                      color: AmeloTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- BOTÃO SALVAR DEMANDA ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AmeloTheme.primaryNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'Salvar Demanda',
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

  // --- HELPERS DA TELA ---
  Widget _buildLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    int maxLines = 1,
    required ThemeData theme,
  }) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AmeloTheme.textSecondary,
          fontSize: 13,
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            hint,
            style: const TextStyle(
              color: AmeloTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          value: value,
          dropdownColor: theme.colorScheme.surface,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
