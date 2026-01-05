import '../data/database_helper.dart';
import '../models/paciente.dart';
import '../models/propietario.dart';

/// Repository para manejar la lógica de negocio de pacientes
class PacienteRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Guardar un paciente
  Future<int> guardarPaciente(Paciente paciente) async {
    // Validar que existe el propietario
    if (paciente.propietarioId != null) {
      final propietario = await _dbHelper.getPropietarioById(
        paciente.propietarioId!,
      );
      if (propietario == null) {
        throw Exception('El propietario no existe');
      }
    }

    return await _dbHelper.insertPaciente(paciente);
  }

  /// Actualizar paciente
  Future<void> actualizarPaciente(Paciente paciente) async {
    if (paciente.id == null) {
      throw Exception('El paciente debe tener un ID');
    }
    await _dbHelper.updatePaciente(paciente);
  }

  /// Eliminar paciente
  Future<void> eliminarPaciente(int id) async {
    // Verificar que no tenga protocolos asociados
    final protocolos = await _dbHelper.getProtocolosByPaciente(id);
    if (protocolos.isNotEmpty) {
      throw Exception(
        'No se puede eliminar el paciente porque tiene ${protocolos.length} protocolo(s) asociado(s)',
      );
    }

    await _dbHelper.deletePaciente(id);
  }

  /// Obtener un paciente por ID
  Future<Paciente?> obtenerPacientePorId(int id) async {
    return await _dbHelper.getPacienteById(id);
  }

  /// Obtener todos los pacientes
  Future<List<Paciente>> obtenerTodosPacientes() async {
    return await _dbHelper.getAllPacientes();
  }

  /// Obtener pacientes de un propietario
  Future<List<Paciente>> obtenerPacientesPorPropietario(
    int propietarioId,
  ) async {
    return await _dbHelper.getPacientesByPropietario(propietarioId);
  }

  /// Obtener paciente con su propietario
  Future<Map<String, dynamic>?> obtenerPacienteConPropietario(int id) async {
    final paciente = await _dbHelper.getPacienteById(id);
    if (paciente == null) return null;

    Propietario? propietario;
    if (paciente.propietarioId != null) {
      propietario = await _dbHelper.getPropietarioById(paciente.propietarioId!);
    }

    return {'paciente': paciente, 'propietario': propietario};
  }

  /// Buscar pacientes por nombre
  Future<List<Paciente>> buscarPorNombre(String nombre) async {
    final pacientes = await _dbHelper.getAllPacientes();
    return pacientes
        .where((p) => p.nombre.toLowerCase().contains(nombre.toLowerCase()))
        .toList();
  }

  /// Obtener estadísticas de pacientes
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    final pacientes = await _dbHelper.getAllPacientes();

    final porEspecie = <String, int>{};
    for (var paciente in pacientes) {
      final especie = paciente.especie ?? 'Sin especificar';
      porEspecie[especie] = (porEspecie[especie] ?? 0) + 1;
    }

    return {
      'total': pacientes.length,
      'castrados': pacientes.where((p) => p.castrado == 1).length,
      'no_castrados': pacientes.where((p) => p.castrado == 0).length,
      'por_especie': porEspecie,
    };
  }

  /// Obtener historial completo del paciente
  Future<Map<String, dynamic>?> obtenerHistorialCompleto(int id) async {
    final paciente = await _dbHelper.getPacienteById(id);
    if (paciente == null) return null;

    final propietario = paciente.propietarioId != null
        ? await _dbHelper.getPropietarioById(paciente.propietarioId!)
        : null;

    final protocolos = await _dbHelper.getProtocolosByPaciente(id);

    return {
      'paciente': paciente,
      'propietario': propietario,
      'protocolos': protocolos,
      'total_protocolos': protocolos.length,
      'edad_actual': paciente.calcularEdad(),
    };
  }
}
