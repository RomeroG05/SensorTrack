import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../data/datos.dart';
import '../data/supabase_service.dart';
import '../models/lectura.dart';
import '../widgets/tarjeta_sensor.dart';

/// Lectura en tiempo real del acelerómetro y el giroscopio.
class SensoresScreen extends StatefulWidget {
  const SensoresScreen({super.key});

  @override
  State<SensoresScreen> createState() => _SensoresScreenState();
}

class _SensoresScreenState extends State<SensoresScreen> {
  double ax = 0, ay = 0, az = 0; // acelerómetro
  double gx = 0, gy = 0, gz = 0; // giroscopio
  String? _error;

  StreamSubscription? _subAcel;
  StreamSubscription? _subGiro;
  Timer? _monitoreo; // guardado automático cada 5 s

  @override
  void initState() {
    super.initState();
    _subAcel =
        accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval)
            .listen(
              (e) {
                setState(() {
                  ax = e.x;
                  ay = e.y;
                  az = e.z;
                });
              },
              onError: (_) =>
                  setState(() => _error = 'Acelerómetro no disponible'),
            );

    _subGiro = gyroscopeEventStream(samplingPeriod: SensorInterval.uiInterval)
        .listen((e) {
          setState(() {
            gx = e.x;
            gy = e.y;
            gz = e.z;
          });
        }, onError: (_) => setState(() => _error = 'Giroscopio no disponible'));
  }

  @override
  void dispose() {
    _subAcel?.cancel();
    _subGiro?.cancel();
    _monitoreo?.cancel();
    super.dispose();
  }

  Future<void> _guardar(List<Lectura> lecturas) async {
    try {
      for (final l in lecturas) {
        await guardarLectura(l);
      }
      _mensaje('Medición guardada');
    } catch (e) {
      _monitoreo?.cancel();
      setState(() => _monitoreo = null);
      _mensaje(mensajeError(e));
    }
  }

  Lectura get _acelerometro =>
      Lectura(sensorType: 'accelerometer', x: ax, y: ay, z: az);

  Lectura get _giroscopio =>
      Lectura(sensorType: 'gyroscope', x: gx, y: gy, z: gz);

  /// Inicia o detiene el guardado automático para no guardar datos de más.
  void _alternarMonitoreo(bool activo) {
    setState(() {
      _monitoreo?.cancel();
      _monitoreo = activo
          ? Timer.periodic(
              const Duration(seconds: 5),
              (_) => _guardar([_acelerometro, _giroscopio]),
            )
          : null;
    });
  }

  void _mensaje(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensores')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          Card(
            child: SwitchListTile(
              title: const Text('Monitoreo automático'),
              subtitle: const Text('Guarda ambos sensores cada 5 segundos'),
              value: _monitoreo != null,
              onChanged: _alternarMonitoreo,
            ),
          ),
          TarjetaSensor(
            sensor: buscarSensor('accelerometer'),
            x: ax,
            y: ay,
            z: az,
            onGuardar: () => _guardar([_acelerometro]),
          ),
          TarjetaSensor(
            sensor: buscarSensor('gyroscope'),
            x: gx,
            y: gy,
            z: gz,
            onGuardar: () => _guardar([_giroscopio]),
          ),
        ],
      ),
    );
  }
}
