import 'package:flutter/material.dart';
import '../../theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔮 A Runa Mestra: Puxa as cores corretas do tema atual (Claro ou Escuro)
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
                color: theme.colorScheme.onPrimary, // Adapta ao fundo
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
            icon: Icon(
              Icons.notifications_none_rounded,
              color: theme.colorScheme.onPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BLOCO 1: RESUMO GERAL ---
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
                  dropdownColor: theme.colorScheme.surface, // Adapta ao tema
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

            // Grade de Cards de Resumo
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: const [
                _StatusCard(
                  titulo: 'Total de demandas',
                  valor: '128',
                  icone: Icons.crop_original_rounded,
                  corIcone: Colors.blueAccent,
                ),
                _StatusCard(
                  titulo: 'Abertas',
                  valor: '42',
                  icone: Icons.crop_square_rounded,
                  corIcone: AmeloTheme.statusAbertas,
                ),
                _StatusCard(
                  titulo: 'Urgentes',
                  valor: '11',
                  icone: Icons.error_outline_rounded,
                  corIcone: AmeloTheme.statusUrgente,
                ),
                _StatusCard(
                  titulo: 'Em andamento',
                  valor: '35',
                  icone: Icons.autorenew_rounded,
                  corIcone: AmeloTheme.statusAndamento,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Card de Concluídas (Largura total)
            const _StatusCard(
              titulo: 'Concluídas',
              valor: '75',
              icone: Icons.check_circle_outline_rounded,
              corIcone: AmeloTheme.statusConcluido,
            ),

            const SizedBox(height: 24),

            // --- BLOCO 2: DEMANDAS POR CONDOMÍNIO ---
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

            // Lista Mockada de Condomínios
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

            // --- BLOCO 3: AÇÕES RÁPIDAS (BOTOES INFERIORES) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActionButton(
                  titulo: 'Nova\nDemanda',
                  icone: Icons.add_circle_outline,
                  corFundo: AmeloTheme.statusAbertas, // Azul
                  onTap: () {},
                ),
                _ActionButton(
                  titulo: 'Cadastrar\nCondomínio',
                  icone: Icons.domain_add,
                  corFundo: AmeloTheme.statusConcluido, // Verde
                  badgeText: 'NOVO',
                  onTap: () {},
                ),
                _ActionButton(
                  titulo: 'Buscar\nCondomínio',
                  icone: Icons.search,
                  corFundo: AmeloTheme.primaryNavy, // Azul Escuro
                  onTap: () {},
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
