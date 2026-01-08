import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/router_provider.dart';
import '../viewmodel/protocolo_viewmodel.dart';
import '../viewmodel/veterinaria_viewmodel.dart';
import '../viewmodel/medico_viewmodel.dart';

class ProtocolPreviewView extends StatefulWidget {
  final int protocolId;

  const ProtocolPreviewView({super.key, required this.protocolId});

  @override
  State<ProtocolPreviewView> createState() => _ProtocolPreviewViewState();
}

class _ProtocolPreviewViewState extends State<ProtocolPreviewView> {
  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void didUpdateWidget(ProtocolPreviewView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.protocolId != widget.protocolId) {
      _cargarDatos();
    }
  }

  void _cargarDatos() {
    Future.microtask(() async {
      await context.read<ProtocoloViewModel>().cargarDetalle(widget.protocolId);
      if (!mounted) return;

      final vetVM = context.read<VeterinariaViewModel>();
      if (vetVM.info == null) {
        await vetVM.cargarInformacion();
      }

      if (!mounted) return;
      final protocolo = context.read<ProtocoloViewModel>().seleccionado;
      if (protocolo != null && protocolo.medicoRemitenteId != null) {
        final medicoVM = context.read<MedicoViewModel>();
        // Solo cargar si no es el que ya tenemos o no tenemos ninguno
        if (medicoVM.seleccionado == null ||
            medicoVM.seleccionado!.id != protocolo.medicoRemitenteId) {
          await medicoVM.cargarDetalle(protocolo.medicoRemitenteId!);
        }
      }
    });
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Protocolo'),
          content: const Text(
            '¿Está seguro que desea eliminar este protocolo? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteProtocol();
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteProtocol() async {
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      await context.read<ProtocoloViewModel>().eliminarProtocolo(
        widget.protocolId,
      );

      // Cerrar el diálogo de carga
      if (!mounted) return;
      Navigator.of(context).pop();

      // Navegar al home usando go en lugar de goNamed
      if (!mounted) return;
      GoRouter.of(context).go('/');

      // Mostrar mensaje de éxito después de navegar
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Protocolo eliminado exitosamente')),
        );
      });
    } catch (e) {
      // Cerrar el diálogo de carga
      if (!mounted) return;
      Navigator.of(context).pop();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar protocolo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vista Previa del Protocolo',
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              final protocolo = context.read<ProtocoloViewModel>().seleccionado;
              if (protocolo != null && protocolo.pacienteId != null) {
                context.pushNamed(
                  RouteNames.protocolEdit,
                  extra: ProtocolEditParams(
                    patientId: protocolo.pacienteId!,
                    protocolId: widget.protocolId,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Información no disponible para editar'),
                  ),
                );
              }
            },
            tooltip: 'Editar Protocolo',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _showDeleteConfirmation();
            },
            tooltip: 'Eliminar Protocolo',
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              GoRouter.of(context).go('/');
            },
            tooltip: 'Ir al Inicio',
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Consumer<ProtocoloViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final protocolo = viewModel.seleccionado;
          if (protocolo == null) {
            return const Center(child: Text('Protocolo no encontrado'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildProtocolInfo(protocolo),
                      const SizedBox(height: 32),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<VeterinariaViewModel>(
          builder: (context, vetVM, _) {
            final info = vetVM.info;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info?.nombreClinica ?? 'PROTOCOLO CITOLÓGICO',
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  info?.direccion ?? 'Vista Previa para Descargar/Imprimir',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: AppColors.textDark.withOpacity(0.6),
                  ),
                ),
                const Divider(height: 24),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildProtocolInfo(protocolo) {
    final fecha = DateTime.parse(protocolo.fechaCreacion);
    final fechaFormato =
        '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection('INFORMACIÓN GENERAL', [
          _buildInfoRow('Número de Protocolo', protocolo.numeroInterno ?? '-'),
          _buildInfoRow('Fecha', fechaFormato),
          protocolo.medicoRemitenteId != null
              ? Consumer<MedicoViewModel>(
                  builder: (context, medicoVM, child) {
                    final nombre =
                        medicoVM.seleccionado?.id == protocolo.medicoRemitenteId
                        ? medicoVM.seleccionado?.nombreCompleto ?? 'Cargando...'
                        : 'Cargando...';
                    return _buildInfoRow('Médico Remitente', nombre);
                  },
                )
              : _buildInfoRow('Médico Remitente', '-'),
          _buildInfoRow(
            'Edad al Momento',
            protocolo.edadAlMomento != null
                ? '${protocolo.edadAlMomento} años'
                : '-',
          ),
          _buildInfoRow(
            'Peso al Momento',
            protocolo.pesoAlMomento != null
                ? '${protocolo.pesoAlMomento} kg'
                : '-',
          ),
        ]),
        const SizedBox(height: 24),
        _buildSection('DATOS CLÍNICOS', [
          _buildInfoRow('Anamnesis', protocolo.anamnesis ?? '-'),
          _buildInfoRow('Dx. Presuntivo', protocolo.dxPresuntivo ?? '-'),
          _buildInfoRow('Tejidos Enviados', protocolo.tejidosEnviados ?? '-'),
        ]),
        const SizedBox(height: 24),
        _buildSection('MUESTRA', [
          _buildInfoRow('Sitio Anatómico', protocolo.sitioAnatomico ?? '-'),
          _buildInfoRow(
            'Método de Obtención',
            protocolo.metodoObtencion ?? '-',
          ),
          _buildInfoRow(
            'Láminas Enviadas',
            protocolo.laminasEnviadas?.toString() ?? '-',
          ),
          _buildInfoRow('Método de Fijación', protocolo.metodoFijacion ?? '-'),
        ]),
        const SizedBox(height: 24),
        _buildSection('RESULTADOS', [
          _buildInfoRow(
            'Aspecto Macroscópico',
            protocolo.aspectoMacroscopico ?? '-',
          ),
          _buildInfoRow(
            'Aspecto Microscópico',
            protocolo.aspectoMicroscopico ?? '-',
          ),
          _buildInfoRow(
            'Diagnóstico Citológico',
            protocolo.diagnosticoCitologico ?? '-',
          ),
          _buildInfoRow('Observaciones', protocolo.observaciones ?? '-'),
        ]),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 12,
                color: AppColors.textDark.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        const Divider(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Descargar PDF'),
              onPressed: () {
                // TODO: Descargar PDF
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Descargando PDF...')),
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text('Imprimir'),
              onPressed: () {
                // TODO: Imprimir
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abriendo impresora...')),
                );
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Compartir'),
              onPressed: () {
                // TODO: Compartir
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opciones de compartir...')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
