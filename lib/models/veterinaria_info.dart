class VeterinariaInfo {
  final int? id;
  final String nombreClinica;
  final String? direccion;
  final String? telefonoPrincipal;
  final String? telefonoUrgencias;
  final String? emailContacto;
  final String? logoPath;

  VeterinariaInfo({
    this.id,
    required this.nombreClinica,
    this.direccion,
    this.telefonoPrincipal,
    this.telefonoUrgencias,
    this.emailContacto,
    this.logoPath,
  });

  // Convertir desde Map (cuando se lee de la BD)
  factory VeterinariaInfo.fromMap(Map<String, dynamic> map) {
    return VeterinariaInfo(
      id: map['id'] as int?,
      nombreClinica: map['nombre_clinica'] as String,
      direccion: map['direccion'] as String?,
      telefonoPrincipal: map['telefono_principal'] as String?,
      telefonoUrgencias: map['telefono_urgencias'] as String?,
      emailContacto: map['email_contacto'] as String?,
      logoPath: map['logo_path'] as String?,
    );
  }

  // Convertir a Map (cuando se guarda en la BD)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre_clinica': nombreClinica,
      'direccion': direccion,
      'telefono_principal': telefonoPrincipal,
      'telefono_urgencias': telefonoUrgencias,
      'email_contacto': emailContacto,
      'logo_path': logoPath,
    };
  }

  // Método para crear copias con modificaciones
  VeterinariaInfo copyWith({
    int? id,
    String? nombreClinica,
    String? direccion,
    String? telefonoPrincipal,
    String? telefonoUrgencias,
    String? emailContacto,
    String? logoPath,
  }) {
    return VeterinariaInfo(
      id: id ?? this.id,
      nombreClinica: nombreClinica ?? this.nombreClinica,
      direccion: direccion ?? this.direccion,
      telefonoPrincipal: telefonoPrincipal ?? this.telefonoPrincipal,
      telefonoUrgencias: telefonoUrgencias ?? this.telefonoUrgencias,
      emailContacto: emailContacto ?? this.emailContacto,
      logoPath: logoPath ?? this.logoPath,
    );
  }
}
