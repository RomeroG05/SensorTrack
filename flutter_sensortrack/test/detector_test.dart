import 'package:flutter_sensortrack/data/detector_impacto.dart';
import 'package:flutter_sensortrack/models/evento_aceleracion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 11, 27, 10, 0, 0);

  test('en reposo (solo gravedad) no hay evento', () {
    final d = DetectorImpacto();
    expect(d.analizar(0, 0, 9.81, t0), isNull);
    expect(DetectorImpacto.intensidad(0, 0, 9.81), closeTo(0, 1e-9));
  });

  test('movimiento normal (intensidad 2–5 m/s²) no supera el umbral', () {
    final d = DetectorImpacto();
    // |a| = √(3² + 12²) ≈ 12.37 → intensidad ≈ 2.56
    expect(d.analizar(0, 3, 12, t0), isNull);
  });

  test('un golpe supera el umbral y genera un evento', () {
    final d = DetectorImpacto();
    // |a| = √(15² + 20²) = 25 → intensidad = 15.19
    final e = d.analizar(0, 15, 20, t0)!;
    expect(e.magnitud, closeTo(25, 1e-9));
    expect(e.intensidad, closeTo(15.19, 1e-9));
    expect(e.umbral, DetectorImpacto.umbral);
    expect(e.detectadoEn, t0);
  });

  test('el mismo golpe no se registra dos veces (espera de 2 s)', () {
    final d = DetectorImpacto();
    expect(d.analizar(0, 15, 20, t0), isNotNull);
    final dentroDeEspera = t0.add(const Duration(milliseconds: 300));
    expect(d.analizar(0, 18, 20, dentroDeEspera), isNull);
    final despues = t0.add(const Duration(milliseconds: 2500));
    expect(d.analizar(0, 18, 20, despues), isNotNull);
  });

  test('el orden de los ejes no cambia el resultado (orientación)', () {
    expect(
      DetectorImpacto.intensidad(20, 0, 15),
      DetectorImpacto.intensidad(0, 15, 20),
    );
  });

  test('EventoAceleracion: toMap y fromMap', () {
    final e = EventoAceleracion(
      x: 1,
      y: 15,
      z: 20,
      magnitud: 25.02,
      intensidad: 15.21,
      umbral: 12,
      detectadoEn: t0,
    );
    final m = e.toMap();
    expect(m.containsKey('id'), isFalse);
    expect(m['intensity'], 15.21);

    final leido = EventoAceleracion.fromMap({...m, 'id': 'abc'});
    expect(leido.id, 'abc');
    expect(leido.magnitud, 25.02);
    expect(leido.detectadoEn, t0);
  });
}
