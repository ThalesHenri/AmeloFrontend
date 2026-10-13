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

  Future<void> _editarCondominio(CondominioModel condominio) async {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController(text: condominio.nome);
    final enderecoController = TextEditingController(text: condominio.endereco);
    final cidadeController = TextEditingController(text: condominio.cidade);
    final estadoController = TextEditingController(text: condominio.estado);
    final cepController = TextEditingController(text: condominio.cep ?? '');
    final telefoneController = TextEditingController(
      text: condominio.telefone ?? '',
    );
    final emailController = TextEditingController(text: condominio.email ?? '');
    final observacoesController = TextEditingController(
      text: condominio.observacoes ?? '',
    );

    try {
      final dados = await showDialog<Map<String, String>>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Editar condomínio'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _campoEdicao(nomeController, 'Nome', obrigatorio: true),
                    _campoEdicao(
                      enderecoController,
                      'Endereço',
                      obrigatorio: true,
                    ),
                    _campoEdicao(cidadeController, 'Cidade', obrigatorio: true),
                    _campoEdicao(
                      estadoController,
                      'Estado (UF)',
                      obrigatorio: true,
                      maxLength: 2,
                    ),
                    _campoEdicao(cepController, 'CEP', obrigatorio: true),
                    _campoEdicao(telefoneController, 'Telefone'),
                    _campoEdicao(emailController, 'E-mail'),
                    _campoEdicao(
                      observacoesController,
                      'Observações',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, {
                    'nome': nomeController.text.trim(),
                    'endereco': enderecoController.text.trim(),
                    'cidade': cidadeController.text.trim(),
                    'estado': estadoController.text.trim().toUpperCase(),
                    'cep': cepController.text.trim(),
                    'telefone': telefoneController.text.trim(),
                    'email': emailController.text.trim(),
                    'observacoes': observacoesController.text.trim(),
                  });
                }
              },
              child: const Text('Salvar alterações'),
            ),
          ],
        ),
      );

      if (dados == null) return;

      await _repository.atualizarSemLerResposta(condominio.id, {
        ...dados,
        'telefone': dados['telefone']!.isEmpty ? null : dados['telefone'],
        'email': dados['email']!.isEmpty ? null : dados['email'],
        'observacoes': dados['observacoes']!.isEmpty
            ? null
            : dados['observacoes'],
      });

      if (!mounted) return;
      final atualizado = CondominioModel(
        id: condominio.id,
        nome: dados['nome']!,
        endereco: dados['endereco']!,
        cidade: dados['cidade']!,
        estado: dados['estado']!,
        cep: dados['cep'],
        telefone: dados['telefone'],
        email: dados['email'],
        observacoes: dados['observacoes'],
        imagem: condominio.imagem,
      );
      setState(() {
        final index = _condominios.indexWhere(
          (item) => item.id == condominio.id,
        );
        if (index != -1) _condominios[index] = atualizado;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Condomínio atualizado com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível atualizar o condomínio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      nomeController.dispose();
      enderecoController.dispose();
      cidadeController.dispose();
      estadoController.dispose();
      cepController.dispose();
      telefoneController.dispose();
      emailController.dispose();
      observacoesController.dispose();
    }
  }

  Widget _campoEdicao(
    TextEditingController controller,
    String rotulo, {
    bool obrigatorio = false,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        decoration: InputDecoration(labelText: rotulo),
        validator: (value) {
          if (obrigatorio && (value == null || value.trim().isEmpty)) {
            return 'Campo obrigatório';
          }
          if (rotulo == 'Estado (UF)' && value != null && value.length != 2) {
            return 'Informe a sigla com 2 letras';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _excluirCondominio(CondominioModel condominio) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir condomínio?'),
        content: Text(
          'Deseja excluir "${condominio.nome}"? Esta ação também excluirá '
          'permanentemente as demandas vinculadas a este condomínio.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _repository.deletar(condominio.id);
      if (!mounted) return;
      setState(() {
        _condominios.removeWhere((item) => item.id == condominio.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Condomínio excluído com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível excluir o condomínio: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
                        condominio: condominio,
                        abertas: abertas,
                        urgentes: urgentes,
                        concluidas: concluidas,
                        onEditar: () => _editarCondominio(condominio),
                        onExcluir: () => _excluirCondominio(condominio),
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
  final CondominioModel condominio;
  final int abertas;
  final int urgentes;
  final int concluidas;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _CondominioCardItem({
    required this.condominio,
    required this.abertas,
    required this.urgentes,
    required this.concluidas,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.demandasCondominio,
                  arguments: {
                    'id': condominio.id,
                    'nome': condominio.nome,
                    'endereco': condominio.endereco,
                    'abertas': abertas,
                    'urgentes': urgentes,
                    'concluidas': concluidas,
                  },
                );
              },
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
                            condominio.nome,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            condominio.endereco,
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
                              _buildPill(
                                '$concluidas',
                                AmeloTheme.statusConcluido,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Ações do condomínio',
            onSelected: (acao) {
              if (acao == 'editar') onEditar();
              if (acao == 'excluir') onExcluir();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'editar',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Editar'),
                ),
              ),
              PopupMenuItem(
                value: 'excluir',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Excluir'),
                ),
              ),
            ],
          ),
        ],
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
