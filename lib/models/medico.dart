class Medico {
  final int? id;
  final String nombreCompleto;
  final String? matricula;
  final String? email;

  Medico({this.id, required this.nombreCompleto, this.matricula, this.email});

  // Convertir desde Map
  factory Medico.fromMap(Map<String, dynamic> map) {
    return Medico(
      id: map['id'] as int?,
      nombreCompleto: map['nombre_completo'] as String,
      matricula: map['matricula'] as String?,
      email: map['email'] as String?,
    );
  }

  // Convertir a Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre_completo': nombreCompleto,
      'matricula': matricula,
      'email': email,
    };
  }

  // Método copyWith
  Medico copyWith({
    int? id,
    String? nombreCompleto,
    String? matricula,
    String? email,
  }) {
    return Medico(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      matricula: matricula ?? this.matricula,
      email: email ?? this.email,
    );
  }
}
