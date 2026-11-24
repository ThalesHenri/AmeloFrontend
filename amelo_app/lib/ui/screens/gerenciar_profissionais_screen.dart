// lib/ui/screens/gerenciar_profissionais_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../repository/models/profissional_model.dart';
import '../../repository/profissional_repository.dart';
import '../../repository/services/api_service.dart';
import '../../theme.dart';

class GerenciarProfissionaisScreen extends StatefulWidget {
  const GerenciarProfissionaisScreen({super.key});

  @override
  State<GerenciarProfissionaisScreen> createState() =>
      _GerenciarProfissionaisScreenState();
}

class _GerenciarProfissionaisScreenState
    extends State<GerenciarProfissionaisScreen> {
  final _repository = ProfissionalRepository(ApiService());
  List<ProfissionalModel> _profissionais = [];
  Map<int, int> _demandasConcluidas = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final profissionais = await _repository.listarTodos();
      Map<int, int> metricas;
      try {
        final resposta = await ApiService().get(
          '/dashboard/metricas-profissionais/',
        );
        metricas = _mapearMetricas(resposta);
      } catch (_) {
        // Mantém a tela compatível com ambientes onde a rota ainda não foi
        // publicada; calcula a mesma contagem a partir das demandas existentes.
        try {
          final demandas = await ApiService().get('/demandas/');
          metricas = _contarDemandasConcluidas(demandas);
        } catch (_) {
          metricas = {};
        }
      }
      if (!mounted) return;
      setState(() {
        _profissionais = profissionais;
        _demandasConcluidas = metricas;
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

  Map<int, int> _mapearMetricas(dynamic resposta) {
    final itens = resposta is Map && resposta['results'] is List
        ? resposta['results'] as List
        : resposta as List;
    return {
      for (final item in itens)
        (item['id'] as num).toInt(): (item['demandas_concluidas'] as num)
            .toInt(),
    };
  }

  Map<int, int> _contarDemandasConcluidas(dynamic resposta) {
    final demandas = resposta is Map && resposta['results'] is List
        ? resposta['results'] as List
        : resposta as List;
    final contagem = <int, int>{};
    for (final item in demandas) {
      if ((item['status'] as String? ?? '').toUpperCase() != 'CONCLUIDA') {
        continue;
      }
      final profissional = item['profissionalAcionado'];
      final id = profissional is Map ? profissional['id'] : profissional;
      if (id is num) {
        final profissionalId = id.toInt();
        contagem[profissionalId] = (contagem[profissionalId] ?? 0) + 1;
      }
    }
    return contagem;
  }

  void _abrirModalNovoProfissional(BuildContext context, ThemeData theme) {
    final nomeController = TextEditingController();
    final especialidadeController = TextEditingController();
    final telefoneController = TextEditingController();
    final usernameController = TextEditingController();

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
                labelText: 'Telefone de contato *',
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: usernameController,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Usuário para acesso ao portal *',
                helperText: 'A senha inicial será 123456.',
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
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  if (nomeController.text.trim().isEmpty ||
                      especialidadeController.text.trim().isEmpty ||
                      telefoneController.text.trim().isEmpty ||
                      usernameController.text.trim().isEmpty) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Preencha os campos obrigatórios.'),
                      ),
                    );
                    return;
                  }
                  try {
                    await _repository.criar(
                      nome: nomeController.text.trim(),
                      especialidade: especialidadeController.text.trim(),
                      telefone: telefoneController.text.trim(),
                      username: usernameController.text.trim(),
                    );
                    if (!mounted) return;
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    await _carregarDados();
                  } catch (e) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(content: Text('Falha ao cadastrar: $e')),
                    );
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

  Future<void> _configurarAcessoPortal(ProfissionalModel profissional) async {
    final messenger = ScaffoldMessenger.of(context);
    final controller = TextEditingController(
      text: profissional.usernameAcesso ?? '',
    );
    final username = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acesso ao portal profissional'),
        content: TextField(
          controller: controller,
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          decoration: const InputDecoration(
            labelText: 'Nome de usuário',
            helperText: 'A senha inicial será 123456.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Salvar acesso'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (username == null || username.isEmpty) return;

    try {
      await _repository.habilitarPortal(
        id: profissional.id,
        username: username,
      );
      await _carregarDados();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Falha ao habilitar portal: $e')),
      );
    }
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : _profissionais.isEmpty
                ? const Center(child: Text('Nenhum profissional cadastrado.'))
                : ListView.builder(
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
                            prof.nome,
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
                                  prof.especialidade,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AmeloTheme.primaryNavy,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                prof.portalHabilitado
                                    ? 'Portal habilitado · ${prof.usernameAcesso}'
                                    : 'Portal ainda não habilitado',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AmeloTheme.textSecondary,
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
                                    prof.telefone ?? 'Telefone não informado',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AmeloTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${_demandasConcluidas[prof.id] ?? 0}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'concluídas',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              if (prof.portalHabilitado)
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded),
                                  tooltip: 'Copiar link do portal',
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(
                                        text: ApiService.professionalPortalUrl,
                                      ),
                                    );
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Link do portal copiado.',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'portal') {
                                    await _configurarAcessoPortal(prof);
                                    return;
                                  }
                                  if (value != 'remover') return;
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  try {
                                    await _repository.deletar(prof.id);
                                    await _carregarDados();
                                  } catch (e) {
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text('Falha ao remover: $e'),
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'portal',
                                    child: Text(
                                      prof.portalHabilitado
                                          ? 'Alterar usuário do portal'
                                          : 'Habilitar acesso ao portal',
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'remover',
                                    child: Text(
                                      'Remover',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
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
