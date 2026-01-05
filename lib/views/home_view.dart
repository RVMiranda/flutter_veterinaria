import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/protocolo.dart';
import '../viewmodel/protocolo_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar todos los protocolos al iniciar
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
      appBar: _buildAppBar(),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildQuickAccessGrid(context),
            const SizedBox(height: 32),
            _buildRecentProtocolsSection(),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  // ============ AppBar ============
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Veterinaria',
        style: GoogleFonts.lato(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        ),
      ),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // Navegar a settings
            // context.pushNamed('settings');
          },
        ),
      ],
    );
  }

  // ============ Search Bar ============
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar protocolos, pacientes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty) {
            // Aquí se podría implementar búsqueda
            // context.read<ProtocoloViewModel>().buscarPorNumeroInterno(value);
          }
        },
      ),
    );
  }

  // ============ Quick Access Grid ============
  Widget _buildQuickAccessGrid(BuildContext context) {
    final quickAccessItems = [
      _QuickAccessItem(
        title: 'Nuevo Protocolo',
        icon: Icons.description_outlined,
        color: AppColors.primary,
        onTap: () {
          // context.pushNamed('protocolEdit');
        },
      ),
      _QuickAccessItem(
        title: 'Pacientes',
        icon: Icons.pets_outlined,
        color: AppColors.secondary,
        onTap: () {
          // context.pushNamed('clients');
        },
      ),
      _QuickAccessItem(
        title: 'Historial',
        icon: Icons.history_outlined,
        color: const Color(0xFF5B7C99),
        onTap: () {
          // context.pushNamed('clients');
        },
      ),
      _QuickAccessItem(
        title: 'Configuración',
        icon: Icons.settings_outlined,
        color: const Color(0xFF6B8BA3),
        onTap: () {
          // context.pushNamed('settings');
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
        children: quickAccessItems
            .map((item) => _buildQuickAccessCard(item))
            .toList(),
      ),
    );
  }

  Widget _buildQuickAccessCard(_QuickAccessItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.color.withOpacity(0.1),
                item.color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 40, color: item.color),
              const SizedBox(height: 12),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ Recent Protocols Section ============
  Widget _buildRecentProtocolsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Protocolos Recientes',
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

              if (viewModel.hasError) {
                return Center(
                  child: Text(
                    'Error: ${viewModel.error}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                );
              }

              final protocolos = viewModel.protocolos.isEmpty
                  ? <Protocolo>[]
                  : viewModel.protocolos.take(5).toList();

              if (protocolos.isEmpty) {
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
                          'No hay protocolos aún',
                          style: GoogleFonts.lato(
                            fontSize: 14,
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
                itemCount: protocolos.length,
                itemBuilder: (context, index) {
                  final protocolo = protocolos[index];
                  return _buildProtocolCard(protocolo);
                },
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProtocolCard(Protocolo protocolo) {
    final fecha = DateTime.parse(protocolo.fechaCreacion);
    final fechaFormato = '${fecha.day}/${fecha.month}/${fecha.year}';

    return Card(
      elevation: 1,
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
              protocolo.numeroInterno ?? '--',
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
          'Protocolo #${protocolo.numeroInterno}',
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
              maxLines: 1,
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
          // context.pushNamed('protocolEdit',
          //   extra: ProtocolEditParams(
          //     patientId: protocolo.pacienteId ?? 0,
          //     protocolId: protocolo.id,
          //   ),
          // );
        },
      ),
    );
  }

  // ============ FAB ============
  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // context.pushNamed('protocolEdit',
        //   extra: ProtocolEditParams(patientId: 0, protocolId: null),
        // );
      },
      child: const Icon(Icons.add),
    );
  }
}

// ============ Quick Access Item Model ============
class _QuickAccessItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _QuickAccessItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
