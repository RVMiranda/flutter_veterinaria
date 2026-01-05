class Propietario {
  final int? id;
  final String nombreCompleto;
  final String? direccion;
  final String? telefono;
  final String? email;

  Propietario({
    this.id,
    required this.nombreCompleto,
    this.direccion,
    this.telefono,
    this.email,
  });

  // Convertir desde Map
  factory Propietario.fromMap(Map<String, dynamic> map) {
    return Propietario(
      id: map['id'] as int?,
      nombreCompleto: map['nombre_completo'] as String,
      direccion: map['direccion'] as String?,
      telefono: map['telefono'] as String?,
      email: map['email'] as String?,
    );
  }

  // Convertir a Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre_completo': nombreCompleto,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
    };
  }

  // Método copyWith
  Propietario copyWith({
    int? id,
    String? nombreCompleto,
    String? direccion,
    String? telefono,
    String? email,
  }) {
    return Propietario(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
    );
  }
}
