import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/medico.dart';
import '../viewmodel/medico_viewmodel.dart';
import '../providers/router_provider.dart';

class CreateMedicoView extends StatefulWidget {
  const CreateMedicoView({super.key});

  @override
  State<CreateMedicoView> createState() => _CreateMedicoViewState();
}

class _CreateMedicoViewState extends State<CreateMedicoView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _matriculaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final medico = Medico(
      nombreCompleto: _nombreController.text.trim(),
      matricula: _matriculaController.text.trim().isEmpty
          ? null
          : _matriculaController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
    );

    try {
      await context.read<MedicoViewModel>().crearMedico(medico);
      // Volver a settings
      context.goNamed(RouteNames.settings);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar médico: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agregar Médico',
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
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ingrese el nombre' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _matriculaController,
                decoration: const InputDecoration(labelText: 'Matrícula'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
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
    );
  }
}
