// lib/ui/screens/gerenciar_profissionais_screen.dart

import 'package:flutter/material.dart';
import '../../theme.dart';

class GerenciarProfissionaisScreen extends StatefulWidget {
  const GerenciarProfissionaisScreen({super.key});

  @override
  State<GerenciarProfissionaisScreen> createState() =>
      _GerenciarProfissionaisScreenState();
}

class _GerenciarProfissionaisScreenState
    extends State<GerenciarProfissionaisScreen> {
  // Lista simulada alinhada à classe Profissional
  final List<Map<String, String>> _profissionais = [
    {
      'id': '1',
      'nome': 'João Pedro',
      'especialidade': 'Hidráulica',
      'telefone': '(11) 91111-2222',
    },
    {
      'id': '2',
      'nome': 'Marcos Souza',
      'especialidade': 'Elétrica',
      'telefone': '(11) 93333-4444',
    },
    {
      'id': '3',
      'nome': 'Roberto Alves',
      'especialidade': 'Pintura & Alvenaria',
      'telefone': '(11) 95555-6666',
    },
    {
      'id': '4',
      'nome': 'Lucas Mendes',
      'especialidade': 'Serralheria',
      'telefone': '(11) 97777-8888',
    },
  ];

  void _abrirModalNovoProfissional(BuildContext context, ThemeData theme) {
    final nomeController = TextEditingController();
    final especialidadeController = TextEditingController();
    final telefoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cadastrar Novo Profissional',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: 'Nome do profissional',
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: especialidadeController,
              decoration: InputDecoration(
                labelText: 'Especialidade (ex: Hidráulico, Eletricista)',
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: telefoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Telefone de contato',
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                onPressed: () {
                  if (nomeController.text.isNotEmpty &&
                      especialidadeController.text.isNotEmpty) {
                    setState(() {
                      _profissionais.add({
                        'id': '${_profissionais.length + 1}',
                        'nome': nomeController.text,
                        'especialidade': especialidadeController.text,
                        'telefone': telefoneController.text,
                      });
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text(
                  'Salvar Profissional',
                  style: TextStyle(
                    color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gerenciar Profissionais',
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
                tooltip: isDark ? 'Modo Claro' : 'Modo Escuro',
                onPressed: () => themeNotifier.value = isDark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AmeloTheme.primaryGold,
        foregroundColor: AmeloTheme.primaryNavy,
        onPressed: () => _abrirModalNovoProfissional(context, theme),
        icon: const Icon(Icons.build_rounded),
        label: const Text(
          'Novo Profissional',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou especialidade...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AmeloTheme.textSecondary,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _profissionais.length,
              itemBuilder: (context, index) {
                final prof = _profissionais[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AmeloTheme.primaryGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.construction_rounded,
                        color: AmeloTheme.primaryNavy,
                      ),
                    ),
                    title: Text(
                      prof['nome']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            prof['especialidade']!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AmeloTheme.primaryNavy,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: AmeloTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              prof['telefone']!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AmeloTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: AmeloTheme.textSecondary,
                      ),
                      onSelected: (val) {
                        if (val == 'remover') {
                          setState(() => _profissionais.removeAt(index));
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'editar',
                          child: Text('Editar'),
                        ),
                        const PopupMenuItem(
                          value: 'remover',
                          child: Text(
                            'Remover',
                            style: TextStyle(color: Colors.red),
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
