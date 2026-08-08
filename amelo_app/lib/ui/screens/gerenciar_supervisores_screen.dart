// lib/ui/screens/gerenciar_supervisores_screen.dart

import 'package:flutter/material.dart';
import '../../theme.dart';

class GerenciarSupervisoresScreen extends StatefulWidget {
  const GerenciarSupervisoresScreen({super.key});

  @override
  State<GerenciarSupervisoresScreen> createState() =>
      _GerenciarSupervisoresScreenState();
}

class _GerenciarSupervisoresScreenState
    extends State<GerenciarSupervisoresScreen> {
  // Dados Fake por enquanto, depois será substituído por uma chamada à API
  final List<Map<String, String>> _supervisores = [
    {
      'id': '1',
      'nome': 'Carlos Silva',
      'telefone': '(11) 98888-1111',
      'data_criacao': '10/01/2026',
    },
    {
      'id': '2',
      'nome': 'Ana Paula',
      'telefone': '(11) 97777-2222',
      'data_criacao': '15/02/2026',
    },
    {
      'id': '3',
      'nome': 'Marcos Oliveira',
      'telefone': '(11) 96666-3333',
      'data_criacao': '01/04/2026',
    },
  ];

  void _abrirModalNovoSupervisor(BuildContext context, ThemeData theme) {
    final nomeController = TextEditingController();
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
              'Cadastrar Novo Supervisor',
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
                labelText: 'Nome completo',
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
                  if (nomeController.text.isNotEmpty) {
                    setState(() {
                      _supervisores.add({
                        'id': '${_supervisores.length + 1}',
                        'nome': nomeController.text,
                        'telefone': telefoneController.text,
                        'data_criacao': '22/07/2026',
                      });
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text(
                  'Salvar Supervisor',
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
          'Gerenciar Supervisores',
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
        onPressed: () => _abrirModalNovoSupervisor(context, theme),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Novo Supervisor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar supervisor por nome...',
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
              itemCount: _supervisores.length,
              itemBuilder: (context, index) {
                final supervisor = _supervisores[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AmeloTheme.primaryNavy,
                      child: Text(
                        supervisor['nome']![0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      supervisor['nome']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              supervisor['telefone']!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AmeloTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Cadastrado em: ${supervisor['data_criacao']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AmeloTheme.textSecondary.withOpacity(0.8),
                          ),
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
                          setState(() => _supervisores.removeAt(index));
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
