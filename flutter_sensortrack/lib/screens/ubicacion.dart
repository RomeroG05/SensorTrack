import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../data/supabase_service.dart';
import '../models/lectura.dart';
import '../widgets/dato_fila.dart';

/// Ubicación GPS: latitud, longitud, precisión y fecha/hora de captura.
class UbicacionScreen extends StatefulWidget {
  const UbicacionScreen({super.key});

  @override
  State<UbicacionScreen> createState() => _UbicacionScreenState();
}

class _UbicacionScreenState extends State<UbicacionScreen> {
  Position? _posicion;
  String? _error;
  bool _cargando = false;

  Future<void> _obtenerUbicacion() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw 'Activa la ubicación del dispositivo.';
      }
      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        throw 'Permiso de ubicación denegado.';
      }
      _posicion = await Geolocator.getCurrentPosition();
    } catch (e) {
      _error = e.toString();
    }
    setState(() => _cargando = false);
  }

  Future<void> _guardar() async {
    // No se guarda la ubicación sin autorización del usuario.
    final autoriza = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guardar ubicación'),
        content: const Text(
          '¿Autorizas guardar tu ubicación actual en la base de datos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, guardar'),
          ),
        ],
      ),
    );
    if (autoriza != true) return;

    String mensaje;
    try {
      await guardarLectura(
        Lectura(
          sensorType: 'gps',
          latitude: _posicion!.latitude,
          longitude: _posicion!.longitude,
          accuracy: _posicion!.accuracy,
          recordedAt: _posicion!.timestamp.toLocal(),
        ),
      );
      mensaje = 'Ubicación guardada';
    } catch (e) {
      mensaje = mensajeError(e);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final p = _posicion;
    return Scaffold(
      appBar: AppBar(title: const Text('Ubicación')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: p == null
                  ? const Text('Pulsa "Obtener ubicación" para leer el GPS.')
                  : Column(
                      children: [
                        DatoFila('Latitud', p.latitude.toStringAsFixed(6)),
                        DatoFila('Longitud', p.longitude.toStringAsFixed(6)),
                        DatoFila(
                          'Precisión',
                          '${p.accuracy.toStringAsFixed(1)} m',
                        ),
                        DatoFila(
                          'Fecha y hora',
                          formatearFecha(p.timestamp.toLocal()),
                        ),
                      ],
                    ),
            ),
          ),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _cargando ? null : _obtenerUbicacion,
            icon: const Icon(Icons.gps_fixed),
            label: Text(_cargando ? 'Buscando...' : 'Obtener ubicación'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: p == null ? null : _guardar,
            icon: const Icon(Icons.save),
            label: const Text('Guardar ubicación'),
          ),
        ],
      ),
    );
  }
}
