// lib/ui/screens/demandas_condominio_screen.dart

import 'package:flutter/material.dart';
import '../../app_routes.dart';
import '../../repository/services/api_service.dart';
import '../../theme.dart';

class DemandasCondominioScreen extends StatefulWidget {
  const DemandasCondominioScreen({super.key});

  @override
  State<DemandasCondominioScreen> createState() =>
      _DemandasCondominioScreenState();
}

class _DemandasCondominioScreenState extends State<DemandasCondominioScreen> {
  final ApiService api = ApiService();
  bool _isLoading = true;
  String? _error;
  List<dynamic> _demandas = [];
  bool _dadosCarregados = false;
  String? _filtro;

  int _abertas = 0;
  int _urgentes = 0;
  int _concluidas = 0;
  int _emAndamento = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dadosCarregados) {
      final args =
          (ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?) ??
          {};
      final id = args['id'] as int?;
      _filtro = args['filtro'] as String?;
      _carregarDemandas(id);
      _dadosCarregados = true;
    }
  }

  Future<void> _carregarDemandas(int? condominioId) async {
    try {
      final endpoint = condominioId != null
          ? '/demandas/?condominio=$condominioId'
          : '/demandas/';
      final data = await api.get(endpoint);

      if (!mounted) return;

      final lista = (data is Map && data.containsKey('results'))
          ? data['results'] as List<dynamic>
          : data as List<dynamic>;

      final filtradas = lista.where((item) {
        final status = (item['status'] as String? ?? '').toUpperCase();
        final urgencia = (item['urgencia'] as String? ?? '').toUpperCase();
        switch (_filtro) {
          case 'abertas':
            return status == 'PENDENTE';
          case 'urgentes':
            return urgencia == 'URGENTE' || urgencia == 'ALTA';
          case 'em_andamento':
            return status == 'EM_ANDAMENTO';
          case 'concluidas':
            return status == 'CONCLUIDA';
          default:
            return true;
        }
      }).toList();

      int abertas = 0;
      int urgentes = 0;
      int concluidas = 0;
      int emAndamento = 0;

      for (var item in filtradas) {
        final status = (item['status'] as String? ?? '').toUpperCase();
        final urgencia = (item['urgencia'] as String? ?? '').toUpperCase();
        final dataAberturaStr = item['dataAbertura'] as String?;
        final dataConclusaoStr = item['dataConclusao'] as String?;
        final previsaoStr = item['previsaoConclusao'] as String?;

        if (status == 'PENDENTE' || status == 'EM_ANDAMENTO') {
          abertas++;
        }
        if (urgencia == 'ALTA' || urgencia == 'URGENTE') {
          urgentes++;
        }
        if (status == 'CONCLUIDA') {
          concluidas++;
        }
        if (status == 'EM_ANDAMENTO') {
          emAndamento++;
        }

        // Calcular tempo de resolução para demandas concluidas
        if (status == 'CONCLUIDA' &&
            dataAberturaStr != null &&
            dataConclusaoStr != null) {
          try {
            final aberta = DateTime.parse(dataAberturaStr);
            final concluida = DateTime.parse(dataConclusaoStr);
            final duracao = concluida.difference(aberta);

            String duracaoTexto;
            if (duracao.inDays > 0) {
              duracaoTexto =
                  '${duracao.inDays} dia${duracao.inDays > 1 ? 's' : ''}';
              if (duracao.inHours % 24 > 0) {
                duracaoTexto +=
                    ', ${duracao.inHours % 24} hora${duracao.inHours % 24 > 1 ? 's' : ''}';
              }
            } else if (duracao.inHours > 0) {
              duracaoTexto =
                  '${duracao.inHours} hora${duracao.inHours > 1 ? 's' : ''}';
            } else {
              duracaoTexto = 'Menos de 1 minuto';
            }
            item['tempoResolucao'] = duracaoTexto;
          } catch (_) {
            item['tempoResolucao'] = 'Não disponível';
          }
        }

        // Verificar conformidade com o prazo
        if (status == 'CONCLUIDA' &&
            previsaoStr != null &&
            previsaoStr.isNotEmpty &&
            dataConclusaoStr != null) {
          try {
            final concluida = DateTime.parse(dataConclusaoStr);
            final previsao = DateTime.parse(previsaoStr);
            final diff = concluida.difference(previsao).inMinutes;
            item['foraDoPrazo'] = diff > 0;
          } catch (_) {
            item['foraDoPrazo'] = false;
          }
        }
      }

      setState(() {
        _demandas = filtradas;
        _abertas = abertas;
        _emAndamento = emAndamento;
        _urgentes = urgentes;
        _concluidas = concluidas;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
        {};

    final idCondominio = args['id'] as int?;
    final nome = args['nome'] as String? ?? 'Condomínio';
    final endereco = args['endereco'] as String? ?? 'Endereço não informado';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Demandas por condomínio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Passa o condomínio ativo para pré-seleção na tela de criação
          await Navigator.pushNamed(
            context,
            AppRoutes.novaDemanda,
            arguments: {
              'condominio': {
                'id': idCondominio,
                'nome': nome,
                'endereco': endereco,
              },
            },
          );
          // Recarrega as demandas e contadores ao retornar
          setState(() => _dadosCarregados = false);
          _carregarDemandas(idCondominio);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  endereco,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AmeloTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ResumoChip(
                      label: '$_abertas abertas',
                      color: AmeloTheme.statusAbertas,
                    ),
                    _ResumoChip(
                      label: '$_urgentes urgentes',
                      color: AmeloTheme.statusUrgente,
                    ),
                    _ResumoChip(
                      label: '$_emAndamento em andamento',
                      color: AmeloTheme.statusAndamento,
                    ),
                    _ResumoChip(
                      label: '$_concluidas concluídas',
                      color: AmeloTheme.statusConcluido,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            size: 42,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Não foi possível carregar as demandas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AmeloTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => _carregarDemandas(idCondominio),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _demandas.isEmpty
                ? const Center(
                    child: Text('Nenhuma demanda para este condomínio.'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _demandas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _demandas[index] as Map<String, dynamic>;
                      final idDemanda = item['id'];
                      final titulo = item['titulo'] as String? ?? 'Demanda';
                      final descricao = item['descricao'] as String? ?? '';
                      final statusRaw = item['status'] as String? ?? 'PENDENTE';
                      final condominio =
                          item['condominio'] as Map<String, dynamic>?;
                      final nomeCondominio =
                          condominio?['nome'] as String? ?? 'Condomínio';

                      final status = _statusLabel(statusRaw);
                      final cor = _statusColor(statusRaw);
                      final tempoResolucao = item['tempoResolucao'] as String?;
                      final foraDoPrazo = item['foraDoPrazo'] as bool?;

                      return Card(
                        elevation: 0,
                        color: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              AppRoutes.detalhesDemanda,
                              arguments: {'id': idDemanda},
                            );
                            if (!mounted) return;
                            setState(() => _dadosCarregados = false);
                            _carregarDemandas(idCondominio);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        titulo,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: cor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$nomeCondominio • ${descricao.isNotEmpty ? descricao : 'Sem descrição'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AmeloTheme.textSecondary,
                                  ),
                                ),
                                if (statusRaw == 'CONCLUIDA' &&
                                    tempoResolucao != null) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 12,
                                        color: AmeloTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Resolvida em $tempoResolucao',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AmeloTheme.textSecondary,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              (foraDoPrazo == true
                                                      ? AmeloTheme.statusUrgente
                                                      : foraDoPrazo == false
                                                      ? AmeloTheme
                                                            .statusConcluido
                                                      : AmeloTheme
                                                            .textSecondary)
                                                  .withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          foraDoPrazo == true
                                              ? 'Fora do prazo'
                                              : foraDoPrazo == false
                                              ? 'No prazo'
                                              : 'Sem prazo',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: foraDoPrazo == true
                                                ? AmeloTheme.statusUrgente
                                                : foraDoPrazo == false
                                                ? AmeloTheme.statusConcluido
                                                : AmeloTheme.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
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

  String _statusLabel(String status) {
    switch (status) {
      case 'PENDENTE':
        return 'Pendente';
      case 'EM_ANDAMENTO':
        return 'Em andamento';
      case 'CONCLUIDA':
        return 'Concluída';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDENTE':
        return AmeloTheme.statusAbertas;
      case 'EM_ANDAMENTO':
        return AmeloTheme.statusAndamento;
      case 'CONCLUIDA':
        return AmeloTheme.statusConcluido;
      default:
        return AmeloTheme.statusUrgente;
    }
  }
}

class _ResumoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ResumoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
