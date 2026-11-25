import 'package:flutter/material.dart';

import '../data/datos.dart';
import '../data/supabase_service.dart';
import '../models/lectura.dart';

/// Lista de mediciones guardadas en Supabase.
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  late Future<List<Lectura>> _lecturas = obtenerLecturas();

  Future<void> _recargar() async {
    setState(() => _lecturas = obtenerLecturas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: FutureBuilder<List<Lectura>>(
        future: _lecturas,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  mensajeError(snapshot.error!),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final lecturas = snapshot.data!;
          if (lecturas.isEmpty) {
            return const Center(child: Text('No hay mediciones guardadas.'));
          }
          return RefreshIndicator(
            onRefresh: _recargar,
            child: ListView.builder(
              itemCount: lecturas.length,
              itemBuilder: (context, i) {
                final l = lecturas[i];
                final sensor = buscarSensor(l.sensorType);
                return ListTile(
                  leading: Icon(sensor.iconData, color: sensor.color),
                  title: Text(sensor.nombre),
                  subtitle: Text(
                    '${l.resumen}\n${formatearFecha(l.recordedAt)}',
                  ),
                  isThreeLine: true,
                  onTap: () =>
                      Navigator.pushNamed(context, '/detalle', arguments: l),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
