import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'router_provider.dart';

import '../repository/medico_repository.dart';
import '../repository/paciente_repository.dart';
import '../repository/protocol.dart';
import '../repository/propietario_repository.dart';
import '../repository/veterinaria_repository.dart';
import '../viewmodel/medico_viewmodel.dart';
import '../viewmodel/paciente_viewmodel.dart';
import '../viewmodel/protocolo_viewmodel.dart';
import '../viewmodel/propietario_viewmodel.dart';
import '../viewmodel/veterinaria_viewmodel.dart';

/// Construye la lista de providers para inyectar en `MultiProvider`.
List<SingleChildWidget> buildAppProviders({
  ProtocoloRepository? protocoloRepository,
  PacienteRepository? pacienteRepository,
  PropietarioRepository? propietarioRepository,
  MedicoRepository? medicoRepository,
  VeterinariaRepository? veterinariaRepository,
}) {
  return [
    ChangeNotifierProvider(
      create: (_) => ProtocoloViewModel(
        repository: protocoloRepository ?? ProtocoloRepository(),
      ),
    ),
    ChangeNotifierProvider(
      create: (_) => PacienteViewModel(
        repository: pacienteRepository ?? PacienteRepository(),
      ),
    ),
    ChangeNotifierProvider(
      create: (_) => PropietarioViewModel(
        repository: propietarioRepository ?? PropietarioRepository(),
      ),
    ),
    ChangeNotifierProvider(
      create: (_) =>
          MedicoViewModel(repository: medicoRepository ?? MedicoRepository()),
    ),
    ChangeNotifierProvider(
      create: (_) => VeterinariaViewModel(
        repository: veterinariaRepository ?? VeterinariaRepository(),
      ),
    ),
    // Proveedor del router (GoRouter) - crear al final para que otros providers
    // (viewmodels/repositorios) ya estén disponibles cuando GoRouter inicialice
    // (evita problemas si alguna ruta lee providers en su builder durante
    //  la inicialización del router).
    routerProvider,
  ];
}

/// Wrapper listo para usar alrededor de tu `MaterialApp` o widget raíz.
class AppProviderScope extends StatelessWidget {
  const AppProviderScope({
    super.key,
    required this.child,
    this.protocoloRepository,
    this.pacienteRepository,
    this.propietarioRepository,
    this.medicoRepository,
    this.veterinariaRepository,
  });

  final Widget child;
  final ProtocoloRepository? protocoloRepository;
  final PacienteRepository? pacienteRepository;
  final PropietarioRepository? propietarioRepository;
  final MedicoRepository? medicoRepository;
  final VeterinariaRepository? veterinariaRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildAppProviders(
        protocoloRepository: protocoloRepository,
        pacienteRepository: pacienteRepository,
        propietarioRepository: propietarioRepository,
        medicoRepository: medicoRepository,
        veterinariaRepository: veterinariaRepository,
      ),
      child: child,
    );
  }
}
