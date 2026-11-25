/// Una fila de la tabla sensor_readings.
///
/// Acelerómetro y giroscopio usan x, y, z.
/// GPS usa latitude, longitude y accuracy.
class Lectura {
  final String? id;
  final String sensorType;
  final double? x;
  final double? y;
  final double? z;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final DateTime recordedAt;

  Lectura({
    this.id,
    required this.sensorType,
    this.x,
    this.y,
    this.z,
    this.latitude,
    this.longitude,
    this.accuracy,
    DateTime? recordedAt,
  }) : recordedAt = recordedAt ?? DateTime.now();

  factory Lectura.fromMap(Map<String, dynamic> map) {
    return Lectura(
      id: map['id'],
      sensorType: map['sensor_type'],
      x: (map['x'] as num?)?.toDouble(),
      y: (map['y'] as num?)?.toDouble(),
      z: (map['z'] as num?)?.toDouble(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      accuracy: (map['accuracy'] as num?)?.toDouble(),
      recordedAt: DateTime.parse(map['recorded_at']).toLocal(),
    );
  }

  /// Datos para insertar en Supabase (el id lo genera la base de datos).
  Map<String, dynamic> toMap() {
    return {
      'sensor_type': sensorType,
      'x': x,
      'y': y,
      'z': z,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'recorded_at': recordedAt.toUtc().toIso8601String(),
    };
  }

  bool get tieneUbicacion => latitude != null && longitude != null;

  /// Valores en una línea, para listas.
  String get resumen {
    if (tieneUbicacion) {
      return 'Lat ${latitude!.toStringAsFixed(6)}, Lon ${longitude!.toStringAsFixed(6)}';
    }
    return 'X ${x?.toStringAsFixed(2)}  Y ${y?.toStringAsFixed(2)}  Z ${z?.toStringAsFixed(2)}';
  }
}

/// Formato dd/MM/yyyy HH:mm:ss.
String formatearFecha(DateTime f) {
  String d(int n) => n.toString().padLeft(2, '0');
  return '${d(f.day)}/${d(f.month)}/${f.year} ${d(f.hour)}:${d(f.minute)}:${d(f.second)}';
}
