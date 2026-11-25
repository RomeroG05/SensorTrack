import 'dart:convert';
import 'dart:io';

import 'package:flutter_sensortrack/models/lectura.dart';
import 'package:flutter_sensortrack/models/sensor_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Lectura.fromMap lee una fila de Supabase', () {
    final l = Lectura.fromMap({
      'id': 'abc',
      'sensor_type': 'accelerometer',
      'x': 1,
      'y': 2.5,
      'z': -3,
      'recorded_at': '2026-11-25T18:30:00+00:00',
    });
    expect(l.x, 1.0);
    expect(l.z, -3.0);
    expect(l.tieneUbicacion, isFalse);
    expect(l.recordedAt.toUtc(), DateTime.utc(2026, 11, 25, 18, 30));
  });

  test('Lectura.toMap no envía id y guarda la fecha en UTC', () {
    final fecha = DateTime(2026, 1, 2, 3, 4, 5);
    final m = Lectura(
      sensorType: 'gps',
      latitude: -1,
      longitude: -78,
      recordedAt: fecha,
    ).toMap();
    expect(m.containsKey('id'), isFalse);
    expect(DateTime.parse(m['recorded_at']), fecha.toUtc());
  });

  test('formatearFecha', () {
    expect(
      formatearFecha(DateTime(2026, 3, 7, 9, 5, 2)),
      '07/03/2026 09:05:02',
    );
  });

  test('sensores.json contiene acelerómetro, giroscopio y GPS', () {
    final lista =
        jsonDecode(File('lib/data/sensores.json').readAsStringSync()) as List;
    final ids = lista.map((e) => SensorInfo.fromJson(e).id);
    expect(ids, ['accelerometer', 'gyroscope', 'gps']);
  });
}
