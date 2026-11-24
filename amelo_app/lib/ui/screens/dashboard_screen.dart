// lib/ui/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../app_routes.dart';
import '../../repository/services/api_service.dart';
import '../../theme.dart';
import 'buscar_condominio_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int total = 0;
  int abertas = 0;
  int urgentes = 0;
  int andamento = 0;
  int concluidas = 0;
  bool isLoading = true;
  String? error;
  List<_CondominioBarItem> condominiosResumo = const [];
  List<_CondominioOption> condominiosDisponiveis = const [];
  List<Map<String, dynamic>> _demandas = const [];
  String _condominioSelecionadoId = 'todos';
  List<Map<String, dynamic>> atividadesSupervisores = [];

  @override
  void initState() {
    super.initState();
    _carregarDashboard();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final api = ApiService();
      if (api.isSupervisor && !api.senhaRedefinida) {
        _mostrarDialogoRedefinirSenha();
      }
    });
  }

  // 1. Função que pode ser chamada pelo RefreshIndicator
  Future<void> _carregarDashboard() async {
    final api = ApiService();

    if (!api.isAuthenticated) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        error = 'Sessão expirada. Faça login novamente.';
      });

      _redirecionarParaLogin();
      return;
    }

    try {
      if (error != null) setState(() => error = null);

      // 👇 NOVO: só busca atividades dos supervisores se for Gestor
      final futures = <Future>[
        api.get('/dashboard/summary'),
        api.get('/demandas'),
        api.get('/condominios/'),
      ];
      if (api.isGestor) {
        futures.add(api.get('/dashboard/atividades-supervisores/'));
      }

      final responses = await Future.wait(futures);

      final resumo = responses[0] as Map<String, dynamic>;
      final demandas = responses[1] as List<dynamic>;
      final condominiosRaw = responses[2] is Map
          ? (responses[2] as Map)['results'] as List<dynamic>
          : responses[2] as List<dynamic>;
      final atividades = (api.isGestor && responses.length > 3)
          ? List<Map<String, dynamic>>.from(responses[3] as List)
          : <Map<String, dynamic>>[];

      final grupos = <String, int>{};
      final nomesCondominios = <String, String>{};
      for (final item in demandas) {
        final payload = item as Map<String, dynamic>;
        final condominio = payload['condominio'];
        final nome =
            (condominio is Map<String, dynamic> ? condominio['nome'] : null)
                as String? ??
            'Condomínio sem nome';
        final id = condominio is Map<String, dynamic>
            ? condominio['id']?.toString() ?? 'nome:$nome'
            : 'nome:$nome';
        nomesCondominios[id] = nome;
        grupos[id] = (grupos[id] ?? 0) + 1;
      }

      final maxValor = grupos.values.isEmpty
          ? 1
          : grupos.values.reduce((a, b) => a > b ? a : b);

      final lista = grupos.entries
          .map(
            (entry) => _CondominioBarItem(
              id: entry.key,
              nome: nomesCondominios[entry.key]!,
              valor: entry.value,
              percentual: maxValor <= 0 ? 0 : entry.value / maxValor,
            ),
          )
          .toList();
      lista.sort((a, b) => a.nome.compareTo(b.nome));

      final condominios =
          condominiosRaw
              .whereType<Map<String, dynamic>>()
              .where((condominio) => condominio['id'] != null)
              .map(
                (condominio) => _CondominioOption(
                  id: condominio['id'].toString(),
                  nome: condominio['nome'] as String? ?? 'Condomínio sem nome',
                  endereco:
                      condominio['endereco'] as String? ??
                      'Endereço não informado',
                ),
              )
              .toList()
            ..sort((a, b) => a.nome.compareTo(b.nome));

      if (!mounted) return;

      setState(() {
        total = (resumo['total'] as num?)?.toInt() ?? 0;
        abertas = (resumo['abertas'] as num?)?.toInt() ?? 0;
        urgentes = (resumo['urgentes'] as num?)?.toInt() ?? 0;
        andamento = (resumo['em_andamento'] as num?)?.toInt() ?? 0;
        concluidas = (resumo['concluidas'] as num?)?.toInt() ?? 0;
        condominiosResumo = lista;
        condominiosDisponiveis = condominios;
        _demandas = demandas.cast<Map<String, dynamic>>();
        if (_condominioSelecionadoId != 'todos' &&
            !condominios.any((item) => item.id == _condominioSelecionadoId)) {
          _condominioSelecionadoId = 'todos';
        }
        atividadesSupervisores = atividades; // 👈 NOVO
        isLoading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      final mensagem = e.toString();

      if (mensagem.contains('401') || mensagem.contains('Não autorizado')) {
        api.clearToken();

        if (mounted) {
          setState(() {
            isLoading = false;
            error = 'Sessão expirada. Faça login novamente.';
          });
          _redirecionarParaLogin();
        }
        return;
      }

      setState(() {
        error = mensagem;
        isLoading = false;
      });
    }
  }

  // 2. Magia de Logout Manual
  void _fazerLogout() {
    final api = ApiService();
    api.clearToken();
    _redirecionarParaLogin();
  }

  void _abrirDemandas(String filtro, String titulo) {
    _CondominioOption? condominioSelecionado;
    for (final condominio in condominiosDisponiveis) {
      if (condominio.id == _condominioSelecionadoId) {
        condominioSelecionado = condominio;
        break;
      }
    }
    Navigator.pushNamed(
      context,
      AppRoutes.demandasCondominio,
      arguments: {
        'id': int.tryParse(_condominioSelecionadoId),
        'nome': condominioSelecionado?.nome ?? titulo,
        'endereco': condominioSelecionado?.endereco ?? 'Filtro de Demandas',
        'filtro': filtro,
      },
    );
  }

  void _abrirCondominios() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        settings: const RouteSettings(name: AppRoutes.buscarCondominio),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const BuscarCondominioScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.025),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 240),
        reverseTransitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  void _redirecionarParaLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final api = ApiService();
    final isGestor = api.isGestor; // 👈 define o papel do usuário logado
    final demandasFiltradas = _condominioSelecionadoId == 'todos'
        ? _demandas
        : _demandas.where((demanda) {
            final condominio = demanda['condominio'];
            return condominio is Map &&
                condominio['id']?.toString() == _condominioSelecionadoId;
          }).toList();
    final totalResumo = _condominioSelecionadoId == 'todos'
        ? total
        : demandasFiltradas.length;
    final abertasResumo = _condominioSelecionadoId == 'todos'
        ? abertas
        : demandasFiltradas
              .where((demanda) => demanda['status'] == 'PENDENTE')
              .length;
    final urgentesResumo = _condominioSelecionadoId == 'todos'
        ? urgentes
        : demandasFiltradas
              .where(
                (demanda) =>
                    demanda['urgencia'] == 'URGENTE' ||
                    demanda['urgencia'] == 'ALTA',
              )
              .length;
    final andamentoResumo = _condominioSelecionadoId == 'todos'
        ? andamento
        : demandasFiltradas
              .where((demanda) => demanda['status'] == 'EM_ANDAMENTO')
              .length;
    final concluidasResumo = _condominioSelecionadoId == 'todos'
        ? concluidas
        : demandasFiltradas
              .where((demanda) => demanda['status'] == 'CONCLUIDA')
              .length;
    final condominiosResumoVisiveis = _condominioSelecionadoId == 'todos'
        ? condominiosResumo
        : condominiosResumo
              .where((item) => item.id == _condominioSelecionadoId)
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isGestor
                  ? 'Olá, Síndico!'
                  : 'Olá, Supervisor!', // 👈 saudação por role
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const Text(
              'Bem-vindo ao painel da Amelo',
              style: TextStyle(fontSize: 14, color: AmeloTheme.textSecondary),
            ),
          ],
        ),
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
                      : AmeloTheme.lightSurface,
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
            icon: Icon(
              Icons.logout_rounded,
              color: theme.colorScheme.onPrimary,
            ),
            tooltip: 'Sair da conta',
            onPressed: _fazerLogout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarDashboard,
              color: theme.colorScheme.primary,
              child: error != null
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        padding: const EdgeInsets.all(24.0),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Não foi possível carregar:\n$error\n\n⬇️ Puxe para baixo para tentar novamente.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔒 Banner de redefinição de senha para Supervisor
                          if (api.isSupervisor && !api.senhaRedefinida)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AmeloTheme.statusUrgente.withOpacity(
                                  0.12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AmeloTheme.statusUrgente.withOpacity(
                                    0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lock_reset_rounded,
                                    color: AmeloTheme.statusUrgente,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Sua senha é a padrão.',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Por segurança, redefina sua senha.',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: _mostrarDialogoRedefinirSenha,
                                    style: TextButton.styleFrom(
                                      backgroundColor: AmeloTheme.statusUrgente,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Redefinir',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Resumo geral',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(
                                width: 180,
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  isDense: true,
                                  value: _condominioSelecionadoId,
                                  dropdownColor: theme.colorScheme.surface,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 12,
                                  ),
                                  icon: const Icon(Icons.expand_more_rounded),
                                  underline: const SizedBox(),
                                  items: [
                                    const DropdownMenuItem(
                                      value: 'todos',
                                      child: Text('Todos os condomínios'),
                                    ),
                                    ...condominiosDisponiveis.map(
                                      (condominio) => DropdownMenuItem(
                                        value: condominio.id,
                                        child: Text(
                                          condominio.nome,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(
                                      () => _condominioSelecionadoId = value,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.4,
                            children: [
                              _StatusCard(
                                titulo: 'Total de demandas',
                                valor: totalResumo.toString(),
                                icone: Icons.crop_original_rounded,
                                corIcone: Colors.blueAccent,
                                onTap: () => _abrirDemandas(
                                  'todas',
                                  'Todas as Demandas',
                                ),
                              ),
                              _StatusCard(
                                titulo: 'Abertas',
                                valor: abertasResumo.toString(),
                                icone: Icons.crop_square_rounded,
                                corIcone: AmeloTheme.statusAbertas,
                                onTap: () => _abrirDemandas(
                                  'abertas',
                                  'Demandas Abertas',
                                ),
                              ),
                              _StatusCard(
                                titulo: 'Urgentes',
                                valor: urgentesResumo.toString(),
                                icone: Icons.error_outline_rounded,
                                corIcone: AmeloTheme.statusUrgente,
                                onTap: () => _abrirDemandas(
                                  'urgentes',
                                  'Demandas Urgentes',
                                ),
                              ),
                              _StatusCard(
                                titulo: 'Em andamento',
                                valor: andamentoResumo.toString(),
                                icone: Icons.autorenew_rounded,
                                corIcone: AmeloTheme.statusAndamento,
                                onTap: () => _abrirDemandas(
                                  'em_andamento',
                                  'Demandas em Andamento',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          _StatusCard(
                            titulo: 'Concluídas',
                            valor: concluidasResumo.toString(),
                            icone: Icons.check_circle_outline_rounded,
                            corIcone: AmeloTheme.statusConcluido,
                            onTap: () => _abrirDemandas(
                              'concluidas',
                              'Demandas Concluídas',
                            ),
                          ),

                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Demandas por condomínio',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.demandasCondominio,
                                    arguments: {
                                      'id': null,
                                      'nome': 'Todas as Demandas',
                                      'endereco': 'Geral do Sistema',
                                    },
                                  );
                                },
                                child: const Text(
                                  'Ver todas',
                                  style: TextStyle(
                                    color: AmeloTheme.statusAbertas,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (condominiosResumoVisiveis.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Nenhuma demanda cadastrada para os condomínios do usuário.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AmeloTheme.textSecondary,
                                ),
                              ),
                            )
                          else
                            ...condominiosResumoVisiveis,

                          // 👇 NOVO: feed de ações dos supervisores (só para Gestor)
                          if (isGestor) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Ações dos supervisores',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (atividadesSupervisores.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.history_rounded,
                                      color: AmeloTheme.textSecondary,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'As ações registradas pelos supervisores aparecerão aqui.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AmeloTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ...atividadesSupervisores.map((atividade) {
                                final supervisor =
                                    atividade['supervisor'] as String? ??
                                    'Supervisor';
                                final descricao =
                                    atividade['descricao'] as String? ??
                                    'Atualizou uma demanda';
                                final demanda =
                                    atividade['demanda'] as String? ??
                                    'Demanda';
                                final data = DateTime.tryParse(
                                  atividade['data'] as String? ?? '',
                                )?.toLocal();
                                final dataFormatada = data == null
                                    ? null
                                    : '${data.day.toString().padLeft(2, '0')}/'
                                          '${data.month.toString().padLeft(2, '0')}/'
                                          '${data.year} às '
                                          '${data.hour.toString().padLeft(2, '0')}:'
                                          '${data.minute.toString().padLeft(2, '0')}';
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  color: theme.colorScheme.surface,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: AmeloTheme
                                              .primaryGold
                                              .withValues(alpha: 0.16),
                                          child: const Icon(
                                            Icons.supervisor_account_rounded,
                                            color: AmeloTheme.primaryGold,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                supervisor,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                descricao,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.85),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                demanda,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AmeloTheme.statusAbertas,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (dataFormatada != null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  dataFormatada,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AmeloTheme
                                                        .textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                          ],

                          const SizedBox(height: 24),

                          Text(
                            'Ações Rápidas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 🪄 GRID DE AÇÕES RÁPIDAS — filtrado por role
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.start,
                            children: [
                              _ActionButton(
                                titulo: 'Nova\nDemanda',
                                icone: Icons.add_circle_outline,
                                corFundo: AmeloTheme.statusAbertas,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.novaDemanda,
                                  );
                                },
                              ),
                              // 🔄 Ação alternada conforme o papel do usuário
                              _ActionButton(
                                titulo: 'Demandas por\nCondomínio',
                                icone: Icons.apartment_rounded,
                                corFundo: AmeloTheme.primaryNavy,
                                onTap: _abrirCondominios,
                              ),
                              _ActionButton(
                                titulo: 'Cadastrar\nCondomínio',
                                icone: Icons.domain_add,
                                corFundo: AmeloTheme.statusConcluido,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.cadastrarCondominio,
                                ),
                              ),
                              _ActionButton(
                                titulo: 'Gerenciar\nProfissionais',
                                icone: Icons.handyman_outlined,
                                corFundo: AmeloTheme.primaryGold,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.gerenciarProfissionais,
                                ),
                              ),
                              // 🔒 Ação exclusiva do Gestor
                              if (isGestor) ...[
                                _ActionButton(
                                  titulo: 'Gerenciar\nSupervisores',
                                  icone: Icons.supervisor_account_rounded,
                                  corFundo: AmeloTheme.primaryGold,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.gerenciarSupervisores,
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
    );
  }

  Future<void> _mostrarDialogoRedefinirSenha() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const _RedefinirSenhaDialog(),
    );

    if (result == true && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }
}

class _RedefinirSenhaDialog extends StatefulWidget {
  const _RedefinirSenhaDialog();

  @override
  State<_RedefinirSenhaDialog> createState() => _RedefinirSenhaDialogState();
}

class _RedefinirSenhaDialogState extends State<_RedefinirSenhaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _error = null;
      _isSubmitting = true;
    });
    try {
      await ApiService().redefinirSenha(
        senhaAtual: _senhaAtualController.text,
        novaSenha: _novaSenhaController.text,
        confirmarSenha: _confirmarSenhaController.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      var message = e.toString();
      if (message.contains('[')) {
        message = message.replaceAll(RegExp(r'\[.*\]\s*'), '');
      }
      if (message.contains('senha_atual') || message.contains('Senha atual')) {
        message = 'Senha atual incorreta.';
      }
      setState(() {
        _error = message;
        _isSubmitting = false;
      });
    }
  }

  String? _required(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.lock_reset_rounded, color: AmeloTheme.statusUrgente),
          SizedBox(width: 10),
          Text('Redefinir Senha'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _senhaAtualController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha atual'),
                validator: (value) =>
                    _required(value, 'Informe a senha atual.'),
              ),
              TextFormField(
                controller: _novaSenhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nova senha'),
                validator: (value) {
                  final error = _required(value, 'Informe a nova senha.');
                  if (error != null) return error;
                  if (value!.trim().length < 6) {
                    return 'A senha deve ter ao menos 6 caracteres.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmarSenhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar nova senha',
                ),
                validator: (value) {
                  final error = _required(value, 'Confirme a nova senha.');
                  if (error != null) return error;
                  if (value != _novaSenhaController.text) {
                    return 'As senhas não coincidem.';
                  }
                  return null;
                },
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: TextStyle(color: AmeloTheme.statusUrgente),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _confirmar,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirmar'),
        ),
      ],
    );
  }
}

// ─── WIDGETS AUXILIARES COM CORES DINÂMICAS ──────────────────────────────────

class _StatusCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;
  final Color corIcone;
  final VoidCallback? onTap;

  const _StatusCard({
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.corIcone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [Icon(icone, color: corIcone, size: 20)]),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AmeloTheme.textSecondary,
                    ),
                  ),
                  Text(
                    valor,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CondominioBarItem extends StatelessWidget {
  final String id;
  final String nome;
  final int valor;
  final double percentual;

  const _CondominioBarItem({
    required this.id,
    required this.nome,
    required this.valor,
    required this.percentual,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              nome,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentual,
                color: AmeloTheme.statusAbertas,
                backgroundColor: theme.scaffoldBackgroundColor,
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Text(
              '$valor',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CondominioOption {
  final String id;
  final String nome;
  final String endereco;

  const _CondominioOption({
    required this.id,
    required this.nome,
    required this.endereco,
  });
}

class _ActionButton extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final Color corFundo;
  final VoidCallback onTap;

  const _ActionButton({
    required this.titulo,
    required this.icone,
    required this.corFundo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: corFundo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icone, color: Colors.white, size: 28),
                const SizedBox(height: 8),
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
