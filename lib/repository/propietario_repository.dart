import '../data/database_helper.dart';
import '../models/propietario.dart';

/// Repository para manejar la lógica de negocio de propietarios
class PropietarioRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Guardar un propietario
  Future<int> guardarPropietario(Propietario propietario) async {
    // Validar que no exista duplicado por email (si tiene email)
    if (propietario.email != null && propietario.email!.isNotEmpty) {
      final propietarios = await _dbHelper.getAllPropietarios();
      final duplicado = propietarios.any(
        (p) =>
            p.email?.toLowerCase() == propietario.email?.toLowerCase() &&
            p.id != propietario.id,
      );

      if (duplicado) {
        throw Exception('Ya existe un propietario con ese email');
      }
    }

    return await _dbHelper.insertPropietario(propietario);
  }

  /// Actualizar propietario
  Future<void> actualizarPropietario(Propietario propietario) async {
    if (propietario.id == null) {
      throw Exception('El propietario debe tener un ID');
    }

    // Validar email único
    if (propietario.email != null && propietario.email!.isNotEmpty) {
      final propietarios = await _dbHelper.getAllPropietarios();
      final duplicado = propietarios.any(
        (p) =>
            p.email?.toLowerCase() == propietario.email?.toLowerCase() &&
            p.id != propietario.id,
      );

      if (duplicado) {
        throw Exception('Ya existe un propietario con ese email');
      }
    }

    await _dbHelper.updatePropietario(propietario);
  }

  /// Eliminar propietario
  Future<void> eliminarPropietario(int id) async {
    // Verificar que no tenga pacientes asociados
    final pacientes = await _dbHelper.getPacientesByPropietario(id);
    if (pacientes.isNotEmpty) {
      throw Exception(
        'No se puede eliminar el propietario porque tiene ${pacientes.length} paciente(s) asociado(s)',
      );
    }

    await _dbHelper.deletePropietario(id);
  }

  /// Obtener un propietario por ID
  Future<Propietario?> obtenerPropietarioPorId(int id) async {
    return await _dbHelper.getPropietarioById(id);
  }

  /// Obtener todos los propietarios
  Future<List<Propietario>> obtenerTodosPropietarios() async {
    return await _dbHelper.getAllPropietarios();
  }

  /// Buscar propietarios por nombre
  Future<List<Propietario>> buscarPorNombre(String nombre) async {
    final propietarios = await _dbHelper.getAllPropietarios();
    return propietarios
        .where(
          (p) => p.nombreCompleto.toLowerCase().contains(nombre.toLowerCase()),
        )
        .toList();
  }

  /// Obtener propietario con sus pacientes
  Future<Map<String, dynamic>?> obtenerPropietarioConPacientes(int id) async {
    final propietario = await _dbHelper.getPropietarioById(id);
    if (propietario == null) return null;

    final pacientes = await _dbHelper.getPacientesByPropietario(id);

    return {
      'propietario': propietario,
      'pacientes': pacientes,
      'total_pacientes': pacientes.length,
    };
  }

  /// Buscar propietario por email
  Future<Propietario?> buscarPorEmail(String email) async {
    final propietarios = await _dbHelper.getAllPropietarios();
    try {
      return propietarios.firstWhere(
        (p) => p.email?.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Buscar propietario por teléfono
  Future<Propietario?> buscarPorTelefono(String telefono) async {
    final propietarios = await _dbHelper.getAllPropietarios();
    try {
      return propietarios.firstWhere((p) => p.telefono == telefono);
    } catch (e) {
      return null;
    }
  }
}
