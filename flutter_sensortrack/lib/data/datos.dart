import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/sensor_info.dart';

/// Catálogo de sensores leído de lib/data/sensores.json.
List<SensorInfo> sensores = [];

/// Carga los datos JSON. Se llama una vez desde main().
Future<void> cargarDatos() async {
  final texto = await rootBundle.loadString('lib/data/sensores.json');
  final lista = jsonDecode(texto) as List;
  sensores = lista.map((e) => SensorInfo.fromJson(e)).toList();
}

/// Devuelve el sensor cuyo id coincide con el `sensor_type` guardado.
SensorInfo buscarSensor(String id) => sensores.firstWhere((s) => s.id == id);
