/// Un cambio brusco de aceleración detectado (fila de acceleration_events).
class EventoAceleracion {
  final String? id;

  /// Valores del acelerómetro en el momento del evento (m/s²).
  final double x;
  final double y;
  final double z;

  /// |a| = √(x² + y² + z²).
  final double magnitud;

  /// Cuánto se alejó |a| de la gravedad; es lo que se compara con el umbral.
  final double intensidad;

  /// Umbral con el que se detectó el evento.
  final double umbral;

  final DateTime detectadoEn;

  EventoAceleracion({
    this.id,
    required this.x,
    required this.y,
    required this.z,
    required this.magnitud,
    required this.intensidad,
    required this.umbral,
    required this.detectadoEn,
  });

  factory EventoAceleracion.fromMap(Map<String, dynamic> map) {
    return EventoAceleracion(
      id: map['id'],
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      z: (map['z'] as num).toDouble(),
      magnitud: (map['magnitude'] as num).toDouble(),
      intensidad: (map['intensity'] as num).toDouble(),
      umbral: (map['threshold'] as num).toDouble(),
      detectadoEn: DateTime.parse(map['detected_at']).toLocal(),
    );
  }

  /// Datos para insertar en Supabase (el id lo genera la base de datos).
  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'z': z,
      'magnitude': magnitud,
      'intensity': intensidad,
      'threshold': umbral,
      'detected_at': detectadoEn.toUtc().toIso8601String(),
    };
  }
}
