import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/router_provider.dart';
import '../models/protocolo.dart';
import '../viewmodel/paciente_viewmodel.dart';
import '../viewmodel/protocolo_viewmodel.dart';

class PatientHistoryView extends StatefulWidget {
  final int clientId;
  final int patientId;

  const PatientHistoryView({
    super.key,
    required this.clientId,
    required this.patientId,
  });

  @override
  State<PatientHistoryView> createState() => _PatientHistoryViewState();
}

class _PatientHistoryViewState extends State<PatientHistoryView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<PacienteViewModel>().cargarDetalle(widget.patientId);
        context.read<ProtocoloViewModel>().cargarPorPaciente(widget.patientId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historial del Paciente',
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
            _buildPacienteInfoSection(),
            const SizedBox(height: 32),
            _buildProtocolosSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a crear protocolo para este paciente
          context.pushNamed(
            RouteNames.protocolEdit,
            extra: ProtocolEditParams(
              patientId: widget.patientId,
              protocolId: null,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPacienteInfoSection() {
    return Consumer<PacienteViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final paciente = viewModel.seleccionado;
        if (paciente == null) {
          return const Center(child: Text('Paciente no encontrado'));
        }

        final edad = paciente.calcularEdad();
        final castradoText = paciente.castrado == 1
            ? 'Sí'
            : paciente.castrado == 0
            ? 'No'
            : 'No reportado';

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
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: Icon(Icons.pets, size: 30)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              paciente.nombre,
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              paciente.especie ?? 'Especie desconocida',
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                color: AppColors.textDark.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoGrid([
                    _buildInfoCard('Raza', paciente.raza ?? '-'),
                    _buildInfoCard('Género', paciente.genero ?? '-'),
                    _buildInfoCard('Edad', edad != null ? '$edad años' : '-'),
                    _buildInfoCard('Castrado', castradoText),
                    _buildInfoCard('Peso', '${paciente.pesoActual ?? '-'} kg'),
                    _buildInfoCard(
                      'F. Nacimiento',
                      paciente.fechaNacimiento ?? '-',
                    ),
                  ]),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navegar a editar paciente
                        context.pushNamed(
                          RouteNames.editPatient,
                          pathParameters: {
                            'clientId': widget.clientId.toString(),
                            'patientId': widget.patientId.toString(),
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

  Widget _buildInfoGrid(List<Widget> children) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: children,
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 10,
              color: AppColors.textDark.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolosSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Protocolos (Historial)',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Consumer<ProtocoloViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.protocolos.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 48,
                          color: AppColors.border,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No hay protocolos registrados',
                          style: GoogleFonts.lato(
                            color: AppColors.textDark.withValues(alpha: 0.6),
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
                itemCount: viewModel.protocolos.length,
                itemBuilder: (context, index) {
                  final protocolo = viewModel.protocolos[index];
                  return _buildProtocolCard(context, protocolo);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolCard(BuildContext context, Protocolo protocolo) {
    final fecha = DateTime.parse(protocolo.fechaCreacion);
    final fechaFormato = '${fecha.day}/${fecha.month}/${fecha.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              protocolo.numeroInterno ?? '--',
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        title: Text(
          'Protocolo #${protocolo.numeroInterno}',
          style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              protocolo.diagnosticoCitologico ?? 'Sin diagnóstico',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lato(
                fontSize: 12,
                color: AppColors.textDark.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              fechaFormato,
              style: GoogleFonts.lato(
                fontSize: 11,
                color: AppColors.textDark.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navegar a preview
          context.pushNamed(
            RouteNames.protocolPreview,
            queryParameters: {'protocolId': protocolo.id.toString()},
          );
        },
      ),
    );
  }
}
