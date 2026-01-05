class Protocolo {
  final int? id;
  final String? numeroInterno;
  final String fechaCreacion; // DATETIME como String en SQLite

  // Relaciones
  final int? pacienteId;
  final int? medicoRemitenteId;

  // Datos clínicos del momento
  final int? edadAlMomento;
  final double? pesoAlMomento;
  final String? tejidosEnviados;
  final String? anamnesis;
  final String? dxPresuntivo;

  // Datos de la muestra
  final String? sitioAnatomico;
  final String? metodoObtencion;
  final int? laminasEnviadas;
  final double? liquidoEnviadoMl;
  final String? metodoFijacion;

  // Resultados
  final String? rutaImagenMicroscopia;
  final String? aspectoMacroscopico;
  final String? aspectoMicroscopico;
  final String? diagnosticoCitologico;
  final String? observaciones;

  Protocolo({
    this.id,
    this.numeroInterno,
    String? fechaCreacion,
    this.pacienteId,
    this.medicoRemitenteId,
    this.edadAlMomento,
    this.pesoAlMomento,
    this.tejidosEnviados,
    this.anamnesis,
    this.dxPresuntivo,
    this.sitioAnatomico,
    this.metodoObtencion,
    this.laminasEnviadas,
    this.liquidoEnviadoMl,
    this.metodoFijacion,
    this.rutaImagenMicroscopia,
    this.aspectoMacroscopico,
    this.aspectoMicroscopico,
    this.diagnosticoCitologico,
    this.observaciones,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now().toIso8601String();

  // Convertir desde Map
  factory Protocolo.fromMap(Map<String, dynamic> map) {
    return Protocolo(
      id: map['id'] as int?,
      numeroInterno: map['numero_interno'] as String?,
      fechaCreacion: map['fecha_creacion'] as String,
      pacienteId: map['paciente_id'] as int?,
      medicoRemitenteId: map['medico_remitente_id'] as int?,
      edadAlMomento: map['edad_al_momento'] as int?,
      pesoAlMomento: map['peso_al_momento'] != null
          ? (map['peso_al_momento'] as num).toDouble()
          : null,
      tejidosEnviados: map['tejidos_enviados'] as String?,
      anamnesis: map['anamnesis'] as String?,
      dxPresuntivo: map['dx_presuntivo'] as String?,
      sitioAnatomico: map['sitio_anatomico'] as String?,
      metodoObtencion: map['metodo_obtencion'] as String?,
      laminasEnviadas: map['laminas_enviadas'] as int?,
      liquidoEnviadoMl: map['liquido_enviado_ml'] != null
          ? (map['liquido_enviado_ml'] as num).toDouble()
          : null,
      metodoFijacion: map['metodo_fijacion'] as String?,
      rutaImagenMicroscopia: map['ruta_imagen_microscopia'] as String?,
      aspectoMacroscopico: map['aspecto_macroscopico'] as String?,
      aspectoMicroscopico: map['aspecto_microscopico'] as String?,
      diagnosticoCitologico: map['diagnostico_citologico'] as String?,
      observaciones: map['observaciones'] as String?,
    );
  }

  // Convertir a Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'numero_interno': numeroInterno,
      'fecha_creacion': fechaCreacion,
      'paciente_id': pacienteId,
      'medico_remitente_id': medicoRemitenteId,
      'edad_al_momento': edadAlMomento,
      'peso_al_momento': pesoAlMomento,
      'tejidos_enviados': tejidosEnviados,
      'anamnesis': anamnesis,
      'dx_presuntivo': dxPresuntivo,
      'sitio_anatomico': sitioAnatomico,
      'metodo_obtencion': metodoObtencion,
      'laminas_enviadas': laminasEnviadas,
      'liquido_enviado_ml': liquidoEnviadoMl,
      'metodo_fijacion': metodoFijacion,
      'ruta_imagen_microscopia': rutaImagenMicroscopia,
      'aspecto_macroscopico': aspectoMacroscopico,
      'aspecto_microscopico': aspectoMicroscopico,
      'diagnostico_citologico': diagnosticoCitologico,
      'observaciones': observaciones,
    };
  }

  // Método copyWith
  Protocolo copyWith({
    int? id,
    String? numeroInterno,
    String? fechaCreacion,
    int? pacienteId,
    int? medicoRemitenteId,
    int? edadAlMomento,
    double? pesoAlMomento,
    String? tejidosEnviados,
    String? anamnesis,
    String? dxPresuntivo,
    String? sitioAnatomico,
    String? metodoObtencion,
    int? laminasEnviadas,
    double? liquidoEnviadoMl,
    String? metodoFijacion,
    String? rutaImagenMicroscopia,
    String? aspectoMacroscopico,
    String? aspectoMicroscopico,
    String? diagnosticoCitologico,
    String? observaciones,
  }) {
    return Protocolo(
      id: id ?? this.id,
      numeroInterno: numeroInterno ?? this.numeroInterno,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      pacienteId: pacienteId ?? this.pacienteId,
      medicoRemitenteId: medicoRemitenteId ?? this.medicoRemitenteId,
      edadAlMomento: edadAlMomento ?? this.edadAlMomento,
      pesoAlMomento: pesoAlMomento ?? this.pesoAlMomento,
      tejidosEnviados: tejidosEnviados ?? this.tejidosEnviados,
      anamnesis: anamnesis ?? this.anamnesis,
      dxPresuntivo: dxPresuntivo ?? this.dxPresuntivo,
      sitioAnatomico: sitioAnatomico ?? this.sitioAnatomico,
      metodoObtencion: metodoObtencion ?? this.metodoObtencion,
      laminasEnviadas: laminasEnviadas ?? this.laminasEnviadas,
      liquidoEnviadoMl: liquidoEnviadoMl ?? this.liquidoEnviadoMl,
      metodoFijacion: metodoFijacion ?? this.metodoFijacion,
      rutaImagenMicroscopia:
          rutaImagenMicroscopia ?? this.rutaImagenMicroscopia,
      aspectoMacroscopico: aspectoMacroscopico ?? this.aspectoMacroscopico,
      aspectoMicroscopico: aspectoMicroscopico ?? this.aspectoMicroscopico,
      diagnosticoCitologico:
          diagnosticoCitologico ?? this.diagnosticoCitologico,
      observaciones: observaciones ?? this.observaciones,
    );
  }
}
