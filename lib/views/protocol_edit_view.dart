import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../viewmodel/protocolo_viewmodel.dart';
import '../viewmodel/medico_viewmodel.dart';
import '../viewmodel/paciente_viewmodel.dart';
import '../models/protocolo.dart';
import '../models/evaluacion_lesion.dart';
import '../providers/router_provider.dart';

class ProtocolEditView extends StatefulWidget {
  final int patientId;
  final int? protocolId;

  const ProtocolEditView({super.key, required this.patientId, this.protocolId});

  @override
  State<ProtocolEditView> createState() => _ProtocolEditViewState();
}

class _ProtocolEditViewState extends State<ProtocolEditView> {
  late PageController _pageController;
  int _currentPage = 0;

  // Controllers del Protocolo
  late TextEditingController _tejidosController;
  late TextEditingController _anamnesesController;
  late TextEditingController _dxPresuntivoController;
  late TextEditingController _sitioAnastomicoController;
  late TextEditingController _metodoObtencionController;
  late TextEditingController _laminasController;
  late TextEditingController _liquidoController;
  late TextEditingController _metodoFijacionController;
  late TextEditingController _aspectoMacroscopicoController;
  late TextEditingController _aspectoMicroscopicoController;
  late TextEditingController _diagnosticoCitologicoController;
  late TextEditingController _observacionesController;

  // Controllers de Evaluación de Lesión
  late TextEditingController _localizacionController;
  late TextEditingController _tamanoLargoController;
  late TextEditingController _tamanoAnchoController;
  late TextEditingController _tamanoAltoController;
  late TextEditingController _formaController;
  late TextEditingController _colorController;
  late TextEditingController _consistenciaController;
  late TextEditingController _distribucionController;
  late TextEditingController _patronCrecimientoController;
  late TextEditingController _tasaCrecimientoController;
  late TextEditingController _contornoController;
  int? _selectedMedicoId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _tejidosController = TextEditingController();
    _anamnesesController = TextEditingController();
    _dxPresuntivoController = TextEditingController();
    _sitioAnastomicoController = TextEditingController();
    _metodoObtencionController = TextEditingController();
    _laminasController = TextEditingController();
    _liquidoController = TextEditingController();
    _metodoFijacionController = TextEditingController();
    _aspectoMacroscopicoController = TextEditingController();
    _aspectoMicroscopicoController = TextEditingController();
    _diagnosticoCitologicoController = TextEditingController();
    _observacionesController = TextEditingController();

    _localizacionController = TextEditingController();
    _tamanoLargoController = TextEditingController();
    _tamanoAnchoController = TextEditingController();
    _tamanoAltoController = TextEditingController();
    _formaController = TextEditingController();
    _colorController = TextEditingController();
    _consistenciaController = TextEditingController();
    _distribucionController = TextEditingController();
    _patronCrecimientoController = TextEditingController();
    _tasaCrecimientoController = TextEditingController();
    _contornoController = TextEditingController();

