// lib/app_routes.dart

import 'package:flutter/material.dart';

// Importação de todas as 9 views do sistema
//import 'ui/screens/';
//import 'ui/screens/home_screen.dart';
//import 'ui/screens/detalhes_demanda_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/nova_demanda_screen.dart';
import 'ui/screens/buscar_condominio_screen.dart';
import 'ui/screens/cadastrar_condominio_screen.dart';
import 'ui/screens/historico_atualizacoes_screen.dart';
import 'ui/screens/gerenciar_supervisores_screen.dart';
import 'ui/screens/gerenciar_profissionais_screen.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/demandas_condominio_screen.dart';

abstract class AppRoutes {
  // Constantes das rotas para evitar erros de digitação (magic strings)
  static const String login = '/login';
  static const String home = '/dashboard';
  static const String detalhesDemanda = '/demanda-detalhes';
  static const String novaDemanda = '/nova-demanda';
  static const String buscarCondominio = '/buscar-condominio';
  static const String cadastrarCondominio = '/cadastrar-condominio';
  static const String historicoAtualizacoes = '/historico-atualizacoes';
  static const String gerenciarSupervisores = '/gerenciar-supervisores';
  static const String gerenciarProfissionais = '/gerenciar-profissionais';
  static const String demandasCondominio = '/demandas-condominio';

  /// Mapa contendo todos os construtores de tela indexados por rota
  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    home: (context) => const DashboardScreen(),
    //detalhesDemanda: (context) => const DetalhesDemandaScreen(),
    novaDemanda: (context) => const NovaDemandaScreen(),
    buscarCondominio: (context) => const BuscarCondominioScreen(),
    cadastrarCondominio: (context) => const CadastrarCondominioScreen(),
    historicoAtualizacoes: (context) => const HistoricoAtualizacoesScreen(),
    gerenciarSupervisores: (context) => const GerenciarSupervisoresScreen(),
    gerenciarProfissionais: (context) => const GerenciarProfissionaisScreen(),
    demandasCondominio: (context) => const DemandasCondominioScreen(),
  };
}


//Faltando fazer as telas comentadas e implementar no material app