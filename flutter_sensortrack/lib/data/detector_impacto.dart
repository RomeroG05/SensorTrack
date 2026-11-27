import 'dart:math';

import '../models/evento_aceleracion.dart';

/// Detecta cambios bruscos en la aceleración (golpes, caídas, sacudidas).
///
/// En reposo el acelerómetro solo mide la gravedad, así que la magnitud
/// |a| = √(x² + y² + z²) vale ≈ 9.81 m/s² sin importar cómo esté el teléfono.
/// La intensidad es cuánto se aleja |a| de ese valor:
///
///     intensidad = | |a| − 9.81 |
///
/// Se usa la magnitud y no cada eje por separado porque no depende de la
/// orientación del teléfono: un golpe se detecta igual si está vertical,
/// horizontal o en el bolsillo.
class DetectorImpacto {
  /// Gravedad estándar (m/s²).
  static const gravedad = 9.81;

  /// Umbral de intensidad (m/s²).
  ///
  /// Justificación:
  /// - En reposo la intensidad es cercana a 0.
  /// - Manipular el teléfono o caminar produce variaciones de 2 a 5 m/s².
  /// - Un golpe, una caída sobre una superficie o una sacudida fuerte
  ///   supera los 12 m/s².
  /// Con 12 m/s² el uso normal no genera alertas y los cambios bruscos sí
  /// (más del doble del máximo de caminar, para dejar margen).
  /// Equivale a |a| ≈ 21.8 m/s² (≈ 2.2 g), dentro del rango de 2–3 g que se
  /// usa habitualmente para detectar impactos y caídas.
  static const umbral = 30.0;

  /// Tiempo mínimo entre dos eventos.
  ///
  /// Un solo golpe produce varias muestras seguidas sobre el umbral (el
  /// teléfono vibra durante unos cientos de milisegundos). Con esta espera se
  /// registra como un único evento y no se llena la base de datos.
  static const espera = Duration(seconds: 2);

  DateTime? _ultimoEvento;

  static double magnitud(double x, double y, double z) =>
      sqrt(x * x + y * y + z * z);

  static double intensidad(double x, double y, double z) =>
      (magnitud(x, y, z) - gravedad).abs();

  /// Analiza una muestra del acelerómetro.
  ///
  /// Devuelve un evento si la intensidad supera el umbral y ya pasó el tiempo
  /// de [espera] desde el último evento; si no, devuelve null.
  EventoAceleracion? analizar(double x, double y, double z, [DateTime? ahora]) {
    ahora ??= DateTime.now();
    final i = intensidad(x, y, z);
    if (i <= umbral) return null;

    final ultimo = _ultimoEvento;
    if (ultimo != null && ahora.difference(ultimo) < espera) return null;

    _ultimoEvento = ahora;
    return EventoAceleracion(
      x: x,
      y: y,
      z: z,
      magnitud: magnitud(x, y, z),
      intensidad: i,
      umbral: umbral,
      detectadoEn: ahora,
    );
  }
}
