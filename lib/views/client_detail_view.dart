import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/paciente.dart';
import '../viewmodel/paciente_viewmodel.dart';
import '../providers/router_provider.dart';
import '../viewmodel/propietario_viewmodel.dart';

class ClientDetailView extends StatefulWidget {
  final int clientId;

  const ClientDetailView({super.key, required this.clientId});

  @override
  State<ClientDetailView> createState() => _ClientDetailViewState();
}

class _ClientDetailViewState extends State<ClientDetailView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PropietarioViewModel>().cargarDetalle(widget.clientId);
      context.read<PacienteViewModel>().cargarPorPropietario(widget.clientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalle del Propietario',
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.goNamed(RouteNames.home),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPropietarioInfoSection(),
            const SizedBox(height: 32),
            _buildPacientesSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la vista de crear paciente para este propietario
          context.pushNamed(
            RouteNames.createPatient,
            pathParameters: {'clientId': widget.clientId.toString()},
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPropietarioInfoSection() {
    return Consumer<PropietarioViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final propietario = viewModel.seleccionado;
        if (propietario == null) {
          return const Center(child: Text('No se encontró el propietario'));
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(Icons.person, size: 30),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              propietario.nombreCompleto,
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow(
                    '📍',
                    'Dirección',
                    propietario.direccion ?? '-',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('📞', 'Teléfono', propietario.telefono ?? '-'),
                  const SizedBox(height: 12),
                  _buildInfoRow('📧', 'Email', propietario.email ?? '-'),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navegar a editar propietario
                        context.pushNamed(
                          RouteNames.editClient,
                          pathParameters: {
                            'clientId': widget.clientId.toString(),
                          },
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar Información'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String icon, String label, String value) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 12,
                color: AppColors.textDark.withOpacity(0.6),
              ),
            ),
            Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPacientesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mascotas',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Consumer<PacienteViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.pacientes.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.pets_outlined,
                          size: 48,
                          color: AppColors.border,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No hay mascotas registradas',
                          style: GoogleFonts.lato(
                            color: AppColors.textDark.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.pacientes.length,
                itemBuilder: (context, index) {
                  final paciente = viewModel.pacientes[index];
                  return _buildPacienteCard(context, paciente);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPacienteCard(BuildContext context, Paciente paciente) {
    final edad = paciente.calcularEdad();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.pets, color: AppColors.primary),
          ),
        ),
        title: Text(
          paciente.nombre,
          style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${paciente.especie ?? 'Sin especificar'} | ${edad != null ? '$edad años' : 'Edad desconocida'}',
          style: GoogleFonts.lato(fontSize: 12),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (ctx) => [
            PopupMenuItem(
              child: const Text('Editar'),
              onTap: () {
                // Navegar a editar paciente
                Future.microtask(
                  () => context.pushNamed(
                    RouteNames.editPatient,
                    pathParameters: {
                      'clientId': widget.clientId.toString(),
                      'patientId': paciente.id.toString(),
                    },
                  ),
                );
              },
            ),
            PopupMenuItem(
              child: const Text('Eliminar'),
              onTap: () async {
                // Confirmar eliminación
                Future.microtask(() async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('Confirmar'),
                      content: const Text(
                        '¿Eliminar esta mascota? Esta acción no se puede deshacer.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dCtx).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(dCtx).pop(true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      await context.read<PacienteViewModel>().eliminarPaciente(
                        paciente.id!,
                      );
                      if (!mounted) return;
                      await context
                          .read<PacienteViewModel>()
                          .cargarPorPropietario(widget.clientId);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mascota eliminada')),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al eliminar: ${e.toString()}'),
                        ),
                      );
                    }
                  }
                });
              },
            ),
          ],
        ),
        onTap: () {
          // Navegar a historial del paciente
          context.pushNamed(
            RouteNames.patientHistory,
            pathParameters: {
              'clientId': widget.clientId.toString(),
              'patientId': paciente.id.toString(),
            },
          );
        },
      ),
    );
  }
}
