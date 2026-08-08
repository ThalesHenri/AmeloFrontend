// lib/ui/screens/cadastrar_condominio_screen.dart

import 'package:flutter/material.dart';
import '../../theme.dart';

class CadastrarCondominioScreen extends StatefulWidget {
  const CadastrarCondominioScreen({super.key});

  @override
  State<CadastrarCondominioScreen> createState() =>
      _CadastrarCondominioScreenState();
}

class _CadastrarCondominioScreenState extends State<CadastrarCondominioScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers mapeados diretamente para os atributos da classe Condominio
  final _nomeController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _cepController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _observacoesController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _enderecoController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _cepController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cadastrar Condomínio',
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- FOTO DO CONDOMÍNIO (Atributo: imagem) ---
              _buildLabel('Imagem da Fachada / Logo', theme),
              InkWell(
                onTap: () {
                  // Ação para selecionar imagem da galeria/câmera
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AmeloTheme.textSecondary.withOpacity(0.3),
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: AmeloTheme.primaryGold,
                        size: 36,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Clique para selecionar a imagem do condomínio',
                        style: TextStyle(
                          fontSize: 12,
                          color: AmeloTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- NOME DO CONDOMÍNIO ---
              _buildLabel('Nome do Condomínio *', theme),
              _buildTextField(
                controller: _nomeController,
                hint: 'Ex: Residencial Parque das Flores',
                theme: theme,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // --- ENDEREÇO ---
              _buildLabel('Endereço *', theme),
              _buildTextField(
                controller: _enderecoController,
                hint: 'Ex: Av. Paulista, 1000',
                theme: theme,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // --- CIDADE E ESTADO (LADO A LADO) ---
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Cidade *', theme),
                        _buildTextField(
                          controller: _cidadeController,
                          hint: 'Ex: São Paulo',
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Estado *', theme),
                        _buildTextField(
                          controller: _estadoController,
                          hint: 'Ex: SP',
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- CEP E TELEFONE ---
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('CEP', theme),
                        _buildTextField(
                          controller: _cepController,
                          hint: '00000-000',
                          keyboardType: TextInputType.number,
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Telefone', theme),
                        _buildTextField(
                          controller: _telefoneController,
                          hint: '(11) 99999-9999',
                          keyboardType: TextInputType.phone,
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- EMAIL ---
              _buildLabel('E-mail de Contato', theme),
              _buildTextField(
                controller: _emailController,
                hint: 'contato@condominio.com.br',
                keyboardType: TextInputType.emailAddress,
                theme: theme,
              ),
              const SizedBox(height: 16),

              // --- OBSERVAÇÕES ---
              _buildLabel('Observações', theme),
              _buildTextField(
                controller: _observacoesController,
                hint:
                    'Informações adicionais sobre portaria, regras de acesso, etc.',
                maxLines: 3,
                theme: theme,
              ),
              const SizedBox(height: 28),

              // --- BOTÃO DE CADASTRO ---
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Lógica de envio futuramente integrada com a API
                    }
                  },
                  child: const Text(
                    'Cadastrar Condomínio',
                    style: TextStyle(
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
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    required ThemeData theme,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
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
}
