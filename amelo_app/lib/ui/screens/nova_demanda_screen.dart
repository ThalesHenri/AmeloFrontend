// lib/ui/screens/nova_demanda_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../repository/condominio_repository.dart';
import '../../repository/models/condominio_model.dart';
import '../../repository/models/profissional_model.dart';
import '../../repository/profissional_repository.dart';
import '../../repository/demanda_repository.dart';
import '../../repository/services/api_service.dart';
import '../../theme.dart';

class NovaDemandaScreen extends StatefulWidget {
  const NovaDemandaScreen({super.key});

  @override
  State<NovaDemandaScreen> createState() => _NovaDemandaScreenState();
}

class _NovaDemandaScreenState extends State<NovaDemandaScreen> {
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _observacoesController = TextEditingController();

  final _condominioRepository = CondominioRepository(ApiService());
  final _profissionalRepository = ProfissionalRepository(ApiService());
  final _demandaRepository = DemandaRepository(ApiService());
  final _imagePicker = ImagePicker();
  final List<XFile> _fotosSelecionadas = [];

  bool _isUrgente = true;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isEditing = false;
  bool _initDone = false;
  String? _error;

  bool get _podeEditarTudo => true;

  String _statusSelecionado = 'PENDENTE';
  DateTime? _previsaoConclusao;

  final List<Map<String, String>> _statusOpcoes = [
    {'value': 'PENDENTE', 'label': 'Pendente'},
    {'value': 'EM_ANDAMENTO', 'label': 'Em Andamento'},
    {'value': 'CONCLUIDA', 'label': 'Concluída'},
  ];

  List<CondominioModel> _condominios = [];
  List<ProfissionalModel> _profissionais = [];

  int? _demandaId;
  String? _condominioSelecionado;
  int? _condominioIdSelecionado;
  int? _profissionalIdSelecionado;
  int _fotosExistentes = 0;

  static const int _maxFotosPorDemanda = 5;
  static const int _maxFotoBytes = 100 * 1024 * 1024;
  static const Set<String> _extensoesPermitidas = {
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  };

