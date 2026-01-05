import '../data/database_helper.dart';
import '../models/veterinaria_info.dart';

/// Repository para manejar la configuración de la veterinaria
class VeterinariaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Obtener información de la veterinaria (solo debe haber un registro)
  Future<VeterinariaInfo?> obtenerInformacion() async {
    return await _dbHelper.getVeterinariaInfo();
  }

  /// Guardar o actualizar información de la veterinaria
  Future<void> guardarInformacion(VeterinariaInfo info) async {
    final existente = await _dbHelper.getVeterinariaInfo();

    if (existente == null) {
      // Crear nuevo registro
      await _dbHelper.insertVeterinariaInfo(info);
    } else {
      // Actualizar registro existente
      final infoActualizada = info.copyWith(id: existente.id);
      await _dbHelper.updateVeterinariaInfo(infoActualizada);
    }
  }

  /// Verificar si ya existe configuración
  Future<bool> existeConfiguracion() async {
    final info = await _dbHelper.getVeterinariaInfo();
    return info != null;
  }

  /// Actualizar solo el logo
  Future<void> actualizarLogo(String logoPath) async {
    final info = await _dbHelper.getVeterinariaInfo();
    if (info == null) {
      throw Exception(
        'Debe configurar primero la información de la veterinaria',
      );
    }

    final infoActualizada = info.copyWith(logoPath: logoPath);
    await _dbHelper.updateVeterinariaInfo(infoActualizada);
  }

  /// Actualizar información de contacto
  Future<void> actualizarContacto({
    String? telefonoPrincipal,
    String? telefonoUrgencias,
    String? emailContacto,
  }) async {
    final info = await _dbHelper.getVeterinariaInfo();
    if (info == null) {
      throw Exception(
        'Debe configurar primero la información de la veterinaria',
      );
    }

    final infoActualizada = info.copyWith(
      telefonoPrincipal: telefonoPrincipal ?? info.telefonoPrincipal,
      telefonoUrgencias: telefonoUrgencias ?? info.telefonoUrgencias,
      emailContacto: emailContacto ?? info.emailContacto,
    );

    await _dbHelper.updateVeterinariaInfo(infoActualizada);
  }
}