    Future.microtask(() {
      if (widget.patientId == 0) {
        // Mostrar lista de pacientes para seleccionar
        context.read<PacienteViewModel>().cargarTodos();
      } else {
        context.read<PacienteViewModel>().cargarDetalle(widget.patientId);
      }

      // Cargar lista de médicos para el dropdown
      context.read<MedicoViewModel>().cargarTodos();

      if (widget.protocolId != null) {
        context.read<ProtocoloViewModel>().cargarDetalle(widget.protocolId!);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tejidosController.dispose();
    _anamnesesController.dispose();
    _dxPresuntivoController.dispose();
    _sitioAnastomicoController.dispose();
    _metodoObtencionController.dispose();
    _laminasController.dispose();
    _liquidoController.dispose();
    _metodoFijacionController.dispose();
    _aspectoMacroscopicoController.dispose();
    _aspectoMicroscopicoController.dispose();
    _diagnosticoCitologicoController.dispose();
    _observacionesController.dispose();
    _localizacionController.dispose();
    _tamanoLargoController.dispose();
    _tamanoAnchoController.dispose();
    _tamanoAltoController.dispose();
    _formaController.dispose();
    _colorController.dispose();
    _consistenciaController.dispose();
    _distribucionController.dispose();
    _patronCrecimientoController.dispose();
    _tasaCrecimientoController.dispose();
    _contornoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.protocolId == null ? 'Nuevo Protocolo' : 'Editar Protocolo',
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                _buildPacienteInfoPage(),
                _buildProtocolFormPage(),
                _buildEvaluacionLesionPage(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (index) => Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _currentPage >= index
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ['Paciente', 'Protocolo', 'Lesión'][index],
                    style: GoogleFonts.lato(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPacienteInfoPage() {
    return Consumer<PacienteViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Si estamos creando un protocolo nuevo sin patientId, mostramos lista de pacientes
        if (widget.patientId == 0) {
          final pacientes = viewModel.pacientes;
          if (pacientes.isEmpty) {
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
                      'No hay pacientes registrados',
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
            padding: const EdgeInsets.all(16),
            itemCount: pacientes.length,
            itemBuilder: (context, index) {
              final p = pacientes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(p.nombre),
                  subtitle: Text(p.especie ?? ''),
                  onTap: () async {
                    await context.read<PacienteViewModel>().cargarDetalle(
                      p.id!,
                    );
                    // Avanzar al formulario de protocolo
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              );
            },
          );
        }

        final paciente = viewModel.seleccionado;
        if (paciente == null) {
          return const Center(child: Text('Paciente no encontrado'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Información del Paciente',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildReadOnlyField('Nombre', paciente.nombre),
                    const SizedBox(height: 12),
                    _buildReadOnlyField(
                      'Especie',
                      paciente.especie ?? 'No especificada',
                    ),
                    const SizedBox(height: 12),
                    _buildReadOnlyField('Raza', paciente.raza ?? '-'),
                    const SizedBox(height: 12),
                    _buildReadOnlyField(
                      'Edad',
                      '${paciente.calcularEdad()} años',
                    ),
                    const SizedBox(height: 12),
                    _buildReadOnlyField(
                      'Peso',
                      '${paciente.pesoActual ?? '-'} kg',
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProtocolFormPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Datos del Protocolo',
          style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _anamnesesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Anamnesis',
                    hintText: 'Historia clínica del paciente...',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _dxPresuntivoController,
                  decoration: const InputDecoration(
                    labelText: 'Diagnóstico Presuntivo',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tejidosController,
                  decoration: const InputDecoration(
                    labelText: 'Tejidos Enviados',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _sitioAnastomicoController,
                  decoration: const InputDecoration(
                    labelText: 'Sitio Anatómico',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _metodoObtencionController,
                  decoration: const InputDecoration(
                    labelText: 'Método de Obtención',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _laminasController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Láminas Enviadas',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _metodoFijacionController,
                  decoration: const InputDecoration(
                    labelText: 'Método de Fijación',
                  ),
                ),
                const SizedBox(height: 12),
                // Selector de Médico remitente
                Consumer<MedicoViewModel>(
                  builder: (context, medicoVM, _) {
                    final medicos = medicoVM.medicos;
                    return DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Médico Remitente (opcional)',
                      ),
                      items: medicos
                          .map(
                            (m) => DropdownMenuItem<int>(
                              value: m.id,
                              child: Text(m.nombreCompleto),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        // Guardar selección en el estado temporal
                        setState(() {
                          _selectedMedicoId = value;
                        });
                      },
                      value: _selectedMedicoId,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEvaluacionLesionPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Evaluación de Lesión',
          style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _localizacionController,
                  decoration: const InputDecoration(labelText: 'Localización'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tamanoLargoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Largo (cm)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _tamanoAnchoController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Ancho (cm)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tamanoAltoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Alto (cm)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _formaController,
                  decoration: const InputDecoration(labelText: 'Forma'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _colorController,
                  decoration: const InputDecoration(labelText: 'Color'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _consistenciaController,
                  decoration: const InputDecoration(labelText: 'Consistencia'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 14,
            color: AppColors.textDark.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Atrás'),
            ),
          if (_currentPage < 2)
            ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Siguiente'),
            )
          else
            ElevatedButton.icon(
              onPressed: () {
                _guardarProtocolo();
              },
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
            ),
        ],
      ),
    );
  }

  void _guardarProtocolo() {
    // Construir objeto Protocolo desde los controllers
    final pacienteId = widget.patientId == 0
        ? context.read<PacienteViewModel>().seleccionado?.id
        : widget.patientId;

    if (pacienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un paciente antes de guardar'),
        ),
      );
      return;
    }

    // Obtener datos clínicos del paciente para guardar en el protocolo
    final paciente = context.read<PacienteViewModel>().seleccionado;

    final protocolo = Protocolo(
      id: widget.protocolId,
      pacienteId: pacienteId,
      medicoRemitenteId: _selectedMedicoId,
      edadAlMomento: paciente?.calcularEdad(),
      pesoAlMomento: paciente?.pesoActual,
      tejidosEnviados: _tejidosController.text.isEmpty
          ? null
          : _tejidosController.text,
      anamnesis: _anamnesesController.text.isEmpty
          ? null
          : _anamnesesController.text,
      dxPresuntivo: _dxPresuntivoController.text.isEmpty
          ? null
          : _dxPresuntivoController.text,
      sitioAnatomico: _sitioAnastomicoController.text.isEmpty
          ? null
          : _sitioAnastomicoController.text,
      metodoObtencion: _metodoObtencionController.text.isEmpty
          ? null
          : _metodoObtencionController.text,
      laminasEnviadas: int.tryParse(_laminasController.text),
      liquidoEnviadoMl: double.tryParse(_liquidoController.text),
      metodoFijacion: _metodoFijacionController.text.isEmpty
          ? null
          : _metodoFijacionController.text,
      aspectoMacroscopico: _aspectoMacroscopicoController.text.isEmpty
          ? null
          : _aspectoMacroscopicoController.text,
      aspectoMicroscopico: _aspectoMicroscopicoController.text.isEmpty
          ? null
          : _aspectoMicroscopicoController.text,
      diagnosticoCitologico: _diagnosticoCitologicoController.text.isEmpty
          ? null
          : _diagnosticoCitologicoController.text,
      observaciones: _observacionesController.text.isEmpty
          ? null
          : _observacionesController.text,
    );

    final evaluacion = EvaluacionLesion(
      localizacion: _localizacionController.text.isEmpty
          ? null
          : _localizacionController.text,
      tamanoLargo: double.tryParse(_tamanoLargoController.text),
      tamanoAncho: double.tryParse(_tamanoAnchoController.text),
      tamanoAlto: double.tryParse(_tamanoAltoController.text),
      forma: _formaController.text.isEmpty ? null : _formaController.text,
      color: _colorController.text.isEmpty ? null : _colorController.text,
      consistencia: _consistenciaController.text.isEmpty
          ? null
          : _consistenciaController.text,
      distribucion: _distribucionController.text.isEmpty
          ? null
          : _distribucionController.text,
      patronCrecimiento: _patronCrecimientoController.text.isEmpty
          ? null
          : _patronCrecimientoController.text,
      tasaCrecimiento: _tasaCrecimientoController.text.isEmpty
          ? null
          : _tasaCrecimientoController.text,
      contorno: _contornoController.text.isEmpty
          ? null
          : _contornoController.text,
    );

    // Ejecutar guardado (crear o actualizar)
    final protocoloVM = context.read<ProtocoloViewModel>();

    if (widget.protocolId == null) {
      protocoloVM
          .crearProtocolo(protocolo: protocolo, evaluacionLesion: evaluacion)
          .then((id) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Protocolo guardado exitosamente')),
            );
            // Navegar a la vista de preview del protocolo (reemplazando la ruta de edición)
            context.goNamed(
              'protocolPreview',
              queryParameters: {'protocolId': id.toString()},
            );
          })
          .catchError((err) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al guardar protocolo: $err')),
            );
          });
    } else {
      protocoloVM
          .actualizarProtocolo(
            protocolo: protocolo,
            evaluacionLesion: evaluacion,
          )
          .then((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Protocolo actualizado exitosamente'),
              ),
            );
            context.goNamed(
              'protocolPreview',
              queryParameters: {'protocolId': widget.protocolId.toString()},
            );
          })
          .catchError((err) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al actualizar protocolo: $err')),
            );
          });
    }
  }
}
