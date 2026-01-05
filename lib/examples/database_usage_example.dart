import '../data/database_helper.dart';
import '../models/veterinaria_info.dart';
import '../models/medico.dart';
import '../models/propietario.dart';
import '../models/paciente.dart';
import '../models/protocolo.dart';
import '../models/evaluacion_lesion.dart';

/// Ejemplo de cómo usar los modelos y la base de datos
class DatabaseUsageExample {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Ejemplo completo: crear un protocolo con todos sus datos
  Future<void> crearProtocoloCompleto() async {
    // 1. Configurar información de la veterinaria (solo una vez)
    final veterinaria = VeterinariaInfo(
      nombreClinica: 'Veterinaria "El Gaucho"',
      direccion: 'Av. Principal 123',
      telefonoPrincipal: '011-1234-5678',
      telefonoUrgencias: '011-8765-4321',
      emailContacto: 'info@elgaucho.com',
      logoPath: '/ruta/al/logo.png',
    );
    final veterinariaId = await _db.insertVeterinariaInfo(veterinaria);
    print('Veterinaria registrada con ID: $veterinariaId');

    // 2. Registrar médico remitente
    final medico = Medico(
      nombreCompleto: 'Saba Efrain',
      matricula: 'MP-12345',
      email: 'saba.efrain@ejemplo.com',
    );
    final medicoId = await _db.insertMedico(medico);
    print('Médico registrado con ID: $medicoId');

    // 3. Registrar propietario
    final propietario = Propietario(
      nombreCompleto: 'Britos Carlos',
      direccion: 'Primera Junta 6148',
      telefono: '011-9876-5432',
      email: 'carlos.britos@ejemplo.com',
    );
    final propietarioId = await _db.insertPropietario(propietario);
    print('Propietario registrado con ID: $propietarioId');

    // 4. Registrar paciente
    final paciente = Paciente(
      propietarioId: propietarioId,
      nombre: 'Tyson',
      especie: 'Perro',
      raza: 'Labrador',
      genero: 'Macho',
      castrado: 1, // 1 = Sí
      fechaNacimiento: '2020-05-15',
      pesoActual: 35.0,
    );
    final pacienteId = await _db.insertPaciente(paciente);
    print('Paciente registrado con ID: $pacienteId');
    print('Edad del paciente: ${paciente.calcularEdad()} años');

    // 5. Generar número interno automático
    final numeroInterno = await _db.generarNumeroInterno();
    print('Número interno generado: $numeroInterno');

    // 6. Crear protocolo
    final protocolo = Protocolo(
      numeroInterno: numeroInterno,
      pacienteId: pacienteId,
      medicoRemitenteId: medicoId,
      edadAlMomento: paciente.calcularEdad(),
      pesoAlMomento: paciente.pesoActual,
      tejidosEnviados: '3 muestras por paaf',
      anamnesis: 'Presentó nódulos en región cervical hace 2 meses...',
      dxPresuntivo: 'Posible neoplasia cutánea',
      sitioAnatomico: 'Piel región cervical',
      metodoObtencion: 'Aspirado',
      laminasEnviadas: 3,
      liquidoEnviadoMl: null,
      metodoFijacion: 'Aire',
      rutaImagenMicroscopia: '/ruta/a/imagen/citologia.jpg',
      aspectoMacroscopico: 'Nódulo de 3x2 cm, firme, rojizo',
      aspectoMicroscopico: 'Células redondeadas con gránulos basofílicos...',
      diagnosticoCitologico: 'Sugerente de mastocitoma grado II',
      observaciones: 'Se recomienda biopsia escisional completa',
    );
    final protocoloId = await _db.insertProtocolo(protocolo);
    print('Protocolo creado con ID: $protocoloId');

    // 7. Registrar evaluación de la lesión
    final evaluacion = EvaluacionLesion(
      protocoloId: protocoloId,
      localizacion: 'Piel, subcutáneo',
      tamanoLargo: 3.0,
      tamanoAncho: 2.0,
      tamanoAlto: 1.5,
      forma: 'Irregular',
      color: 'Rojizo',
      consistencia: 'Firme',
      distribucion: 'Focal',
      patronCrecimiento: 'Infiltrante',
      tasaCrecimiento: 'Rápido',
      contorno: 'Elevada',
      recurrencia: 0, // No
      capsula: 0, // No
    );
    final evaluacionId = await _db.insertEvaluacionLesion(evaluacion);
    print('Evaluación registrada con ID: $evaluacionId');
    print('Volumen aproximado: ${evaluacion.calcularVolumen()} cm³');
  }

  /// Ejemplo: consultar todos los protocolos de un paciente
  Future<void> consultarProtocolosPaciente(int pacienteId) async {
    final protocolos = await _db.getProtocolosByPaciente(pacienteId);
    print('Protocolos encontrados: ${protocolos.length}');

    for (var protocolo in protocolos) {
      print('Protocolo #${protocolo.numeroInterno}');
      print('Fecha: ${protocolo.fechaCreacion}');
      print('Diagnóstico: ${protocolo.diagnosticoCitologico}');
      print('---');
    }
  }

  /// Ejemplo: actualizar un protocolo
  Future<void> actualizarProtocolo(int protocoloId) async {
    final protocolo = await _db.getProtocoloById(protocoloId);
    if (protocolo != null) {
      final protocoloActualizado = protocolo.copyWith(
        observaciones: 'Observaciones actualizadas: Se realizó seguimiento...',
      );
      await _db.updateProtocolo(protocoloActualizado);
      print('Protocolo actualizado correctamente');
    }
  }

  /// Ejemplo: obtener historial completo de un paciente
  Future<void> obtenerHistorialPaciente(int pacienteId) async {
    // Obtener paciente
    final paciente = await _db.getPacienteById(pacienteId);
    if (paciente == null) {
      print('Paciente no encontrado');
      return;
    }

    // Obtener propietario
    final propietario = await _db.getPropietarioById(paciente.propietarioId!);

    // Obtener todos los protocolos
    final protocolos = await _db.getProtocolosByPaciente(pacienteId);

    print('=== HISTORIAL DEL PACIENTE ===');
    print('Nombre: ${paciente.nombre}');
    print('Especie: ${paciente.especie}');
    print('Edad: ${paciente.calcularEdad()} años');
    print('Propietario: ${propietario?.nombreCompleto}');
    print('\nProtocolos: ${protocolos.length}');

    for (var protocolo in protocolos) {
      print('\n--- Protocolo #${protocolo.numeroInterno} ---');
      print('Fecha: ${protocolo.fechaCreacion}');
      print('Diagnóstico: ${protocolo.diagnosticoCitologico}');

      // Obtener evaluación de lesión si existe
      final evaluacion = await _db.getEvaluacionByProtocolo(protocolo.id!);
      if (evaluacion != null) {
        print(
          'Tamaño lesión: ${evaluacion.tamanoLargo}x${evaluacion.tamanoAncho}x${evaluacion.tamanoAlto} cm',
        );
      }
    }
  }

  /// Ejemplo: listar todos los pacientes con sus propietarios
  Future<void> listarTodosPacientes() async {
    final pacientes = await _db.getAllPacientes();

    print('=== LISTA DE PACIENTES ===');
    for (var paciente in pacientes) {
      final propietario = await _db.getPropietarioById(paciente.propietarioId!);
      print(
        '${paciente.nombre} (${paciente.especie}) - Propietario: ${propietario?.nombreCompleto}',
      );
    }
  }
}
