import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/paciente.dart';
import '../viewmodel/paciente_viewmodel.dart';
import '../providers/router_provider.dart';

class EditPatientView extends StatefulWidget {
  final int clientId;
  final int patientId;

  const EditPatientView({
    super.key,
    required this.clientId,
    required this.patientId,
  });

  @override
  State<EditPatientView> createState() => _EditPatientViewState();
}

class _EditPatientViewState extends State<EditPatientView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _especieController = TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  final TextEditingController _generoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  bool _castrado = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final vm = context.read<PacienteViewModel>();
      await vm.cargarDetalle(widget.patientId);
      final paciente = vm.seleccionado;
      if (paciente != null) {
        _nombreController.text = paciente.nombre;
        _especieController.text = paciente.especie ?? '';
        _razaController.text = paciente.raza ?? '';
        _generoController.text = paciente.genero ?? '';
        _fechaController.text = paciente.fechaNacimiento ?? '';
        _pesoController.text = paciente.pesoActual?.toString() ?? '';
        _castrado = paciente.castrado == 1;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _especieController.dispose();
    _razaController.dispose();
    _generoController.dispose();
    _fechaController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final paciente = Paciente(
      id: widget.patientId,
      propietarioId: widget.clientId,
      nombre: _nombreController.text.trim(),
      especie: _especieController.text.trim().isEmpty
          ? null
          : _especieController.text.trim(),
      raza: _razaController.text.trim().isEmpty
          ? null
          : _razaController.text.trim(),
      genero: _generoController.text.trim().isEmpty
          ? null
          : _generoController.text.trim(),
      castrado: _castrado ? 1 : 0,
      fechaNacimiento: _fechaController.text.trim().isEmpty
          ? null
          : _fechaController.text.trim(),
      pesoActual: _pesoController.text.trim().isEmpty
          ? null
          : double.tryParse(_pesoController.text.trim()),
    );

    try {
      await context.read<PacienteViewModel>().actualizarPaciente(paciente);
      // Volver al historial
      // Use goNamed so we replace the current route and don't allow back to edit
      context.goNamed(
        RouteNames.patientHistory,
        pathParameters: {
          'clientId': widget.clientId.toString(),
          'patientId': widget.patientId.toString(),
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Mascota',
          style: GoogleFonts.lato(
            fontSize: 20,
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Ingrese el nombre'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _especieController,
                  decoration: const InputDecoration(labelText: 'Especie'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _razaController,
                  decoration: const InputDecoration(labelText: 'Raza'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _generoController,
                  decoration: const InputDecoration(labelText: 'Género'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fechaController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de nacimiento (YYYY-MM-DD)',
                  ),
                  onTap: () async {
                    final now = DateTime.now();
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: DateTime(1900),
                      lastDate: now,
                    );
                    if (selected != null) {
                      _fechaController.text =
                          '${selected.year.toString().padLeft(4, '0')}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pesoController,
                  decoration: const InputDecoration(labelText: 'Peso (kg)'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Castrado'),
                    const SizedBox(width: 12),
                    Switch(
                      value: _castrado,
                      onChanged: (v) => setState(() => _castrado = v),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onSave,
                        child: const Text('Guardar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => context.goNamed(RouteNames.home),
                      child: const Text('Ir al Inicio'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
