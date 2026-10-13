// lib/repository/service/api_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    const envBaseUrl = String.fromEnvironment('AMELO_API_BASE_URL');
    if (envBaseUrl.trim().isNotEmpty) {
      return envBaseUrl;
    }
    return 'https://amelo-api.com.br/api/v1';
  }

  ApiService._();
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;

  String? _authToken;
  String? _refreshToken; // Guardará a chave de renovação
  String? _userRole; // Guardará a role do usuário
  bool _isRefreshing = false;
  bool _senhaRedefinida = false;

  bool get isAuthenticated =>
      _authToken != null && _authToken!.trim().isNotEmpty;
  String? get authToken => _authToken;
  String? get userRole => _userRole;
  bool get isGestor => _userRole == 'GESTOR';
  bool get isSupervisor => _userRole == 'SUPERVISOR';
  bool get senhaRedefinida => _senhaRedefinida;

  /// Define os tokens JWT obtidos no login
  void setTokens({required String accessToken, String? refreshToken}) {
    _authToken = accessToken;
    if (refreshToken != null) {
      _refreshToken = refreshToken;
    }
  }

  void setUserRole(String? role) {
    _userRole = role;
  }

  void setSenhaRedefinida(bool redefinida) {
    _senhaRedefinida = redefinida;
  }

  /// Manter o setToken antigo por compatibilidade
  void setToken(String token) {
    _authToken = token;
  }

  /// Limpa os tokens ao fazer logout
  void clearToken() {
    _authToken = null;
    _refreshToken = null;
    _userRole = null;
    _senhaRedefinida = false;
  }

  /// Retorna os cabeçalhos padrão incluindo o Bearer Token
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Função interna que tenta renovar o Access Token usando o Refresh Token
  Future<bool> _tentarRenovarToken() async {
    if (_refreshToken == null || _isRefreshing) return false;

    _isRefreshing = true;

    try {
      final uri = Uri.parse('$baseUrl/token/refresh/');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh': _refreshToken}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['access'];
        _isRefreshing = false;
        return true;
      }
    } catch (_) {
      // Falha ao renovar
    }

    _isRefreshing = false;
    clearToken(); // Se a renovação falhar, limpa tudo de vez
    return false;
  }

  /// Encapsulador generico para executar chamadas com tentativa de Auto-Refresh
  Future<dynamic> _executarComRetry(
    Future<http.Response> Function() chamadaHttp, {
    required String metodo,
    required Uri uri,
    bool decodeResponseBody = true,
  }) async {
    final endpointAuth =
        uri.path.endsWith('/auth/token/') || uri.path.endsWith('/auth/me/');
    final contextoRequisicao =
        '$metodo ${uri.replace(query: null, fragment: null)}';

    try {
      if (uri.path.endsWith('/auth/me/')) {
        _registrarEnvioAuth(metodo, uri, tentativa: 1);
      }
      final response = await chamadaHttp().timeout(const Duration(seconds: 10));
      if (endpointAuth) {
        _registrarRespostaAuth(metodo, uri, response, tentativa: 1);
      }

      // Se der 401, tenta renovar o token e repetir a requisição UMA vez
      if (response.statusCode == 401 && _refreshToken != null) {
        final renovou = await _tentarRenovarToken();
        if (renovou) {
          if (uri.path.endsWith('/auth/me/')) {
            _registrarEnvioAuth(metodo, uri, tentativa: 2);
          }
          final retryResponse = await chamadaHttp().timeout(
            const Duration(seconds: 10),
          );
          if (endpointAuth) {
            _registrarRespostaAuth(metodo, uri, retryResponse, tentativa: 2);
          }
          return _processResponse(
            retryResponse,
            contexto: contextoRequisicao,
            decodeBody: decodeResponseBody,
          );
        }
      }

      return _processResponse(
        response,
        contexto: contextoRequisicao,
        decodeBody: decodeResponseBody,
      );
    } on TimeoutException {
      throw Exception('Tempo excedido na comunicação com a API.');
    } on SocketException {
      throw Exception('Não foi possível alcançar a API. Verifique a rede.');
    }
  }

  /// Confirma apenas se o Bearer será enviado; nunca registra o token.
  void _registrarEnvioAuth(String metodo, Uri uri, {required int tentativa}) {
    final tokenPresente = _authToken?.trim().isNotEmpty == true;
    final endpoint = uri.replace(query: null, fragment: null);
    debugPrint(
      '[Amelo.Api.Auth] '
      '$metodo $endpoint (tentativa $tentativa): '
      'Authorization Bearer ${tokenPresente ? 'configurado' : 'ausente'}; '
      'token não registrado.',
    );
  }

  /// Registra diagnóstico de login/perfil sem expor credenciais ou tokens.
  void _registrarRespostaAuth(
    String metodo,
    Uri uri,
    http.Response response, {
    required int tentativa,
  }) {
    final endpoint = uri.replace(query: null, fragment: null);
    final contexto = '$metodo $endpoint (tentativa $tentativa)';

    if (response.statusCode >= 200 && response.statusCode < 300) {
      debugPrint(
        '[Amelo.Api.Auth] '
        '$contexto -> HTTP ${response.statusCode}; corpo omitido.',
      );
      return;
    }

    debugPrint(
      '[Amelo.Api.Auth] '
      '$contexto -> HTTP ${response.statusCode}; '
      'resposta: ${_respostaAuthSegura(response.body)}',
    );
  }

  String _respostaAuthSegura(String body) {
    if (body.isEmpty) return '<vazia>';

    try {
      final decoded = jsonDecode(body);
      final sanitized = _ocultarSegredos(decoded);
      final encoded = jsonEncode(sanitized);
      return encoded.length <= 2000
          ? encoded
          : '${encoded.substring(0, 2000)}… <truncada>';
    } on FormatException {
      // Respostas não JSON podem ecoar dados enviados; não as registramos.
      return '<resposta não JSON omitida; ${body.length} caracteres>';
    }
  }

  dynamic _ocultarSegredos(dynamic value) {
    const chavesSensiveis = {
      'password',
      'senha',
      'access',
      'refresh',
      'token',
      'authorization',
      'secret',
      'credential',
      'username',
      'email',
    };

    if (value is Map) {
      return value.map((key, nestedValue) {
        final normalizedKey = key.toString().toLowerCase();
        final sensitive = chavesSensiveis.any(normalizedKey.contains);
        return MapEntry(
          key.toString(),
          sensitive ? '<oculto>' : _ocultarSegredos(nestedValue),
        );
      });
    }
    if (value is List) {
      return value.map(_ocultarSegredos).toList();
    }
    return value;
  }

  /// Requisição GET
  Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return _executarComRetry(
      () => http.get(uri, headers: _headers),
      metodo: 'GET',
      uri: uri,
    );
  }

  /// Requisição POST
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool decodeResponseBody = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return _executarComRetry(
      () => http.post(uri, headers: _headers, body: jsonEncode(body)),
      metodo: 'POST',
      uri: uri,
      decodeResponseBody: decodeResponseBody,
    );
  }

  /// Requisição PUT
  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool decodeResponseBody = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return _executarComRetry(
      () => http.put(uri, headers: _headers, body: jsonEncode(body)),
      metodo: 'PUT',
      uri: uri,
      decodeResponseBody: decodeResponseBody,
    );
  }

  /// Requisição PATCH
  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return _executarComRetry(
      () => http.patch(uri, headers: _headers, body: jsonEncode(body)),
      metodo: 'PATCH',
      uri: uri,
    );
  }

  /// Requisição DELETE
  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return _executarComRetry(
      () => http.delete(uri, headers: _headers),
      metodo: 'DELETE',
      uri: uri,
    );
  }

  /// Redefine a senha do usuário autenticado
  Future<dynamic> redefinirSenha({
    required String senhaAtual,
    required String novaSenha,
    required String confirmarSenha,
  }) async {
    const endpoint = '/auth/redefinir-senha/';
    final uri = Uri.parse('$baseUrl$endpoint');
    final resposta = await _executarComRetry(
      () => http.post(
        uri,
        headers: _headers,
        body: jsonEncode({
          'senha_atual': senhaAtual,
          'nova_senha': novaSenha,
          'confirmar_senha': confirmarSenha,
        }),
      ),
      metodo: 'POST',
      uri: uri,
    );
    _senhaRedefinida = true;
    return resposta;
  }

  /// Processa o status code e decodifica o JSON retornado pela API
  dynamic _processResponse(
    http.Response response, {
    String? contexto,
    bool decodeBody = true,
  }) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (!decodeBody) return null;
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } on FormatException catch (error) {
        final contentType = response.headers['content-type'] ?? 'não informado';
        final offset = error.offset?.toString() ?? 'desconhecido';
        throw FormatException(
          'A API retornou uma resposta que não é JSON válido '
          '(HTTP $statusCode, Content-Type: $contentType, '
          '${response.body.length} caracteres; erro próximo ao caractere '
          '$offset). O conteúdo da resposta foi omitido.',
        );
      }
    }

    switch (statusCode) {
      case 401:
        clearToken();
        if (contexto != null) {
          throw Exception(
            'Não autorizado [401] em $contexto: '
            '${_respostaAuthSegura(response.body)}',
          );
        }
        throw Exception('Não autorizado [401]: Token inválido ou expirado.');
      case 403:
        clearToken();
        throw Exception('Acesso negado [403]: Permissão insuficiente.');
      case 404:
        throw Exception('Recurso não encontrado [404].');
      case 500:
        throw Exception('Erro interno no servidor [500].');
      default:
        throw Exception(
          'Erro de comunicação [$statusCode]: ${_mensagemErro(response)}',
        );
    }
  }

  String _mensagemErro(http.Response response) {
    if (response.body.isEmpty) return 'Resposta vazia do servidor.';

    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return data.entries
            .map((entry) {
              final valor = entry.value;
              if (valor is List) return '${entry.key}: ${valor.join(', ')}';
              return '${entry.key}: $valor';
            })
            .join(' | ');
      }
      return data.toString();
    } on FormatException {
      return response.body;
    }
  }
}
