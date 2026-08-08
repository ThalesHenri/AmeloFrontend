import 'package:flutter/material.dart';
import '../../app_routes.dart';
import '../../repository/services/api_service.dart';
import '../../theme.dart';

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

  @override
  void initState() {
    super.initState();
    _carregarDashboard();
  }

  Future<void> _carregarDashboard() async {
    final api = ApiService();

    if (!api.isAuthenticated) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        error = 'Sessão expirada. Faça login novamente.';
      });

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
      return;
    }

    try {
      final data = await api.get('/dashboard/summary');

      if (!mounted) return;

      setState(() {
        total = (data['total'] as num?)?.toInt() ?? 0;
        abertas = (data['abertas'] as num?)?.toInt() ?? 0;
        urgentes = (data['urgentes'] as num?)?.toInt() ?? 0;
        andamento = (data['em_andamento'] as num?)?.toInt() ?? 0;
        concluidas = (data['concluidas'] as num?)?.toInt() ?? 0;
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

          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
        return;
      }

      setState(() {
        error = mensagem;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, Síndico!',
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
              Icons.notifications_none_rounded,
              color: theme.colorScheme.onPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Não foi possível carregar o dashboard: $error',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      DropdownButton<String>(
                        value: 'Todos os condomínios',
                        dropdownColor: theme.colorScheme.surface,
                        style: const TextStyle(
                          color: AmeloTheme.textSecondary,
                          fontSize: 12,
                        ),
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: 'Todos os condomínios',
                            child: Text('Todos os condomínios'),
                          ),
                        ],
                        onChanged: (value) {},
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
                        valor: total.toString(),
                        icone: Icons.crop_original_rounded,
                        corIcone: Colors.blueAccent,
                      ),
                      _StatusCard(
                        titulo: 'Abertas',
                        valor: abertas.toString(),
                        icone: Icons.crop_square_rounded,
                        corIcone: AmeloTheme.statusAbertas,
                      ),
                      _StatusCard(
                        titulo: 'Urgentes',
                        valor: urgentes.toString(),
                        icone: Icons.error_outline_rounded,
                        corIcone: AmeloTheme.statusUrgente,
                      ),
                      _StatusCard(
                        titulo: 'Em andamento',
                        valor: andamento.toString(),
                        icone: Icons.autorenew_rounded,
                        corIcone: AmeloTheme.statusAndamento,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _StatusCard(
                    titulo: 'Concluídas',
                    valor: concluidas.toString(),
                    icone: Icons.check_circle_outline_rounded,
                    corIcone: AmeloTheme.statusConcluido,
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
                        onPressed: () {},
                        child: const Text(
                          'Ver todas',
                          style: TextStyle(color: AmeloTheme.statusAbertas),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  const _CondominioBarItem(
                    nome: 'Residencial Jardim das Flores',
                    valor: 18,
                    percentual: 0.8,
                  ),
                  const _CondominioBarItem(
                    nome: 'Edifício Parque Central',
                    valor: 15,
                    percentual: 0.65,
                  ),
                  const _CondominioBarItem(
                    nome: 'Condomínio Vila do Sol',
                    valor: 12,
                    percentual: 0.5,
                  ),
                  const _CondominioBarItem(
                    nome: 'Residencial das Palmeiras',
                    valor: 10,
                    percentual: 0.4,
                  ),
                  const _CondominioBarItem(
                    nome: 'Edifício Maria Carolina',
                    valor: 8,
                    percentual: 0.3,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ActionButton(
                        titulo: 'Nova\nDemanda',
                        icone: Icons.add_circle_outline,
                        corFundo: AmeloTheme.statusAbertas,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.novaDemanda);
                        },
                      ),
                      _ActionButton(
                        titulo: 'Cadastrar\nCondomínio',
                        icone: Icons.domain_add,
                        corFundo: AmeloTheme.statusConcluido,
                        badgeText: 'NOVO',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.cadastrarCondominio,
                          );
                        },
                      ),
                      _ActionButton(
                        titulo: 'Buscar\nCondomínio',
                        icone: Icons.search,
                        corFundo: AmeloTheme.primaryNavy,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.buscarCondominio,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

// ─── WIDGETS AUXILIARES COM CORES DINÂMICAS ──────────────────────────────────

class _StatusCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;
  final Color corIcone;

  const _StatusCard({
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.corIcone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surface, // Adapta ao tema
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
                    color: theme.colorScheme.onSurface, // Adapta ao tema
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CondominioBarItem extends StatelessWidget {
  final String nome;
  final int valor;
  final double percentual;

  const _CondominioBarItem({
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
                color: theme.colorScheme.onSurface, // Adapta ao tema
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
                backgroundColor:
                    theme.scaffoldBackgroundColor, // Mais contraste
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
                color: theme.colorScheme.onSurface, // Adapta ao tema
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// O Novo Componente: Botões Quadrados de Ação
class _ActionButton extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final Color corFundo;
  final VoidCallback onTap;
  final String? badgeText;

  const _ActionButton({
    required this.titulo,
    required this.icone,
    required this.corFundo,
    required this.onTap,
    this.badgeText,
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
          if (badgeText != null)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AmeloTheme.primaryGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText!,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
