import 'package:flutter/material.dart';
import '../../app_routes.dart';
import '../../repository/hooks/use_auth.dart';
import '../../repository/usuario_repository.dart';
import '../../repository/services/api_service.dart';
import '../../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _useAuth = UseAuth(UsuarioRepository(ApiService()));
  bool _obscurePassword = true;
  bool _isLoading = false; // Controle de carregamento seguro da tela

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔘 Botão Flutuante de Troca de Tema no Canto
                Align(
                  alignment: Alignment.topRight,
                  child: ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, mode, child) {
                      final isDark = mode == ThemeMode.dark;
                      return IconButton(
                        icon: Icon(
                          isDark
                              ? Icons.wb_sunny_rounded
                              : Icons.nightlight_round,
                          color: isDark
                              ? AmeloTheme.primaryGold
                              : AmeloTheme.primaryNavy,
                        ),
                        onPressed: () {
                          themeNotifier.value = isDark
                              ? ThemeMode.light
                              : ThemeMode.dark;
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // --- BRANCO/LOGO AMELO ---
                Icon(
                  Icons.domain_rounded,
                  size: 64,
                  color: theme.brightness == Brightness.dark
                      ? AmeloTheme.primaryGold
                      : AmeloTheme.primaryNavy,
                ),
                const SizedBox(height: 12),
                Text(
                  'AMELO',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Text(
                  'GESTOR CONDOMÍNIOS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: AmeloTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 40),

                // --- CAMPO USERNAME ---
                TextField(
                  controller: _usernameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Nome de Usuário',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // --- CAMPO SENHA ---
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // --- ESQUECEU A SENHA ---
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Esqueceu a senha?',
                      style: TextStyle(
                        color: AmeloTheme.statusAbertas,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // --- BOTÃO ENTRAR ---
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AmeloTheme.primaryNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            final username = _usernameController.text.trim();
                            final senha = _passwordController.text.trim();

                            if (username.isEmpty || senha.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Informe o nome de usuário e a senha.',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _isLoading = true;
                            });

                            final sucesso = await _useAuth.login(
                              username,
                              senha,
                            );

                            if (!mounted) return;

                            setState(() {
                              _isLoading = false;
                            });

                            if (sucesso) {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.home,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _useAuth.error ??
                                        'Falha ao realizar login.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Entrar no Painel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),

                // --- RODAPÉ DE SUPORTE ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Precisa de acesso? ',
                      style: TextStyle(
                        color: AmeloTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Fale com a administração',
                        style: TextStyle(
                          color: AmeloTheme.statusAbertas,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
