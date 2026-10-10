// lib/ui/screens/detalhes_demanda_screen.dart

import 'package:flutter/material.dart';
import '../../app_routes.dart';
import '../../repository/services/api_service.dart';
import '../../theme.dart';

class DetalhesDemandaScreen extends StatefulWidget {
  const DetalhesDemandaScreen({super.key});

  @override
  State<DetalhesDemandaScreen> createState() => _DetalhesDemandaScreenState();
}

class _DetalhesDemandaScreenState extends State<DetalhesDemandaScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _demanda;
  bool _isLoading = true;
  String? _error;
  bool _initDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initDone) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final id = args?['id'];
      if (id != null) {
        _carregarDetalhes(id);
      } else {
        setState(() {
          _error = 'ID da demanda não fornecido.';
          _isLoading = false;
        });
      }
      _initDone = true;
    }
  }

  Future<void> _carregarDetalhes(dynamic id) async {
    try {
      final data = await _api.get('/demandas/$id/');
      setState(() {
        _demanda = data as Map<String, dynamic>;
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

  Future<void> _avancarStatus() async {
    if (_demanda == null) return;

    final statusAtual = _demanda!['status'] as String? ?? 'PENDENTE';
    String novoStatus;

    if (statusAtual == 'PENDENTE') {
      novoStatus = 'EM_ANDAMENTO';
    } else if (statusAtual == 'EM_ANDAMENTO') {
      novoStatus = 'CONCLUIDA';
    } else {
      return;
    }

    try {
      setState(() => _isLoading = true);
      final id = _demanda!['id'];

      await _api.patch('/demandas/$id/', {'status': novoStatus});
      await _carregarDetalhes(id);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao avançar status: $e')));
    }
  }

  Future<void> _editarDemanda() async {
    if (_demanda == null) return;

    final resultado = await Navigator.pushNamed(
      context,
      AppRoutes.novaDemanda,
      arguments: {'demanda': _demanda, 'id': _demanda!['id']},
    );

    if (resultado == true) {
      _carregarDetalhes(_demanda!['id']);
    }
  }

  Future<void> _excluirDemanda() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Demanda'),
        content: const Text(
          'Tem certeza que deseja excluir esta demanda permanentemente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final id = _demanda!['id'];
      await _api.delete('/demandas/$id/');
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes da Demanda')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes da Demanda')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_error!),
          ),
        ),
      );
    }

    if (_demanda == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes da Demanda')),
        body: const Center(child: Text('Demanda não encontrada.')),
      );
    }

    final titulo = _demanda!['titulo'] as String? ?? 'Sem título';
    final descricao = _demanda!['descricao'] as String? ?? 'Sem descrição';
    final observacoes =
        _demanda!['observacoes'] as String? ?? 'Nenhuma observação informada.';

    final condominio = _demanda!['condominio'] is Map
        ? _demanda!['condominio'] as Map<String, dynamic>
        : {};
    final nomeCondominio = condominio['nome'] as String? ?? 'Condomínio';
    final enderecoCondominio =
        condominio['endereco'] as String? ?? 'Endereço não informado';

    final criadoPorObj = _demanda!['criado_por'] ?? _demanda!['criadoPor'];
    final criadoPor = criadoPorObj is Map
        ? criadoPorObj['nome'] as String?
        : 'Não atribuído';

    final profObj =
        _demanda!['profissional_acionado'] ?? _demanda!['profissionalAcionado'];
    final profissional = profObj is Map
        ? profObj['nome'] as String?
        : 'Nenhum acionado';

    final statusRaw = _demanda!['status'] as String? ?? 'PENDENTE';
    final urgenciaRaw = _demanda!['urgencia'] as String? ?? 'NORMAL';

    final statusLabel = _obterStatusLabel(statusRaw);
    final statusColor = _obterStatusColor(statusRaw);
    final urgencyLabel = _obterUrgenciaLabel(urgenciaRaw);
    final urgencyColor = _obterUrgenciaColor(urgenciaRaw);

    final dataAberturaObj = DateTime.tryParse(_demanda!['dataAbertura'] as String? ?? '');
    final dataConclusaoObj = DateTime.tryParse(_demanda!['dataConclusao'] as String? ?? '');
    final previsaoObj = _demanda!['previsaoConclusao'] != null
        ? DateTime.tryParse(_demanda!['previsaoConclusao'] as String? ?? '')
        : null;
    DateTime? dataAberturaParseada;
    DateTime? dataConclusaoParseada;
    DateTime? previsaoParseada;
    if (dataAberturaObj != null) dataAberturaParseada = dataAberturaObj;
    if (dataConclusaoObj != null) dataConclusaoParseada = dataConclusaoObj;
    if (previsaoObj != null) previsaoParseada = previsaoObj;

    String textoTempoResolucao = '';
    String textoPrazoResultado = '';
    Color corPrazoResultado = AmeloTheme.textSecondary;

    void calcularTempoResolucao() {
      if (dataAberturaParseada == null || dataConclusaoParseada == null) {
        textoTempoResolucao = 'Não disponível';
        textoPrazoResultado = '';
        corPrazoResultado = AmeloTheme.textSecondary;
        return;
      }

      final duracao = dataConclusaoParseada.difference(dataAberturaParseada);

      String duracaoTexto;
      if (duracao.inDays > 0) {
        duracaoTexto = '${duracao.inDays} dia${duracao.inDays > 1 ? 's' : ''}';
        if (duracao.inHours % 24 > 0) {
          duracaoTexto += ', ${duracao.inHours % 24} hora${duracao.inHours % 24 > 1 ? 's' : ''}';
        }
        if (duracao.inMinutes % 60 > 0) {
          duracaoTexto += ', ${duracao.inMinutes % 60} min';
        }
      } else if (duracao.inHours > 0) {
        duracaoTexto = '${duracao.inHours} hora${duracao.inHours > 1 ? 's' : ''}';
        if (duracao.inMinutes % 60 > 0) {
          duracaoTexto += ', ${duracao.inMinutes % 60} min';
        }
      } else if (duracao.inMinutes > 0) {
        duracaoTexto = '${duracao.inMinutes} min';
      } else {
        duracaoTexto = 'Menos de 1 minuto';
      }

      textoTempoResolucao = 'Resolvida em $duracaoTexto';

      if (previsaoParseada != null) {
        final diff = dataConclusaoParseada.difference(previsaoParseada).inMinutes;
        if (diff <= 0) {
          textoPrazoResultado = 'Concluída dentro do prazo';
          corPrazoResultado = AmeloTheme.statusConcluido;
        } else {
          final atrasoMins = diff.abs();
          String atrasoTexto;
          if (atrasoMins >= 1440) {
            atrasoTexto = '${atrasoMins / 1440} dia${atrasoMins / 1440 > 1 ? 's' : ''}';
          } else if (atrasoMins >= 60) {
            atrasoTexto = '${atrasoMins / 60} hora${atrasoMins / 60 > 1 ? 's' : ''}';
          } else {
            atrasoTexto = '$atrasoMins min';
          }
          textoPrazoResultado = 'Concluída fora do prazo (atraso de $atrasoTexto)';
          corPrazoResultado = AmeloTheme.statusUrgente;
        }
      } else {
        textoPrazoResultado = 'Sem prazo definido';
        corPrazoResultado = AmeloTheme.textSecondary;
      }
    }

    // Callback disparado assim que a tela é montada, para garantir que os dados
    // ja estejam disponiveis antes de calcular o tempo de resolucao.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      calcularTempoResolucao();
    });

    String formatarData(String? isoString) {
      if (isoString == null) return 'Data não informada';
      try {
        final data = DateTime.parse(isoString).toLocal();
        return '${data.day.toString().padLeft(2, '0')}/'
            '${data.month.toString().padLeft(2, '0')}/'
            '${data.year} às '
            '${data.hour.toString().padLeft(2, '0')}:'
            '${data.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        return isoString;
      }
    }

    final dataAbertura = formatarData(
      _demanda!['dataAbertura'] as String? ?? 'Data não informada',
    );
    final previsao = formatarData(
      _demanda!['previsaoConclusao'] as String? ?? 'Não definida',
    );

    bool podeAvancar = statusRaw != 'CONCLUIDA';
    String textoBotaoAvancar;
    Color corBotaoAvancar;

    if (statusRaw == 'PENDENTE') {
      textoBotaoAvancar = 'Iniciar Atendimento';
      corBotaoAvancar = AmeloTheme.statusAndamento;
    } else if (statusRaw == 'EM_ANDAMENTO') {
      textoBotaoAvancar = 'Concluir Demanda';
      corBotaoAvancar = AmeloTheme.statusConcluido;
    } else {
      textoBotaoAvancar = 'Demanda Concluída';
      corBotaoAvancar = AmeloTheme.textSecondary;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalhes da Demanda',
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
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: urgencyColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: urgencyColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: urgencyColor, size: 8),
                  const SizedBox(width: 6),
                  Text(
                    urgencyLabel,
                    style: TextStyle(
                      color: urgencyColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$nomeCondominio\n$enderecoCondominio',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AmeloTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: theme.colorScheme.surface,
                    child: Icon(
                      Icons.apartment_rounded,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _buildInfoRow('Responsável', criadoPor ?? 'Sistema', theme),
            _buildInfoRow(
              'Profissional acionado',
              profissional ?? 'Nenhum',
              theme,
            ),
            _buildStatusRow(
              'Status da demanda',
              statusLabel,
              statusColor,
              theme,
            ),
            if (textoTempoResolucao.isNotEmpty || textoPrazoResultado.isNotEmpty) ...[  // Resolução da demanda
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resolução da demanda',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: corPrazoResultado.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: corPrazoResultado, width: 1),
                    ),
                    child: Text(
                      textoTempoResolucao.isEmpty
                          ? textoPrazoResultado
                          : 'Resolvida em $textoTempoResolucao',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: corPrazoResultado,
                      ),
                    ),
                  ),
                ],
              ),
              if (textoPrazoResultado.isNotEmpty && textoTempoResolucao.isNotEmpty) ...[  // Prazo/tolerância
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: Text(
                    textoPrazoResultado,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: corPrazoResultado,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              if (textoPrazoResultado.isEmpty && textoTempoResolucao.isNotEmpty) ...[  // Apenas tempo
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: Text(
                    'Prazo da condição não informado ou indisponível',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AmeloTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
            _buildInfoRow('Data de abertura', dataAbertura, theme),
            _buildInfoRow('Previsão de conclusão', previsao, theme),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Text(
              'Descrição',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              descricao,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Observações',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              observacoes,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Anexos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildAnexoThumbnail(Icons.build_rounded, theme),
                const SizedBox(width: 8),
                _buildAnexoThumbnail(Icons.plumbing_rounded, theme),
                const SizedBox(width: 8),
                _buildAnexoThumbnail(Icons.description_rounded, theme),
                const SizedBox(width: 8),
                _buildAnexoMoreBadge('+3', theme),
              ],
            ),
            const SizedBox(height: 32),
            if (podeAvancar) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corBotaoAvancar,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _avancarStatus,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        statusRaw == 'PENDENTE'
                            ? Icons.play_arrow_rounded
                            : Icons.check_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        textoBotaoAvancar,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _editarDemanda,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 8),
                    Text(
                      'Editar Demanda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _excluirDemanda,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text(
                      'Excluir Demanda',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _obterStatusLabel(String status) {
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

  Color _obterStatusColor(String status) {
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

  Color _obterUrgenciaColor(String urgencia) {
    switch (urgencia) {
      case 'ALTA':
      case 'URGENTE':
        return AmeloTheme.statusUrgente;
      case 'MEDIA':
        return AmeloTheme.statusAndamento;
      case 'BAIXA':
        return AmeloTheme.statusConcluido;
      default:
        return AmeloTheme.textSecondary;
    }
  }

  String _obterUrgenciaLabel(String urgencia) {
    switch (urgencia) {
      case 'ALTA':
      case 'URGENTE':
        return 'Urgente';
      case 'MEDIA':
        return 'Média';
      case 'BAIXA':
        return 'Baixa';
      default:
        return urgencia;
    }
  }

  static Widget _buildInfoRow(String label, String valor, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AmeloTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatusRow(
    String label,
    String status,
    Color color,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AmeloTheme.textSecondary,
            ),
          ),
          Row(
            children: [
              Icon(Icons.circle, color: color, size: 8),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildAnexoThumbnail(IconData icone, ThemeData theme) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Icon(icone, color: AmeloTheme.textSecondary),
    );
  }

  static Widget _buildAnexoMoreBadge(String text, ThemeData theme) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
