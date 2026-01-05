import '../data/database_helper.dart';
import '../models/protocolo.dart';
import '../models/evaluacion_lesion.dart';

/// Repository para manejar la lógica de negocio de los protocolos
class ProtocoloRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Guardar un protocolo completo con su evaluación de lesión
  Future<int> guardarProtocoloCompleto({
    required Protocolo protocolo,
    EvaluacionLesion? evaluacionLesion,
  }) async {
    // Generar número interno si no existe
    final protocoloConNumero = protocolo.numeroInterno == null
        ? protocolo.copyWith(
            numeroInterno: await _dbHelper.generarNumeroInterno(),
          )
        : protocolo;

    // Guardar protocolo
    final protocoloId = await _dbHelper.insertProtocolo(protocoloConNumero);

    // Si hay evaluación de lesión, guardarla también
    if (evaluacionLesion != null) {
      final evaluacionConProtocolo = evaluacionLesion.copyWith(
        protocoloId: protocoloId,
      );
      await _dbHelper.insertEvaluacionLesion(evaluacionConProtocolo);
    }

    return protocoloId;
  }

  /// Obtener un protocolo por ID con su evaluación de lesión
  Future<Map<String, dynamic>?> obtenerProtocoloCompleto(int id) async {
    final protocolo = await _dbHelper.getProtocoloById(id);
    if (protocolo == null) return null;

    final evaluacion = await _dbHelper.getEvaluacionByProtocolo(id);

    return {'protocolo': protocolo, 'evaluacion': evaluacion};
  }

  /// Actualizar protocolo completo
  Future<void> actualizarProtocoloCompleto({
    required Protocolo protocolo,
    EvaluacionLesion? evaluacionLesion,
  }) async {
    await _dbHelper.updateProtocolo(protocolo);

    if (evaluacionLesion != null) {
      // Verificar si ya existe una evaluación
      final evaluacionExistente = await _dbHelper.getEvaluacionByProtocolo(
        protocolo.id!,
      );

      if (evaluacionExistente != null) {
        // Actualizar
        final evaluacionActualizada = evaluacionLesion.copyWith(
          id: evaluacionExistente.id,
          protocoloId: protocolo.id,
        );
        await _dbHelper.updateEvaluacionLesion(evaluacionActualizada);
      } else {
        // Insertar nueva
        final nuevaEvaluacion = evaluacionLesion.copyWith(
          protocoloId: protocolo.id,
        );
        await _dbHelper.insertEvaluacionLesion(nuevaEvaluacion);
      }
    }
  }

  /// Eliminar protocolo (también elimina la evaluación por CASCADE)
  Future<void> eliminarProtocolo(int id) async {
    await _dbHelper.deleteProtocolo(id);
  }

  /// Obtener todos los protocolos ordenados por fecha
  Future<List<Protocolo>> obtenerTodosProtocolos() async {
    return await _dbHelper.getAllProtocolos();
  }

  /// Obtener protocolos de un paciente específico
  Future<List<Protocolo>> obtenerProtocolosPorPaciente(int pacienteId) async {
    return await _dbHelper.getProtocolosByPaciente(pacienteId);
  }

  /// Buscar protocolos por número interno
  Future<Protocolo?> buscarPorNumeroInterno(String numeroInterno) async {
    final protocolos = await _dbHelper.getAllProtocolos();
    try {
      return protocolos.firstWhere((p) => p.numeroInterno == numeroInterno);
    } catch (e) {
      return null;
    }
  }

  /// Obtener estadísticas de protocolos
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    final protocolos = await _dbHelper.getAllProtocolos();

    return {
      'total': protocolos.length,
      'ultimo_mes': protocolos.where((p) {
        final fecha = DateTime.parse(p.fechaCreacion);
        final haceUnMes = DateTime.now().subtract(Duration(days: 30));
        return fecha.isAfter(haceUnMes);
      }).length,
      'ultimo_numero': protocolos.isNotEmpty
          ? protocolos.first.numeroInterno
          : '0000',
    };
  }

  /// Duplicar un protocolo (útil para casos similares)
  Future<int> duplicarProtocolo(int protocoloId) async {
    final original = await obtenerProtocoloCompleto(protocoloId);
    if (original == null) {
      throw Exception('Protocolo no encontrado');
    }

    final protocolo = original['protocolo'] as Protocolo;
    final evaluacion = original['evaluacion'] as EvaluacionLesion?;

    // Crear copia sin ID y con nueva fecha
    final nuevoProtocolo = protocolo.copyWith(
      id: null,
      numeroInterno: null, // Se generará automáticamente
      fechaCreacion: DateTime.now().toIso8601String(),
    );

    final nuevaEvaluacion = evaluacion?.copyWith(
      id: null,
      protocoloId: null, // Se asignará al guardar
    );

    return await guardarProtocoloCompleto(
      protocolo: nuevoProtocolo,
      evaluacionLesion: nuevaEvaluacion,
    );
  }
}
