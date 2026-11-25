import 'package:flutter/material.dart';

import '../models/sensor_info.dart';
import 'dato_fila.dart';

/// Tarjeta con los valores X, Y, Z de un sensor y el botón "Guardar medición".
class TarjetaSensor extends StatelessWidget {
  final SensorInfo sensor;
  final double x;
  final double y;
  final double z;
  final VoidCallback? onGuardar;

  const TarjetaSensor({
    super.key,
    required this.sensor,
    required this.x,
    required this.y,
    required this.z,
    required this.onGuardar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(sensor.iconData, color: sensor.color, size: 32),
              title: Text(sensor.nombre),
              subtitle: Text('${sensor.descripcion} (${sensor.unidad})'),
            ),
            DatoFila('Eje X', x.toStringAsFixed(2)),
            DatoFila('Eje Y', y.toStringAsFixed(2)),
            DatoFila('Eje Z', z.toStringAsFixed(2)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onGuardar,
                icon: const Icon(Icons.save),
                label: const Text('Guardar medición'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