  int? _toInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    return int.tryParse(val.toString());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initDone) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        if (args.containsKey('demanda')) {
          final demanda = args['demanda'] as Map<String, dynamic>;
          _isEditing = true;
          _demandaId = _toInt(demanda['id']);
          final anexos = demanda['anexos'];
          _fotosExistentes = anexos is List
              ? anexos
                    .where((anexo) => anexo is Map && anexo['isFoto'] == true)
                    .length
              : 0;

          _tituloController.text = demanda['titulo'] as String? ?? '';
          _descricaoController.text = demanda['descricao'] as String? ?? '';
          _observacoesController.text = demanda['observacoes'] as String? ?? '';

          _statusSelecionado = demanda['status'] as String? ?? 'PENDENTE';

          // 👇 NOVO: carrega previsão existente ao editar
          final previsaoRaw = demanda['previsaoConclusao'] as String?;
          if (previsaoRaw != null) {
            _previsaoConclusao = DateTime.tryParse(previsaoRaw)?.toLocal();
          }

          final urgenciaRaw = (demanda['urgencia'] as String? ?? 'NAO_URGENTE')
              .toUpperCase();
          _isUrgente = (urgenciaRaw == 'ALTA' || urgenciaRaw == 'URGENTE');

          if (demanda['condominio'] is Map) {
            _condominioIdSelecionado = _toInt(demanda['condominio']['id']);
            _condominioSelecionado = demanda['condominio']['nome'] as String?;
          } else {
            _condominioIdSelecionado = _toInt(demanda['condominio']);
          }

          final prof =
              demanda['profissional_acionado'] ??
              demanda['profissionalAcionado'];
          if (prof is Map) {
            _profissionalIdSelecionado = _toInt(prof['id']);
          } else {
            _profissionalIdSelecionado = _toInt(prof);
          }
        } else if (args.containsKey('condominio')) {
          final cond = args['condominio'] as Map<String, dynamic>;
          final condId = _toInt(cond['id']);
          final condNome = cond['nome'] as String?;

          if (condId != null) {
            _condominioIdSelecionado = condId;
            _condominioSelecionado = condNome;
          }
        }
      }
      _initDone = true;
      _carregarOpcoes();
    }
  }

  Future<void> _carregarOpcoes() async {
    try {
      final dados = await Future.wait([
        _condominioRepository.listarTodos(),
        _profissionalRepository.listarTodos(),
      ]);

      if (!mounted) return;

      final rawConds = dados[0] as List<CondominioModel>;
      final rawProfs = dados[1] as List<ProfissionalModel>;

      final Map<int, CondominioModel> condMap = {};
      for (var c in rawConds) {
        condMap[c.id] = c;
      }
      final conds = condMap.values.toList();

      final Map<int, ProfissionalModel> profMap = {};
      for (var p in rawProfs) {
        profMap[p.id] = p;
      }
      final profs = profMap.values.toList();

      setState(() {
        _condominios = conds;
        _profissionais = profs;

        if (_condominioIdSelecionado != null) {
          final matches = _condominios.where(
            (c) => c.id == _condominioIdSelecionado,
          );
          if (matches.isNotEmpty) {
            _condominioSelecionado = matches.first.nome;
          } else if (_condominios.isNotEmpty) {
            _condominioIdSelecionado = _condominios.first.id;
            _condominioSelecionado = _condominios.first.nome;
          }
        } else if (_condominios.isNotEmpty) {
          _condominioIdSelecionado = _condominios.first.id;
          _condominioSelecionado = _condominios.first.nome;
        }

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

  Future<void> _selecionarPrevisao() async {
    final agora = DateTime.now();
    final hoje = DateUtils.dateOnly(agora);
    final previsaoAtual = _previsaoConclusao == null
        ? null
        : DateUtils.dateOnly(_previsaoConclusao!);
    final dataMinima = previsaoAtual != null && previsaoAtual.isBefore(hoje)
        ? previsaoAtual
        : hoje;
    final limitePadrao = DateUtils.dateOnly(
      agora.add(const Duration(days: 365)),
    );
    final dataMaxima =
        previsaoAtual != null && previsaoAtual.isAfter(limitePadrao)
        ? previsaoAtual
        : limitePadrao;
    final dataEscolhida = await showDatePicker(
      context: context,
      initialDate:
          previsaoAtual ??
          DateUtils.dateOnly(agora.add(const Duration(days: 3))),
      firstDate: dataMinima,
      lastDate: dataMaxima,
    );
    if (dataEscolhida == null || !mounted) return;

    final horaEscolhida = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_previsaoConclusao ?? agora),
    );
    if (horaEscolhida == null || !mounted) return;

    setState(() {
      _previsaoConclusao = DateTime(
        dataEscolhida.year,
        dataEscolhida.month,
        dataEscolhida.day,
        horaEscolhida.hour,
        horaEscolhida.minute,
      );
    });
  }

  Future<void> _selecionarFotos(ImageSource origem) async {
    final disponiveis =
        _maxFotosPorDemanda - _fotosExistentes - _fotosSelecionadas.length;
    if (disponiveis <= 0) {
      _mostrarMensagem('Esta demanda já atingiu o limite de 5 fotos.');
      return;
    }

    final List<XFile> selecionadas;
    if (origem == ImageSource.gallery) {
      selecionadas = await _imagePicker.pickMultiImage();
    } else {
      final foto = await _imagePicker.pickImage(source: ImageSource.camera);
      selecionadas = foto == null ? [] : [foto];
    }
    if (!mounted || selecionadas.isEmpty) return;

    final aceitas = <XFile>[];
    var motivoRecusa = '';
    for (final foto in selecionadas) {
      final extensao = '.${foto.name.split('.').last.toLowerCase()}';
      if (!_extensoesPermitidas.contains(extensao)) {
        motivoRecusa = 'Use imagens JPG, JPEG, PNG ou WEBP.';
        continue;
      }
      if (await foto.length() > _maxFotoBytes) {
        motivoRecusa = 'Cada foto pode ter no máximo 100 MB.';
        continue;
      }
      if (aceitas.length >= disponiveis) {
        motivoRecusa = 'O limite desta demanda é de 5 fotos.';
        continue;
      }
      aceitas.add(foto);
    }

    if (!mounted) return;
    setState(() => _fotosSelecionadas.addAll(aceitas));
    if (motivoRecusa.isNotEmpty) _mostrarMensagem(motivoRecusa);
  }

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Widget _buildSeletorFotos(ThemeData theme) {
    final totalFotos = _fotosExistentes + _fotosSelecionadas.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          'Fotos da demanda ($totalFotos/$_maxFotosPorDemanda)',
          theme,
        ),
        if (_fotosSelecionadas.isNotEmpty)
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _fotosSelecionadas.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final foto = _fotosSelecionadas[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(foto.path),
                        width: 84,
                        height: 84,
                        cacheWidth: 168,
                        cacheHeight: 168,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: IconButton(
                        constraints: const BoxConstraints.tightFor(
                          width: 28,
                          height: 28,
                        ),
                        padding: EdgeInsets.zero,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () =>
                            setState(() => _fotosSelecionadas.removeAt(index)),
                        icon: const Icon(Icons.close, size: 18),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : () => _selecionarFotos(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Galeria'),
            ),
            OutlinedButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : () => _selecionarFotos(ImageSource.camera),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Câmera'),
            ),
          ],
        ),
        Text(
          'JPG, PNG ou WEBP · até 100 MB por foto',
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Demanda' : 'Nova Demanda',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_podeEditarTudo) ...[
                    _buildLabel('Condomínio', theme),
                    _buildDropdownCondominio(
                      hint: 'Selecione o condomínio',
                      value: _condominioIdSelecionado,
                      items: _condominios,
                      onChanged: (id) {
                        setState(() {
                          _condominioIdSelecionado = id;
                          if (id != null && _condominios.isNotEmpty) {
                            final matches = _condominios.where(
                              (c) => c.id == id,
                            );
                            if (matches.isNotEmpty) {
                              _condominioSelecionado = matches.first.nome;
                            }
                          }
                        });
                      },
                      theme: theme,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Título da demanda', theme),
                    _buildTextField(
                      controller: _tituloController,
                      hint: 'Digite o título',
                      theme: theme,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Descrição da demanda', theme),
                    _buildTextField(
                      controller: _descricaoController,
                      hint: 'Descreva a demanda detalhadamente',
                      maxLines: 3,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    _buildLabel('Condomínio', theme),
                    Text(
                      _condominioSelecionado ?? '—',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Título da demanda', theme),
                    Text(
                      _tituloController.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_isEditing) ...[
                    _buildLabel('Status da demanda', theme),
                    _buildDropdownStatus(theme),
                    const SizedBox(height: 16),
                  ],

                  if (_podeEditarTudo) ...[
                    _buildLabel('Urgência', theme),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isUrgente
                                  ? AmeloTheme.statusUrgente
                                  : theme.colorScheme.surface,
                              foregroundColor: _isUrgente
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                              elevation: _isUrgente ? 2 : 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => setState(() => _isUrgente = true),
                            icon: Icon(
                              Icons.error_outline_rounded,
                              size: 18,
                              color: _isUrgente
                                  ? Colors.white
                                  : AmeloTheme.statusUrgente,
                            ),
                            label: const Text(
                              'Urgente',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: !_isUrgente
                                  ? theme.colorScheme.surface
                                  : Colors.transparent,
                              foregroundColor: !_isUrgente
                                  ? theme.colorScheme.onSurface
                                  : AmeloTheme.textSecondary,
                              side: BorderSide(
                                color: theme.dividerColor.withOpacity(0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => setState(() => _isUrgente = false),
                            child: const Text('Não urgente'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Previsão de conclusão', theme),
                    InkWell(
                      onTap: _selecionarPrevisao,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.dividerColor.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 18,
                              color: AmeloTheme.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _previsaoConclusao != null
                                    ? '${_previsaoConclusao!.day.toString().padLeft(2, '0')}/'
                                          '${_previsaoConclusao!.month.toString().padLeft(2, '0')}/'
                                          '${_previsaoConclusao!.year} às '
                                          '${_previsaoConclusao!.hour.toString().padLeft(2, '0')}:'
                                          '${_previsaoConclusao!.minute.toString().padLeft(2, '0')}'
                                    : 'Selecione a data e o horário previstos',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _previsaoConclusao != null
                                      ? theme.colorScheme.onSurface
                                      : AmeloTheme.textSecondary,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: AmeloTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  _buildLabel('Profissional acionado', theme),
                  _buildDropdownProfissional(
                    hint: 'Selecione o profissional',
                    value: _profissionalIdSelecionado,
                    items: _profissionais,
                    onChanged: (id) =>
                        setState(() => _profissionalIdSelecionado = id),
                    theme: theme,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Observações (opcional)', theme),
                  _buildTextField(
                    controller: _observacoesController,
                    hint: 'Adicione observações',
                    maxLines: 2,
                    theme: theme,
                  ),
                  const SizedBox(height: 24),
                  _buildSeletorFotos(theme),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AmeloTheme.primaryNavy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _salvar,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isEditing
                                  ? 'Salvar Alterações'
                                  : 'Salvar Demanda',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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

  Future<void> _salvar() async {
    final estavaCriando = !_isEditing;
    if (_podeEditarTudo) {
      if (_condominioIdSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione um condomínio.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      if (_tituloController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informe o título da demanda.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      if (_descricaoController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informe a descrição da demanda.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final Map<String, dynamic> payload = _podeEditarTudo
          ? {
              'condominio': _condominioIdSelecionado,
              'titulo': _tituloController.text.trim(),
              'descricao': _descricaoController.text.trim(),
              'urgencia': _isUrgente ? 'URGENTE' : 'NAO_URGENTE',
              if (_isEditing) 'status': _statusSelecionado,
              'previsaoConclusao': _previsaoConclusao?.toIso8601String(),
              'observacoes': _observacoesController.text.trim(),
              'profissional_acionado': _profissionalIdSelecionado,
              'profissionalAcionado': _profissionalIdSelecionado,
            }
          : {
              'status': _statusSelecionado,
              'observacoes': _observacoesController.text.trim(),
              'profissional_acionado': _profissionalIdSelecionado,
              'profissionalAcionado': _profissionalIdSelecionado,
            };

      int? demandaId = _demandaId;
      if (_isEditing && demandaId != null) {
        await ApiService().patch('/demandas/$demandaId/', payload);
      } else {
        final criada = await _demandaRepository.criar(payload);
        demandaId = criada.id;
        if (mounted) {
          setState(() {
            _demandaId = demandaId;
            _isEditing = true;
          });
        }
      }

      var fotosEnviadas = 0;
      final fotosParaEnviar = List<XFile>.of(_fotosSelecionadas);
      try {
        for (final foto in fotosParaEnviar) {
          await ApiService().postFile(
            '/anexos/',
            filePath: foto.path,
            fields: {'demanda': '$demandaId'},
          );
          fotosEnviadas++;
          if (mounted) {
            setState(() {
              _fotosExistentes++;
              _fotosSelecionadas.remove(foto);
            });
          }
        }
      } catch (e) {
        throw Exception(
          'Demanda salva, mas somente $fotosEnviadas de '
          '${fotosParaEnviar.length} fotos foram enviadas. '
          'Tente salvar novamente ou reabra os detalhes da demanda. $e',
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !estavaCriando
                ? 'Demanda atualizada com sucesso.'
                : 'Demanda criada com sucesso.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildDropdownStatus(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _statusSelecionado,
          dropdownColor: theme.colorScheme.surface,
          items: _statusOpcoes.map((opcao) {
            return DropdownMenuItem<String>(
              value: opcao['value'],
              child: Text(
                opcao['label']!,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
          onChanged: (novoStatus) {
            if (novoStatus != null) {
              setState(() => _statusSelecionado = novoStatus);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    required ThemeData theme,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AmeloTheme.textSecondary,
          fontSize: 13,
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
      ),
    );
  }

  Widget _buildDropdownCondominio({
    required String hint,
    required int? value,
    required List<CondominioModel> items,
    required ValueChanged<int?> onChanged,
    required ThemeData theme,
  }) {
    final exists = items.any((c) => c.id == value);
    final selectedValue = exists ? value : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          hint: Text(
            hint,
            style: const TextStyle(
              color: AmeloTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          value: selectedValue,
          dropdownColor: theme.colorScheme.surface,
          items: items.map((item) {
            return DropdownMenuItem<int>(
              value: item.id,
              child: Text(
                item.nome,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDropdownProfissional({
    required String hint,
    required int? value,
    required List<ProfissionalModel> items,
    required ValueChanged<int?> onChanged,
    required ThemeData theme,
  }) {
    final exists = items.any((p) => p.id == value);
    final selectedValue = exists ? value : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          hint: Text(
            hint,
            style: const TextStyle(
              color: AmeloTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          value: selectedValue,
          dropdownColor: theme.colorScheme.surface,
          items: items.map((item) {
            return DropdownMenuItem<int>(
              value: item.id,
              child: Text(
                '${item.nome} • ${item.especialidade}',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
