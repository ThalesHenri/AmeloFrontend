// lib/ui/screens/gerenciar_supervisores_screen.dart

import 'package:flutter/material.dart';
import '../../repository/services/api_service.dart';
import '../../theme.dart';

class GerenciarSupervisoresScreen extends StatefulWidget {
  const GerenciarSupervisoresScreen({super.key});

  @override
  State<GerenciarSupervisoresScreen> createState() =>
      _GerenciarSupervisoresScreenState();
}

class _GerenciarSupervisoresScreenState
    extends State<GerenciarSupervisoresScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _buscaController = TextEditingController();

  List<Map<String, dynamic>> _supervisores = [];
  List<Map<String, dynamic>> _supervisoresFiltrados = [];
  List<Map<String, dynamic>> _todosCondominios =
      []; // 🏢 Lista dos condomínios cadastrados

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  /// Busca supervisores e condomínios simultaneamente
  Future<void> _inicializarDados() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await Future.wait([_carregarSupervisores(), _carregarCondominios()]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Falha ao invocar os dados: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _carregarSupervisores() async {
    final response = await _api.get('/supervisores/');
    final lista = List<Map<String, dynamic>>.from(response as List);

    setState(() {
      _supervisores = lista;
      _supervisoresFiltrados = lista;
    });
  }

  Future<void> _carregarCondominios() async {
    try {
      final response = await _api.get('/condominios/');

      List<Map<String, dynamic>> listaExtraida = [];

      if (response is Map<String, dynamic> && response.containsKey('results')) {
        listaExtraida = List<Map<String, dynamic>>.from(response['results']);
      } else if (response is List) {
        listaExtraida = List<Map<String, dynamic>>.from(response);
      }

      setState(() {
        _todosCondominios = listaExtraida;
      });

      return;
    } catch (e) {
      setState(() {
        _error = 'Falha ao invocar os dados: $e';
      });
    }
  }

  void _filtrarSupervisores(String query) {
    setState(() {
      if (query.isEmpty) {
        _supervisoresFiltrados = _supervisores;
      } else {
        _supervisoresFiltrados = _supervisores.where((sup) {
          final usuario = sup['usuarioDetalhe'] ?? {};
          final nome = (sup['nome'] ?? usuario['nome'] ?? '')
              .toString()
              .toLowerCase();
          final email = (sup['email'] ?? usuario['email'] ?? '')
              .toString()
              .toLowerCase();
          final busca = query.toLowerCase();
          return nome.contains(busca) || email.contains(busca);
        }).toList();
      }
    });
  }

  Future<void> _abrirModalNovoSupervisor({
    Map<String, dynamic>? supervisor,
  }) async {
    final isEdicao = supervisor != null;

    // Extrai dados do usuário ou do próprio mapa do supervisor
    final usuarioData =
        supervisor?['usuarioDetalhe'] ?? supervisor?['usuario'] ?? {};
    final nomeCtrl = TextEditingController(
      text: supervisor?['nome'] ?? usuarioData['username'] ?? '',
    );
    final emailCtrl = TextEditingController(
      text: supervisor?['email'] ?? usuarioData['email'] ?? '',
    );
    final telefoneCtrl = TextEditingController(
      text: supervisor?['telefone'] ?? usuarioData['telefone'] ?? '',
    );

    // Identifica quais condomínios já estão vinculados a este supervisor
    List<int> condominiosSelecionados = [];
    if (supervisor != null) {
      if (supervisor['condominios'] is List) {
        condominiosSelecionados = List<int>.from(
          (supervisor['condominios'] as List).map(
            (c) => c is Map ? c['id'] : c,
          ),
        );
      } else if (supervisor['condominiosDetalhe'] is List) {
        condominiosSelecionados = List<int>.from(
          (supervisor['condominiosDetalhe'] as List).map((c) => c['id']),
        );
      }
    }

    final publicado = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              title: Text(
                isEdicao ? 'Editar Supervisor' : 'Novo Supervisor',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nomeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Usuário',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: telefoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Telefone / WhatsApp',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🏢 Seção de Vinculação de Condomínios
                    Text(
                      'Vincular Condomínios:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_todosCondominios.isEmpty)
                      const Text(
                        'Nenhum condomínio encontrado para vincular.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AmeloTheme.textSecondary,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _todosCondominios.map((condominio) {
                          final int id = condominio['id'];
                          final String nome =
                              condominio['nome'] ?? 'Condomínio $id';
                          final bool isSelected = condominiosSelecionados
                              .contains(id);

                          return FilterChip(
                            label: Text(nome),
                            selected: isSelected,
                            selectedColor: AmeloTheme.statusConcluido
                                .withOpacity(0.2),
                            checkmarkColor: AmeloTheme.statusConcluido,
                            onSelected: (bool selected) {
                              setModalState(() {
                                if (selected) {
                                  condominiosSelecionados.add(id);
                                } else {
                                  condominiosSelecionados.remove(id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AmeloTheme.primaryNavy,
                  ),
                  onPressed: () async {
                    if (nomeCtrl.text.trim().isEmpty ||
                        emailCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preencha os campos obrigatórios!'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    // 🧙‍♂️ Payload forjado com a lista de condomínios dinâmicos!
                    final payload = {
                      'usuario': {
                        'username': nomeCtrl.text.trim().split(' ')[0],
                        'email': emailCtrl.text.trim(),
                        'telefone': telefoneCtrl.text.trim(),
                        'role': 'SUPERVISOR',
                      },
                      'condominios': condominiosSelecionados,
                    };

                    try {
                      if (isEdicao) {
                        await _api.patch(
                          '/supervisores/${supervisor['id']}/',
                          payload,
                        );
                      } else {
                        await _api.post('/supervisores/', payload);
                      }
                      if (!mounted) return;
                      Navigator.pop(context, true);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erro ao salvar supervisor: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(
                    isEdicao ? 'Atualizar' : 'Salvar',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (publicado == true) {
      _inicializarDados();
    }
  }

  Future<void> _alternarStatusSupervisor(
    Map<String, dynamic> supervisor,
  ) async {
    final bool estaAtivo = supervisor['ativo'] ?? true;
    final id = supervisor['id'];

    try {
      await _api.patch('/supervisores/$id/', {'ativo': !estaAtivo});
      _carregarSupervisores();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alterar status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _excluirSupervisor(Map<String, dynamic> supervisor) async {
    final usuarioData = supervisor['usuarioDetalhe'] ?? supervisor;
    final nome = supervisor['nome'] ?? usuarioData['nome'] ?? 'Supervisor';

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revogar Supervisor'),
        content: Text('Deseja banir o supervisor "$nome" do sistema?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir Definitivamente'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _api.delete('/supervisores/${supervisor['id']}/');
      _carregarSupervisores();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao deletar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestão de Supervisores',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _inicializarDados,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de Pesquisa
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _buscaController,
              onChanged: _filtrarSupervisores,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou e-mail...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _buscaController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _buscaController.clear();
                          _filtrarSupervisores('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: theme.dividerColor.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),

          // Lista de Supervisores
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _inicializarDados,
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _supervisoresFiltrados.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum supervisor encontrado.',
                      style: TextStyle(color: AmeloTheme.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _supervisoresFiltrados.length,
                    itemBuilder: (context, index) {
                      final sup = _supervisoresFiltrados[index];
                      final usuario = sup['usuarioDetalhe'] ?? sup;
                      final bool ativo =
                          sup['ativo'] ?? usuario['ativo'] ?? true;
                      final String nome =
                          sup['nome'] ?? usuario['username'] ?? 'Sem nome';
                      final String email =
                          sup['email'] ?? usuario['email'] ?? 'Sem e-mail';
                      final String telefone =
                          sup['telefone'] ?? usuario['telefone'] ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: ativo
                                ? AmeloTheme.primaryNavy
                                : AmeloTheme.textSecondary,
                            child: Text(
                              nome.isNotEmpty ? nome[0].toUpperCase() : 'S',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  nome,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (ativo
                                              ? AmeloTheme.statusConcluido
                                              : Colors.red)
                                          .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  ativo ? 'Ativo' : 'Inativo',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: ativo
                                        ? AmeloTheme.statusConcluido
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AmeloTheme.textSecondary,
                                  ),
                                ),
                                if (telefone.isNotEmpty)
                                  Text(
                                    'Tel: $telefone',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AmeloTheme.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (opcao) {
                              if (opcao == 'editar') {
                                _abrirModalNovoSupervisor(supervisor: sup);
                              } else if (opcao == 'status') {
                                _alternarStatusSupervisor(sup);
                              } else if (opcao == 'excluir') {
                                _excluirSupervisor(sup);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'editar',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 20),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'status',
                                child: Row(
                                  children: [
                                    Icon(
                                      ativo
                                          ? Icons.block_rounded
                                          : Icons.check_circle_outline,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(ativo ? 'Desativar' : 'Ativar'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'excluir',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Excluir',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AmeloTheme.primaryNavy,
        onPressed: () => _abrirModalNovoSupervisor(),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Novo Supervisor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
