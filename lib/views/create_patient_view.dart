import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/paciente.dart';
import '../viewmodel/paciente_viewmodel.dart';
import '../providers/router_provider.dart';

class CreatePatientView extends StatefulWidget {
  final int clientId;

  const CreatePatientView({super.key, required this.clientId});

  @override
  State<CreatePatientView> createState() => _CreatePatientViewState();
}

class _CreatePatientViewState extends State<CreatePatientView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _especieController = TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  final TextEditingController _generoController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  bool _castrado = false;

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
      final id = await context.read<PacienteViewModel>().crearPaciente(
        paciente,
      );
      // Navegar al historial del paciente recién creado
      context.pushNamed(
        RouteNames.patientHistory,
        pathParameters: {
          'clientId': widget.clientId.toString(),
          'patientId': id.toString(),
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar mascota: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickDate() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrar Mascota',
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        elevation: 0,
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
                  onTap: _pickDate,
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onSave,
                    child: const Text('Guardar'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.goNamed(RouteNames.home),
                    child: const Text('Ir al Inicio'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
