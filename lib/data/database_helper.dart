import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/veterinaria_info.dart';
import '../models/medico.dart';
import '../models/propietario.dart';
import '../models/paciente.dart';
import '../models/protocolo.dart';
import '../models/evaluacion_lesion.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('veterinaria.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE protocolo ADD COLUMN rutas_imagenes TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE protocolo ADD COLUMN etiqueta TEXT');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla veterinaria_info
    await db.execute('''
      CREATE TABLE veterinaria_info (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_clinica TEXT NOT NULL,
        direccion TEXT,
        telefono_principal TEXT,
        telefono_urgencias TEXT,
        email_contacto TEXT,
        logo_path TEXT
      )
    ''');

    // Tabla medico
    await db.execute('''
      CREATE TABLE medico (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_completo TEXT NOT NULL,
        matricula TEXT,
        email TEXT
      )
    ''');

    // Tabla propietario
    await db.execute('''
      CREATE TABLE propietario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_completo TEXT NOT NULL,
        direccion TEXT,
        telefono TEXT,
        email TEXT
      )
    ''');

    // Tabla paciente
    await db.execute('''
      CREATE TABLE paciente (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        propietario_id INTEGER,
        nombre TEXT NOT NULL,
        especie TEXT,
        raza TEXT,
        genero TEXT,
        castrado INTEGER DEFAULT 0,
        fecha_nacimiento TEXT,
        peso_actual REAL,
        FOREIGN KEY (propietario_id) REFERENCES propietario(id)
      )
    ''');

    // Tabla protocolo
    await db.execute('''
      CREATE TABLE protocolo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        numero_interno TEXT,
        etiqueta TEXT,
        fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
        paciente_id INTEGER,
        medico_remitente_id INTEGER,
        edad_al_momento INTEGER,
        peso_al_momento REAL,
        tejidos_enviados TEXT,
        anamnesis TEXT,
        dx_presuntivo TEXT,
        sitio_anatomico TEXT,
        metodo_obtencion TEXT,
        laminas_enviadas INTEGER,
        liquido_enviado_ml REAL,
        metodo_fijacion TEXT,
        ruta_imagen_microscopia TEXT,
        rutas_imagenes TEXT,
        aspecto_macroscopico TEXT,
        aspecto_microscopico TEXT,
        diagnostico_citologico TEXT,
        observaciones TEXT,
        FOREIGN KEY (paciente_id) REFERENCES paciente(id),
        FOREIGN KEY (medico_remitente_id) REFERENCES medico(id)
      )
    ''');

    // Tabla evaluacion_lesion
    await db.execute('''
      CREATE TABLE evaluacion_lesion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        protocolo_id INTEGER,
        localizacion TEXT,
        tamano_largo REAL,
        tamano_ancho REAL,
        tamano_alto REAL,
        forma TEXT,
        color TEXT,
        consistencia TEXT,
        distribucion TEXT,
        patron_crecimiento TEXT,
        tasa_crecimiento TEXT,
        contorno TEXT,
        recurrencia INTEGER DEFAULT 0,
        capsula INTEGER DEFAULT 0,
        FOREIGN KEY (protocolo_id) REFERENCES protocolo(id) ON DELETE CASCADE
      )
    ''');
  }

  // ============ CRUD VeterinariaInfo ============

  Future<int> insertVeterinariaInfo(VeterinariaInfo info) async {
    final db = await database;
    return await db.insert('veterinaria_info', info.toMap());
  }

  Future<VeterinariaInfo?> getVeterinariaInfo() async {
    final db = await database;
    final maps = await db.query('veterinaria_info', limit: 1);
    if (maps.isEmpty) return null;
    return VeterinariaInfo.fromMap(maps.first);
  }

  Future<int> updateVeterinariaInfo(VeterinariaInfo info) async {
    final db = await database;
    return await db.update(
      'veterinaria_info',
      info.toMap(),
      where: 'id = ?',
      whereArgs: [info.id],
    );
  }

  // ============ CRUD Medico ============

  Future<int> insertMedico(Medico medico) async {
    final db = await database;
    return await db.insert('medico', medico.toMap());
  }

  Future<List<Medico>> getAllMedicos() async {
    final db = await database;
    final maps = await db.query('medico', orderBy: 'nombre_completo ASC');
    return maps.map((map) => Medico.fromMap(map)).toList();
  }

  Future<Medico?> getMedicoById(int id) async {
    final db = await database;
    final maps = await db.query('medico', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Medico.fromMap(maps.first);
  }

  Future<int> updateMedico(Medico medico) async {
    final db = await database;
    return await db.update(
      'medico',
      medico.toMap(),
      where: 'id = ?',
      whereArgs: [medico.id],
    );
  }

  Future<int> deleteMedico(int id) async {
    final db = await database;
    return await db.delete('medico', where: 'id = ?', whereArgs: [id]);
  }

  // ============ CRUD Propietario ============

  Future<int> insertPropietario(Propietario propietario) async {
    final db = await database;
    return await db.insert('propietario', propietario.toMap());
  }

  Future<List<Propietario>> getAllPropietarios() async {
    final db = await database;
    final maps = await db.query('propietario', orderBy: 'nombre_completo ASC');
    return maps.map((map) => Propietario.fromMap(map)).toList();
  }

  Future<Propietario?> getPropietarioById(int id) async {
    final db = await database;
    final maps = await db.query(
      'propietario',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Propietario.fromMap(maps.first);
  }

  Future<int> updatePropietario(Propietario propietario) async {
    final db = await database;
    return await db.update(
      'propietario',
      propietario.toMap(),
      where: 'id = ?',
      whereArgs: [propietario.id],
    );
  }

  Future<int> deletePropietario(int id) async {
    final db = await database;
    return await db.delete('propietario', where: 'id = ?', whereArgs: [id]);
  }

  // ============ CRUD Paciente ============

  Future<int> insertPaciente(Paciente paciente) async {
    final db = await database;
    return await db.insert('paciente', paciente.toMap());
  }

  Future<List<Paciente>> getAllPacientes() async {
    final db = await database;
    final maps = await db.query('paciente', orderBy: 'nombre ASC');
    return maps.map((map) => Paciente.fromMap(map)).toList();
  }

  Future<List<Paciente>> getPacientesByPropietario(int propietarioId) async {
    final db = await database;
    final maps = await db.query(
      'paciente',
      where: 'propietario_id = ?',
      whereArgs: [propietarioId],
      orderBy: 'nombre ASC',
    );
    return maps.map((map) => Paciente.fromMap(map)).toList();
  }

  Future<Paciente?> getPacienteById(int id) async {
    final db = await database;
    final maps = await db.query('paciente', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Paciente.fromMap(maps.first);
  }

  Future<int> updatePaciente(Paciente paciente) async {
    final db = await database;
    return await db.update(
      'paciente',
      paciente.toMap(),
      where: 'id = ?',
      whereArgs: [paciente.id],
    );
  }

  Future<int> deletePaciente(int id) async {
    final db = await database;
    return await db.delete('paciente', where: 'id = ?', whereArgs: [id]);
  }

  // ============ CRUD Protocolo ============

  Future<int> insertProtocolo(Protocolo protocolo) async {
    final db = await database;
    return await db.insert('protocolo', protocolo.toMap());
  }

  Future<List<Protocolo>> getAllProtocolos() async {
    final db = await database;
    final maps = await db.query('protocolo', orderBy: 'fecha_creacion DESC');
    return maps.map((map) => Protocolo.fromMap(map)).toList();
  }

  Future<List<Protocolo>> getProtocolosByPaciente(int pacienteId) async {
    final db = await database;
    final maps = await db.query(
      'protocolo',
      where: 'paciente_id = ?',
      whereArgs: [pacienteId],
      orderBy: 'fecha_creacion DESC',
    );
    return maps.map((map) => Protocolo.fromMap(map)).toList();
  }

  Future<Protocolo?> getProtocoloById(int id) async {
    final db = await database;
    final maps = await db.query('protocolo', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Protocolo.fromMap(maps.first);
  }

  Future<int> updateProtocolo(Protocolo protocolo) async {
    final db = await database;
    return await db.update(
      'protocolo',
      protocolo.toMap(),
      where: 'id = ?',
      whereArgs: [protocolo.id],
    );
  }

  Future<int> deleteProtocolo(int id) async {
    final db = await database;
    return await db.delete('protocolo', where: 'id = ?', whereArgs: [id]);
  }

  // ============ CRUD EvaluacionLesion ============

  Future<int> insertEvaluacionLesion(EvaluacionLesion evaluacion) async {
    final db = await database;
    return await db.insert('evaluacion_lesion', evaluacion.toMap());
  }

  Future<EvaluacionLesion?> getEvaluacionByProtocolo(int protocoloId) async {
    final db = await database;
    final maps = await db.query(
      'evaluacion_lesion',
      where: 'protocolo_id = ?',
      whereArgs: [protocoloId],
    );
    if (maps.isEmpty) return null;
    return EvaluacionLesion.fromMap(maps.first);
  }

  Future<EvaluacionLesion?> getEvaluacionById(int id) async {
    final db = await database;
    final maps = await db.query(
      'evaluacion_lesion',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return EvaluacionLesion.fromMap(maps.first);
  }

  Future<int> updateEvaluacionLesion(EvaluacionLesion evaluacion) async {
    final db = await database;
    return await db.update(
      'evaluacion_lesion',
      evaluacion.toMap(),
      where: 'id = ?',
      whereArgs: [evaluacion.id],
    );
  }

  Future<int> deleteEvaluacionLesion(int id) async {
    final db = await database;
    return await db.delete(
      'evaluacion_lesion',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ Utilidades ============

  // Generar el siguiente número interno de protocolo
  Future<String> generarNumeroInterno() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM protocolo');
    final total = result.first['total'] as int;
    return (total + 1).toString().padLeft(4, '0');
  }

  // Cerrar la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
