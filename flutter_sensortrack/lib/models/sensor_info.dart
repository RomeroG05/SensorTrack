import 'package:flutter/material.dart';

/// Sensor del catálogo lib/data/sensores.json.
/// El [id] es el valor que se guarda en la columna sensor_type.
class SensorInfo {
  final String id;
  final String nombre;
  final String descripcion;
  final String unidad;
  final String icono;
  final Color color;

  const SensorInfo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.unidad,
    required this.icono,
    required this.color,
  });

  factory SensorInfo.fromJson(Map<String, dynamic> json) {
    return SensorInfo(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      unidad: json['unidad'],
      icono: json['icono'],
      color: Color(int.parse(json['color'])),
    );
  }

  IconData get iconData {
    switch (icono) {
      case 'acelerometro':
        return Icons.speed;
      case 'giroscopio':
        return Icons.threesixty;
      default:
        return Icons.location_on;
    }
  }
}
