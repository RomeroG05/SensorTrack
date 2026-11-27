import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../data/datos.dart';
import '../data/supabase_service.dart';

/// Pantalla principal: menú, estado de conexión con Supabase y
/// sensores disponibles en el dispositivo.
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  bool? _conectado; // null = verificando
  final Map<String, bool> _disponibles = {};

  @override
  void initState() {
    super.initState();
    _verificar();
  }

  Future<void> _verificar() async {
    setState(() => _conectado = null);
    final conectado = await verificarConexion();
    final resultados = await Future.wait([
      _sensorResponde(accelerometerEventStream()),
      _sensorResponde(gyroscopeEventStream()),
      Geolocator.isLocationServiceEnabled(),
    ]);
    if (!mounted) return;
    setState(() {
      _conectado = conectado;
      _disponibles['accelerometer'] = resultados[0];
      _disponibles['gyroscope'] = resultados[1];
      _disponibles['gps'] = resultados[2];
    });
  }

  /// Un sensor está disponible si envía un dato en menos de 2 segundos.
  Future<bool> _sensorResponde(Stream stream) async {
    try {
      await stream.first.timeout(const Duration(seconds: 2));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SensorTrack'),
        actions: [
          IconButton(onPressed: _verificar, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: _conectado == null
                  ? const CircularProgressIndicator()
                  : Icon(
                      _conectado! ? Icons.cloud_done : Icons.cloud_off,
                      color: _conectado! ? Colors.green : Colors.red,
                      size: 32,
                    ),
              title: const Text('Supabase'),
              subtitle: Text(
                _conectado == null
                    ? 'Verificando conexión...'
                    : _conectado!
                    ? 'Conectado'
                    : 'Sin conexión',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Menú', style: Theme.of(context).textTheme.titleMedium),
          _opcion(Icons.sensors, 'Sensores', '/sensores'),
          _opcion(Icons.location_on, 'Ubicación', '/ubicacion'),
          _opcion(Icons.history, 'Historial', '/historial'),
          _opcion(Icons.bar_chart, 'Estadísticas', '/estadisticas'),
          _opcion(
            Icons.warning_amber_rounded,
            'Detección de impactos',
            '/impactos',
          ),
          const SizedBox(height: 16),
          Text(
            'Sensores disponibles',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final s in sensores)
            Card(
              child: ListTile(
                leading: Icon(s.iconData, color: s.color),
                title: Text(s.nombre),
                subtitle: Text(s.descripcion),
                trailing: _disponibles[s.id] == null
                    ? null
                    : Icon(
                        _disponibles[s.id]! ? Icons.check_circle : Icons.cancel,
                        color: _disponibles[s.id]! ? Colors.green : Colors.red,
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _opcion(IconData icono, String titulo, String ruta) {
    return Card(
      child: ListTile(
        leading: Icon(icono),
        title: Text(titulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, ruta),
      ),
    );
  }
}
