import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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
      if (mounted) {
        final veterinariaVM = context.read<VeterinariaViewModel>();
        final medicoVM = context.read<MedicoViewModel>();
        veterinariaVM.cargarInformacion();
        medicoVM.cargarTodos();
      }
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Acerca de'),
          content: const Text(
            'Aplicación móvil desarrollada con Flutter por Rafael Miranda.\n\n'
            'Para reportar algun error o si quiere ponerse en contacto, puede hacerlo mediante: rafmicr884@gmail.com \n\n'
            '© 2026 RVMiranda. Todos los Derechos Reservados, el desarrollador no se hace responsable del mal uso de la aplicación.\n\n'
            'Versión 1.0.0',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMedicoWithConfirmation(int? id) {
    if (id == null) return;
    // Usamos Future.microtask o un post frame callback para mostrar el dialogo
    // si vinimos desde un popup menu, a veces el contexto se pierde o el menu se cierra.
    // Usar el contexto del widget padre debería ser seguro.
    Future.microtask(() async {
      if (!mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dCtx) => AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text(
            '¿Está seguro de eliminar este médico? Si tiene protocolos asociados, la eliminación podría fallar o quedar incongruente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (confirm == true) {
        if (!mounted) return;
        try {
          await context.read<MedicoViewModel>().eliminarMedico(id);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Médico eliminado correctamente')),
          );
          // Recargar la lista
          context.read<MedicoViewModel>().cargarTodos();
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
        }
      }
    });
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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showAboutDialog,
          ),
        ],
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
                      Row(
                        children: [
                          if (viewModel.info?.logoPath != null &&
                              File(viewModel.info!.logoPath!).existsSync())
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(viewModel.info!.logoPath!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            const Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: Colors.grey,
                            ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                await viewModel.actualizarLogo(image.path);
                              }
                            },
                            icon: const Icon(Icons.image),
                            label: const Text("Seleccionar Logo"),
                          ),
                        ],
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
                        color: AppColors.textDark.withValues(alpha: 0.6),
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
                          color: AppColors.primary.withValues(alpha: 0.1),
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
                              context.pushNamed(
                                RouteNames.editMedico,
                                pathParameters: {
                                  'medicoId': medico.id.toString(),
                                },
                              );
                            },
                          ),
                          PopupMenuItem(
                            child: const Text('Eliminar'),
                            onTap: () {
                              _deleteMedicoWithConfirmation(medico.id);
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
