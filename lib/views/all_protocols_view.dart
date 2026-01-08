import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';
import '../models/protocolo.dart';
import '../providers/router_provider.dart';
import '../viewmodel/protocolo_viewmodel.dart';

class AllProtocolsView extends StatefulWidget {
  const AllProtocolsView({super.key});

  @override
  State<AllProtocolsView> createState() => _AllProtocolsViewState();
}

class _AllProtocolsViewState extends State<AllProtocolsView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProtocoloViewModel>().cargarTodos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Todos los Protocolos',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por número, diagnóstico...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<ProtocoloViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.hasError) {
                  return Center(child: Text('Error: ${viewModel.error}'));
                }

                // Filtrado local simple
                final protocolos = viewModel.protocolos.where((p) {
                  final numero = p.numeroInterno?.toLowerCase() ?? '';
                  final dx = p.diagnosticoCitologico?.toLowerCase() ?? '';
                  final anamnesis = p.anamnesis?.toLowerCase() ?? '';
                  return numero.contains(_searchQuery) ||
                      dx.contains(_searchQuery) ||
                      anamnesis.contains(_searchQuery);
                }).toList();

                if (protocolos.isEmpty) {
                  return Center(
                    child: Text(
                      'No se encontraron protocolos',
                      style: GoogleFonts.lato(
                        color: AppColors.textDark.withOpacity(0.6),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: protocolos.length,
                  itemBuilder: (context, index) {
                    final protocolo = protocolos[index];
                    return _buildProtocolCard(protocolo);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolCard(Protocolo protocolo) {
    final fecha = DateTime.parse(protocolo.fechaCreacion);
    final fechaFormato = '${fecha.day}/${fecha.month}/${fecha.year}';
    final numeroInterno = protocolo.numeroInterno ?? 'S/N';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              numeroInterno,
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        title: Text(
          'Protocolo #$numeroInterno',
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
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
                color: AppColors.textDark.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              fechaFormato,
              style: GoogleFonts.lato(
                fontSize: 11,
                color: AppColors.textDark.withOpacity(0.5),
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.secondary,
        ),
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
