class Paciente {
  final int? id;
  final int? propietarioId;
  final String nombre;
  final String? especie;
  final String? raza;
  final String? genero;
  final int castrado; // 0: No, 1: Sí, 2: NR (No Reportado)
  final String? fechaNacimiento; // Formato: YYYY-MM-DD
  final double? pesoActual;

  Paciente({
    this.id,
    this.propietarioId,
    required this.nombre,
    this.especie,
    this.raza,
    this.genero,
    this.castrado = 0,
    this.fechaNacimiento,
    this.pesoActual,
  });

  // Convertir desde Map
  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      id: map['id'] as int?,
      propietarioId: map['propietario_id'] as int?,
      nombre: map['nombre'] as String,
      especie: map['especie'] as String?,
      raza: map['raza'] as String?,
      genero: map['genero'] as String?,
      castrado: map['castrado'] as int? ?? 0,
      fechaNacimiento: map['fecha_nacimiento'] as String?,
      pesoActual: map['peso_actual'] != null
          ? (map['peso_actual'] as num).toDouble()
          : null,
    );
  }

  // Convertir a Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'propietario_id': propietarioId,
      'nombre': nombre,
      'especie': especie,
      'raza': raza,
      'genero': genero,
      'castrado': castrado,
      'fecha_nacimiento': fechaNacimiento,
      'peso_actual': pesoActual,
    };
  }

  // Calcular edad en años basado en la fecha de nacimiento
  int? calcularEdad() {
    if (fechaNacimiento == null) return null;
    try {
      final fechaNac = DateTime.parse(fechaNacimiento!);
      final hoy = DateTime.now();
      int edad = hoy.year - fechaNac.year;
      if (hoy.month < fechaNac.month ||
          (hoy.month == fechaNac.month && hoy.day < fechaNac.day)) {
        edad--;
      }
      return edad;
    } catch (e) {
      return null;
    }
  }

  // Método copyWith
  Paciente copyWith({
    int? id,
    int? propietarioId,
    String? nombre,
    String? especie,
    String? raza,
    String? genero,
    int? castrado,
    String? fechaNacimiento,
    double? pesoActual,
  }) {
    return Paciente(
      id: id ?? this.id,
      propietarioId: propietarioId ?? this.propietarioId,
      nombre: nombre ?? this.nombre,
      especie: especie ?? this.especie,
      raza: raza ?? this.raza,
      genero: genero ?? this.genero,
      castrado: castrado ?? this.castrado,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      pesoActual: pesoActual ?? this.pesoActual,
    );
  }
}
