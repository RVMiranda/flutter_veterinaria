import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../views/home_view.dart';
import '../views/settings_view.dart';
import '../views/clients_list_view.dart';
import '../views/client_detail_view.dart';
import '../views/patient_history_view.dart';
import '../views/create_client_view.dart';
import '../views/edit_client_view.dart';
import '../views/create_patient_view.dart';
import '../views/edit_patient_view.dart';
import '../views/create_medico_view.dart';
import '../views/protocol_edit_view.dart';
import '../views/protocol_preview_view.dart';
import '../views/all_protocols_view.dart';

/// Constantes de rutas para toda la aplicación
/// Facilita el acceso desde cualquier parte sin tener que hardcodear strings
abstract class RoutePaths {
  // Rutas principales
  static const String home = '/';
  static const String settings = '/settings';

  // Propietarios (Clientes)
  static const String clients = '/clients';
  static const String clientDetail = '/clients/:clientId';
  static const String createClient = '/clients/create';

  // Pacientes
  static const String patientHistory = '/clients/:clientId/patient/:patientId';
  static const String createPatient = '/clients/:clientId/patient/create';

  // Protocolos
  static const String protocolEdit = '/protocol/edit';
  static const String protocolPreview = '/protocol/preview';
}

/// Nombres (identificadores) de rutas usados por GoRouter
/// Se usan como 'name' en las definiciones de GoRoute
abstract class RouteNames {
  static const String home = 'home';
  static const String settings = 'settings';
  static const String clients = 'clients';
  static const String createClient = 'createClient';
  static const String editClient = 'editClient';
  static const String clientDetail = 'clientDetail';
  static const String createPatient = 'createPatient';
  static const String editPatient = 'editPatient';
  static const String patientHistory = 'patientHistory';
  static const String createMedico = 'createMedico';
  static const String protocolEdit = 'protocolEdit';
  static const String protocolPreview = 'protocolPreview';
  static const String allProtocols = 'allProtocols';
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
        name: RouteNames.home,
        builder: (context, state) {
          return const HomeView();
        },
        routes: [
          // ============ SETTINGS ============
          GoRoute(
            path: 'settings',
            name: RouteNames.settings,
            builder: (context, state) {
              return const SettingsView();
            },
            routes: [
              GoRoute(
                path: 'medicos/create',
                name: RouteNames.createMedico,
                builder: (context, state) {
                  return const CreateMedicoView();
                },
              ),
            ],
          ),

          // ============ CLIENTS / PROPIETARIOS ============
          GoRoute(
            path: 'clients',
            name: RouteNames.clients,
            builder: (context, state) {
              return const ClientsListView();
            },
            routes: [
              // Crear nuevo propietario
              GoRoute(
                path: 'create',
                name: RouteNames.createClient,
                builder: (context, state) {
                  return const CreateClientView();
                },
              ),
              // ============ CLIENT DETAIL ============
              GoRoute(
                path: ':clientId',
                name: RouteNames.clientDetail,
                builder: (context, state) {
                  final clientId = int.parse(state.pathParameters['clientId']!);
                  return ClientDetailView(clientId: clientId);
                },
                routes: [
                  // Edit propietario
                  GoRoute(
                    path: 'edit',
                    name: RouteNames.editClient,
                    builder: (context, state) {
                      final clientId = int.parse(
                        state.pathParameters['clientId']!,
                      );
                      return EditClientView(clientId: clientId);
                    },
                  ),
                  // Crear paciente para un propietario
                  GoRoute(
                    path: 'patient/create',
                    name: RouteNames.createPatient,
                    builder: (context, state) {
                      final clientId = int.parse(
                        state.pathParameters['clientId']!,
                      );
                      return CreatePatientView(clientId: clientId);
                    },
                  ),
                  // ============ PATIENT HISTORY ============
                  GoRoute(
                    path: 'patient/:patientId',
                    name: RouteNames.patientHistory,
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
                  // Edit patient
                  GoRoute(
                    path: 'patient/:patientId/edit',
                    name: RouteNames.editPatient,
                    builder: (context, state) {
                      final clientId = int.parse(
                        state.pathParameters['clientId']!,
                      );
                      final patientId = int.parse(
                        state.pathParameters['patientId']!,
                      );
                      return EditPatientView(
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
        name: RouteNames.protocolEdit,
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
        name: RouteNames.protocolPreview,
        builder: (context, state) {
          // Recibe el ID del protocolo a previsualizar
          final protocolId = int.parse(
            state.uri.queryParameters['protocolId'] ?? '0',
          );

          return ProtocolPreviewView(protocolId: protocolId);
        },
      ),

      // ============ ALL PROTOCOLS ============
      GoRoute(
        path: '/protocols',
        name: RouteNames.allProtocols,
        builder: (context, state) {
          return const AllProtocolsView();
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
