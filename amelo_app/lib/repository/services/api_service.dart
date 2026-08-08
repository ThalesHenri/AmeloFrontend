// lib/repository/service/api_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    const envBaseUrl = String.fromEnvironment('AMELO_API_BASE_URL');
    if (envBaseUrl.trim().isNotEmpty) {
      return envBaseUrl;
    }

    return 'http://192.168.0.161:8000/api/v1';
  }

  ApiService._();
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;

  String? _authToken;

  bool get isAuthenticated => _authToken != null && _authToken!.trim().isNotEmpty;
  String? get authToken => _authToken;

  /// Define o token JWT de autenticação para as requisições subsequentes
  void setToken(String token) {
    _authToken = token;
  }

  /// Limpa o token ao fazer logout
  void clearToken() {
    _authToken = null;
  }

  /// Retorna os cabeçalhos padrão incluindo o Bearer Token quando disponível
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  /// Requisição GET
  Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      return _processResponse(response);
    } on TimeoutException {
      throw Exception('Tempo excedido ao consultar a API. Verifique o servidor.');
    } on SocketException {
      throw Exception('Não foi possível alcançar a API. Verifique a rede.');
    }
  }

  /// Requisição POST
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      return _processResponse(response);
    } on TimeoutException {
      throw Exception('Tempo excedido ao enviar dados para a API.');
    } on SocketException {
      throw Exception('Não foi possível alcançar a API para autenticação.');
    }
  }

  /// Requisição PUT
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http
          .put(
            uri,
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      return _processResponse(response);
    } on TimeoutException {
      throw Exception('Tempo excedido na comunicação PUT com a API.');
    } on SocketException {
      throw Exception('Não foi possível alcançar a API.');
    }
  }

  /// Requisição DELETE
  Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http
          .delete(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      return _processResponse(response);
    } on TimeoutException {
      throw Exception('Tempo excedido na comunicação DELETE com a API.');
    } on SocketException {
      throw Exception('Não foi possível alcançar a API.');
    }
  }

  /// Requisição PATCH
  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http
          .patch(
            uri,
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      return _processResponse(response);
    } on TimeoutException {
      throw Exception('Tempo excedido na comunicação PATCH com a API.');
    } on SocketException {
      throw Exception('Não foi possível alcançar a API.');
    }
  }

  /// Processa o status code e decodifica o JSON retornado pela API
  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    switch (statusCode) {
      case 401:
        _instance.clearToken();
        throw Exception('Não autorizado [401]: Token inválido ou expirado.');
      case 403:
        _instance.clearToken();
        throw Exception('Acesso negado [403]: Permissão insuficiente.');
      case 404:
        throw Exception('Recurso não encontrado [404].');
      case 500:
        throw Exception('Erro interno no servidor [500].');
      default:
        throw Exception('Erro de comunicação [$statusCode]: ${response.body}');
    }
  }
}
