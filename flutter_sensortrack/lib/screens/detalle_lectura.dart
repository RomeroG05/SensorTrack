import 'package:flutter/material.dart';

import '../data/datos.dart';
import '../models/lectura.dart';
import '../widgets/dato_fila.dart';

/// Detalle de un registro. Recibe la Lectura como argumento de la ruta.
class DetalleLectura extends StatelessWidget {
  const DetalleLectura({super.key});

  @override
  Widget build(BuildContext context) {
    final l = ModalRoute.of(context)!.settings.arguments as Lectura;
    final sensor = buscarSensor(l.sensorType);
    String v(double? n, [int decimales = 4]) =>
        n == null ? '-' : n.toStringAsFixed(decimales);

    return Scaffold(
      appBar: AppBar(title: Text(sensor.nombre)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(sensor.iconData, color: sensor.color, size: 48),
                const SizedBox(height: 8),
                DatoFila('Tipo de sensor', sensor.nombre),
                DatoFila('Fecha y hora', formatearFecha(l.recordedAt)),
                if (l.tieneUbicacion) ...[
                  DatoFila('Latitud', v(l.latitude, 6)),
                  DatoFila('Longitud', v(l.longitude, 6)),
                  DatoFila('Precisión', '${v(l.accuracy, 1)} m'),
                ] else ...[
                  DatoFila('Eje X (${sensor.unidad})', v(l.x)),
                  DatoFila('Eje Y (${sensor.unidad})', v(l.y)),
                  DatoFila('Eje Z (${sensor.unidad})', v(l.z)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
