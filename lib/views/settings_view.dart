import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/veterinaria_info.dart';
import '../viewmodel/veterinaria_viewmodel.dart';
import '../viewmodel/medico_viewmodel.dart';
import '../providers/router_provider.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _nombreClinicaController;
  late TextEditingController _direccionController;
  late TextEditingController _telefonoPrincipalController;
  late TextEditingController _telefonoUrgenciasController;
  late TextEditingController _emailContactoController;

  @override
  void initState() {
    super.initState();
    _nombreClinicaController = TextEditingController();
    _direccionController = TextEditingController();
    _telefonoPrincipalController = TextEditingController();
    _telefonoUrgenciasController = TextEditingController();
    _emailContactoController = TextEditingController();

    Future.microtask(() {
      final veterinariaVM = context.read<VeterinariaViewModel>();
      final medicoVM = context.read<MedicoViewModel>();
      veterinariaVM.cargarInformacion();
      medicoVM.cargarTodos();
    });
  }

  @override
  void dispose() {
    _nombreClinicaController.dispose();
    _direccionController.dispose();
    _telefonoPrincipalController.dispose();
    _telefonoUrgenciasController.dispose();
    _emailContactoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildVeterinariaInfoSection(),
            const SizedBox(height: 32),
            _buildMedicosSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildVeterinariaInfoSection() {
    return Consumer<VeterinariaViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.info != null) {
          _nombreClinicaController.text = viewModel.info!.nombreClinica;
          _direccionController.text = viewModel.info!.direccion ?? '';
          _telefonoPrincipalController.text =
              viewModel.info!.telefonoPrincipal ?? '';
          _telefonoUrgenciasController.text =
              viewModel.info!.telefonoUrgencias ?? '';
          _emailContactoController.text = viewModel.info!.emailContacto ?? '';
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información de la Veterinaria',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nombreClinicaController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la Clínica',
                          prefixIcon: Icon(Icons.business),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _direccionController,
                        decoration: const InputDecoration(
                          labelText: 'Dirección',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _telefonoPrincipalController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono Principal',
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _telefonoUrgenciasController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono Urgencias',
                          prefixIcon: Icon(Icons.phone_in_talk),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailContactoController,
                        decoration: const InputDecoration(
                          labelText: 'Email de Contacto',
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          final info = VeterinariaInfo(
                            id: viewModel.info?.id,
                            nombreClinica: _nombreClinicaController.text,
                            direccion: _direccionController.text,
                            telefonoPrincipal:
                                _telefonoPrincipalController.text,
                            telefonoUrgencias:
                                _telefonoUrgenciasController.text,
                            emailContacto: _emailContactoController.text,
                            logoPath: viewModel.info?.logoPath,
                          );
                          viewModel.guardarInformacion(info);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Información guardada'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Cambios'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMedicosSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Médicos Registrados',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Navegar a la vista para crear médico
                  context.pushNamed(RouteNames.createMedico);
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<MedicoViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.medicos.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No hay médicos registrados',
                      style: GoogleFonts.lato(
                        color: AppColors.textDark.withOpacity(0.6),
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.medicos.length,
                itemBuilder: (context, index) {
                  final medico = viewModel.medicos[index];
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
                        child: const Icon(Icons.person_outline),
                      ),
                      title: Text(medico.nombreCompleto),
                      subtitle: Text(medico.matricula ?? 'Sin matrícula'),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const Text('Editar'),
                            onTap: () {
                              // TODO: Editar médico
                            },
                          ),
                          PopupMenuItem(
                            child: const Text('Eliminar'),
                            onTap: () {
                              // TODO: Eliminar médico
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
