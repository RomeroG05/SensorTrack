import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lectura.dart';

/// Operaciones sobre la tabla sensor_readings de Supabase.
const tabla = 'sensor_readings';

SupabaseClient get _db => Supabase.instance.client;

/// Guarda una medición.
Future<void> guardarLectura(Lectura lectura) async {
  await _db.from(tabla).insert(lectura.toMap());
}

/// Consulta las mediciones, de la más reciente a la más antigua.
Future<List<Lectura>> obtenerLecturas() async {
  final filas = await _db
      .from(tabla)
      .select()
      .order('recorded_at', ascending: false)
      .limit(1000);
  return filas.map(Lectura.fromMap).toList();
}

/// Devuelve true si Supabase responde y la tabla es accesible.
Future<bool> verificarConexion() async {
  try {
    await _db
        .from(tabla)
        .select('id')
        .limit(1)
        .timeout(const Duration(seconds: 10));
    return true;
  } catch (_) {
    return false;
  }
}

/// Convierte un error de Supabase o de red en un mensaje para el usuario.
String mensajeError(Object error) {
  if (error is PostgrestException) return 'Error de Supabase: ${error.message}';
  return 'No se pudo conectar con Supabase. Revisa tu conexión a internet.';
}
