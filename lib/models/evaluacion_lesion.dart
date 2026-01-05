class EvaluacionLesion {
  final int? id;
  final int? protocoloId;

  // Parámetros específicos de la lesión
  final String? localizacion;
  final double? tamanoLargo; // cm
  final double? tamanoAncho; // cm
  final double? tamanoAlto; // cm
  final String? forma;
  final String? color;
  final String? consistencia;
  final String? distribucion;
  final String? patronCrecimiento;
  final String? tasaCrecimiento;
  final String? contorno;
  final int recurrencia; // 0: No, 1: Sí
  final int capsula; // 0: No, 1: Sí

  EvaluacionLesion({
    this.id,
    this.protocoloId,
    this.localizacion,
    this.tamanoLargo,
    this.tamanoAncho,
    this.tamanoAlto,
    this.forma,
    this.color,
    this.consistencia,
    this.distribucion,
    this.patronCrecimiento,
    this.tasaCrecimiento,
    this.contorno,
    this.recurrencia = 0,
    this.capsula = 0,
  });

  // Convertir desde Map
  factory EvaluacionLesion.fromMap(Map<String, dynamic> map) {
    return EvaluacionLesion(
      id: map['id'] as int?,
      protocoloId: map['protocolo_id'] as int?,
      localizacion: map['localizacion'] as String?,
      tamanoLargo: map['tamano_largo'] != null
          ? (map['tamano_largo'] as num).toDouble()
          : null,
      tamanoAncho: map['tamano_ancho'] != null
          ? (map['tamano_ancho'] as num).toDouble()
          : null,
      tamanoAlto: map['tamano_alto'] != null
          ? (map['tamano_alto'] as num).toDouble()
          : null,
      forma: map['forma'] as String?,
      color: map['color'] as String?,
      consistencia: map['consistencia'] as String?,
      distribucion: map['distribucion'] as String?,
      patronCrecimiento: map['patron_crecimiento'] as String?,
      tasaCrecimiento: map['tasa_crecimiento'] as String?,
      contorno: map['contorno'] as String?,
      recurrencia: map['recurrencia'] as int? ?? 0,
      capsula: map['capsula'] as int? ?? 0,
    );
  }

  // Convertir a Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'protocolo_id': protocoloId,
      'localizacion': localizacion,
      'tamano_largo': tamanoLargo,
      'tamano_ancho': tamanoAncho,
      'tamano_alto': tamanoAlto,
      'forma': forma,
      'color': color,
      'consistencia': consistencia,
      'distribucion': distribucion,
      'patron_crecimiento': patronCrecimiento,
      'tasa_crecimiento': tasaCrecimiento,
      'contorno': contorno,
      'recurrencia': recurrencia,
      'capsula': capsula,
    };
  }

  // Calcular volumen aproximado (largo * ancho * alto)
  double? calcularVolumen() {
    if (tamanoLargo != null && tamanoAncho != null && tamanoAlto != null) {
      return tamanoLargo! * tamanoAncho! * tamanoAlto!;
    }
    return null;
  }

  // Método copyWith
  EvaluacionLesion copyWith({
    int? id,
    int? protocoloId,
    String? localizacion,
    double? tamanoLargo,
    double? tamanoAncho,
    double? tamanoAlto,
    String? forma,
    String? color,
    String? consistencia,
    String? distribucion,
    String? patronCrecimiento,
    String? tasaCrecimiento,
    String? contorno,
    int? recurrencia,
    int? capsula,
  }) {
    return EvaluacionLesion(
      id: id ?? this.id,
      protocoloId: protocoloId ?? this.protocoloId,
      localizacion: localizacion ?? this.localizacion,
      tamanoLargo: tamanoLargo ?? this.tamanoLargo,
      tamanoAncho: tamanoAncho ?? this.tamanoAncho,
      tamanoAlto: tamanoAlto ?? this.tamanoAlto,
      forma: forma ?? this.forma,
      color: color ?? this.color,
      consistencia: consistencia ?? this.consistencia,
      distribucion: distribucion ?? this.distribucion,
      patronCrecimiento: patronCrecimiento ?? this.patronCrecimiento,
      tasaCrecimiento: tasaCrecimiento ?? this.tasaCrecimiento,
      contorno: contorno ?? this.contorno,
      recurrencia: recurrencia ?? this.recurrencia,
      capsula: capsula ?? this.capsula,
    );
  }
}
