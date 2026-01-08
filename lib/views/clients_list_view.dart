import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/router_provider.dart';
import '../models/propietario.dart';
import '../viewmodel/propietario_viewmodel.dart';

class ClientsListView extends StatefulWidget {
  const ClientsListView({super.key});

  @override
  State<ClientsListView> createState() => _ClientsListViewState();
}

class _ClientsListViewState extends State<ClientsListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<PropietarioViewModel>().cargarTodos());
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
          'Propietarios',
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildPropietariosList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la vista de crear propietario
          context.pushNamed(RouteNames.createClient);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar propietarios...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<PropietarioViewModel>().cargarTodos();
                    setState(() {});
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty) {
            context.read<PropietarioViewModel>().buscarPorNombre(value);
          } else {
            context.read<PropietarioViewModel>().cargarTodos();
          }
        },
      ),
    );
  }

  Widget _buildPropietariosList() {
    return Consumer<PropietarioViewModel>(
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

        if (viewModel.propietarios.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 48, color: AppColors.border),
                const SizedBox(height: 12),
                Text(
                  'No hay propietarios',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: AppColors.textDark.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: viewModel.propietarios.length,
          itemBuilder: (context, index) {
            final propietario = viewModel.propietarios[index];
            return _buildPropietarioCard(context, propietario);
          },
        );
      },
    );
  }

  Widget _buildPropietarioCard(BuildContext context, Propietario propietario) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.person, color: AppColors.secondary),
          ),
        ),
        title: Text(
          propietario.nombreCompleto,
          style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (propietario.telefono != null)
              Text(
                propietario.telefono!,
                style: GoogleFonts.lato(fontSize: 12),
              ),
            if (propietario.email != null)
              Text(propietario.email!, style: GoogleFonts.lato(fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navegar a detalle del propietario
          context.pushNamed(
            RouteNames.clientDetail,
            pathParameters: {'clientId': propietario.id.toString()},
          );
        },
      ),
    );
  }
}
