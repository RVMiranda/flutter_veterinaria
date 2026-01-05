import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../views/home_view.dart';
import '../views/settings_view.dart';
import '../views/clients_list_view.dart';
import '../views/client_detail_view.dart';
import '../views/patient_history_view.dart';
import '../views/protocol_edit_view.dart';
import '../views/protocol_preview_view.dart';

/// Constantes de rutas para toda la aplicación
/// Facilita el acceso desde cualquier parte sin tener que hardcodear strings
abstract class RoutePaths {
  // Rutas principales
  static const String home = '/';
  static const String settings = '/settings';

  // Propietarios (Clientes)
  static const String clients = '/clients';
  static const String clientDetail = '/clients/:clientId';

  // Pacientes
  static const String patientHistory = '/clients/:clientId/patient/:patientId';

  // Protocolos
  static const String protocolEdit = '/protocol/edit';
  static const String protocolPreview = '/protocol/preview';
}

/// Class para encapsular parámetros de navegación
/// Usado para pasar datos complejos mediante 'extra'
class ProtocolEditParams {
  final int patientId;
  final int? protocolId; // null = crear nuevo, != null = editar existente

  ProtocolEditParams({required this.patientId, this.protocolId});
}

/// Proveedor de GoRouter integrado con Provider
/// Retorna una instancia configurada de GoRouter lista para usar
final routerProvider = Provider<GoRouter>(
  create: (_) => GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: true,
    routes: [
      // ============ HOME / DASHBOARD ============
      GoRoute(
        path: RoutePaths.home,
        name: 'home',
        builder: (context, state) {
          return const HomeView();
        },
        routes: [
          // ============ SETTINGS ============
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) {
              return const SettingsView();
            },
          ),

          // ============ CLIENTS / PROPIETARIOS ============
          GoRoute(
            path: 'clients',
            name: 'clients',
            builder: (context, state) {
              return const ClientsListView();
            },
            routes: [
              // ============ CLIENT DETAIL ============
              GoRoute(
                path: ':clientId',
                name: 'clientDetail',
                builder: (context, state) {
                  final clientId = int.parse(state.pathParameters['clientId']!);
                  return ClientDetailView(clientId: clientId);
                },
                routes: [
                  // ============ PATIENT HISTORY ============
                  GoRoute(
                    path: 'patient/:patientId',
                    name: 'patientHistory',
                    builder: (context, state) {
                      final clientId = int.parse(
                        state.pathParameters['clientId']!,
                      );
                      final patientId = int.parse(
                        state.pathParameters['patientId']!,
                      );
                      return PatientHistoryView(
                        clientId: clientId,
                        patientId: patientId,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ============ PROTOCOL EDIT ============
      GoRoute(
        path: RoutePaths.protocolEdit,
        name: 'protocolEdit',
        builder: (context, state) {
          // Recibe parámetros mediante 'extra'
          // extra: ProtocolEditParams(patientId: 1, protocolId: null)
          final params = state.extra as ProtocolEditParams?;
          final patientId =
              params?.patientId ??
              int.tryParse(state.uri.queryParameters['patientId'] ?? '');
          final protocolId =
              params?.protocolId ??
              (state.uri.queryParameters['protocolId'] != null
                  ? int.tryParse(state.uri.queryParameters['protocolId']!)
                  : null);

          if (patientId == null) {
            return const Placeholder(
              child: Center(child: Text('Error: patientId requerido')),
            );
          }

          return ProtocolEditView(patientId: patientId, protocolId: protocolId);
        },
      ),

      // ============ PROTOCOL PREVIEW ============
      GoRoute(
        path: RoutePaths.protocolPreview,
        name: 'protocolPreview',
        builder: (context, state) {
          // Recibe el ID del protocolo a previsualizar
          final protocolId = int.parse(
            state.uri.queryParameters['protocolId'] ?? '0',
          );

          return ProtocolPreviewView(protocolId: protocolId);
        },
      ),
    ],

    // Manejador de errores
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Ruta no encontrada: ${state.uri.path}')),
      );
    },
  ),
);

/// Extensión para facilitar navegación desde cualquier parte
/// Uso: context.pushNamed('home')
extension GoRouterExtension on BuildContext {
  void pushNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    GoRouter.of(this).pushNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  void replaceNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    GoRouter.of(this).replaceNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  void goNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    GoRouter.of(this).goNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }
}
