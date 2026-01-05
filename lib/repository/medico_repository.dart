import '../data/database_helper.dart';
import '../models/medico.dart';

/// Repository para manejar la lógica de negocio de médicos
class MedicoRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Guardar un médico
  Future<int> guardarMedico(Medico medico) async {
    // Validar que no exista duplicado por matrícula
    if (medico.matricula != null && medico.matricula!.isNotEmpty) {
      final medicos = await _dbHelper.getAllMedicos();
      final duplicado = medicos.any(
        (m) =>
            m.matricula?.toLowerCase() == medico.matricula?.toLowerCase() &&
            m.id != medico.id,
      );

      if (duplicado) {
        throw Exception('Ya existe un médico con esa matrícula');
      }
    }

    return await _dbHelper.insertMedico(medico);
  }

  /// Actualizar médico
  Future<void> actualizarMedico(Medico medico) async {
    if (medico.id == null) {
      throw Exception('El médico debe tener un ID');
    }

    // Validar matrícula única
    if (medico.matricula != null && medico.matricula!.isNotEmpty) {
      final medicos = await _dbHelper.getAllMedicos();
      final duplicado = medicos.any(
        (m) =>
            m.matricula?.toLowerCase() == medico.matricula?.toLowerCase() &&
            m.id != medico.id,
      );

      if (duplicado) {
        throw Exception('Ya existe un médico con esa matrícula');
      }
    }

    await _dbHelper.updateMedico(medico);
  }

  /// Eliminar médico
  Future<void> eliminarMedico(int id) async {
    // Verificar que no tenga protocolos asociados
    final protocolos = await _dbHelper.getAllProtocolos();
    final tieneProtocolos = protocolos.any((p) => p.medicoRemitenteId == id);

    if (tieneProtocolos) {
      throw Exception(
        'No se puede eliminar el médico porque tiene protocolos asociados',
      );
    }

    await _dbHelper.deleteMedico(id);
  }

  /// Obtener un médico por ID
  Future<Medico?> obtenerMedicoPorId(int id) async {
    return await _dbHelper.getMedicoById(id);
  }

  /// Obtener todos los médicos
  Future<List<Medico>> obtenerTodosMedicos() async {
    return await _dbHelper.getAllMedicos();
  }

  /// Buscar médicos por nombre
  Future<List<Medico>> buscarPorNombre(String nombre) async {
    final medicos = await _dbHelper.getAllMedicos();
    return medicos
        .where(
          (m) => m.nombreCompleto.toLowerCase().contains(nombre.toLowerCase()),
        )
        .toList();
  }

  /// Buscar médico por matrícula
  Future<Medico?> buscarPorMatricula(String matricula) async {
    final medicos = await _dbHelper.getAllMedicos();
    try {
      return medicos.firstWhere(
        (m) => m.matricula?.toLowerCase() == matricula.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtener estadísticas del médico
  Future<Map<String, dynamic>?> obtenerEstadisticasMedico(int id) async {
    final medico = await _dbHelper.getMedicoById(id);
    if (medico == null) return null;

    final protocolos = await _dbHelper.getAllProtocolos();
    final protocolosMedico = protocolos
        .where((p) => p.medicoRemitenteId == id)
        .toList();

    return {
      'medico': medico,
      'total_protocolos': protocolosMedico.length,
      'protocolos': protocolosMedico,
    };
  }
}
