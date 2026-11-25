import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/datos.dart';
import '../data/supabase_service.dart';
import '../models/lectura.dart';
import '../widgets/dato_fila.dart';

/// Estadísticas calculadas a partir de los registros de Supabase.
class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final Future<List<Lectura>> _lecturas = obtenerLecturas();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
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
          return _contenido(snapshot.data!);
        },
      ),
    );
  }

  Widget _contenido(List<Lectura> lecturas) {
    final acel = lecturas
        .where((l) => l.sensorType == 'accelerometer')
        .toList();
    final gps = lecturas.where((l) => l.sensorType == 'gps').toList();

    String minimo(Iterable<double> v) =>
        v.isEmpty ? '-' : v.reduce(min).toStringAsFixed(2);
    String maximo(Iterable<double> v) =>
        v.isEmpty ? '-' : v.reduce(max).toStringAsFixed(2);
    final xs = acel.map((l) => l.x!),
        ys = acel.map((l) => l.y!),
        zs = acel.map((l) => l.z!);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _tarjeta('Registros', [
          DatoFila('Total de registros', '${lecturas.length}'),
          for (final s in sensores)
            DatoFila(
              s.nombre,
              '${lecturas.where((l) => l.sensorType == s.id).length}',
            ),
        ]),
        _tarjeta('Acelerómetro (mín / máx)', [
          DatoFila('Eje X', '${minimo(xs)} / ${maximo(xs)}'),
          DatoFila('Eje Y', '${minimo(ys)} / ${maximo(ys)}'),
          DatoFila('Eje Z', '${minimo(zs)} / ${maximo(zs)}'),
        ]),
        _tarjeta('Última ubicación registrada', [
          if (gps.isEmpty)
            const Text('Sin ubicaciones guardadas.')
          else ...[
            DatoFila('Latitud', gps.first.latitude!.toStringAsFixed(6)),
            DatoFila('Longitud', gps.first.longitude!.toStringAsFixed(6)),
            DatoFila('Fecha y hora', formatearFecha(gps.first.recordedAt)),
          ],
        ]),
        _tarjeta('Evolución del acelerómetro (últimas 30)', [
          SizedBox(
            height: 220,
            child: _grafico(acel.take(30).toList().reversed.toList()),
          ),
          const Text('Rojo: X   Verde: Y   Azul: Z'),
        ]),
      ],
    );
  }

  /// Gráfico de líneas con los ejes X, Y, Z en orden cronológico.
  Widget _grafico(List<Lectura> datos) {
    if (datos.isEmpty) return const Center(child: Text('Sin datos'));

    LineChartBarData linea(double? Function(Lectura) valor, Color color) {
      return LineChartBarData(
        spots: [
          for (var i = 0; i < datos.length; i++)
            FlSpot(i.toDouble(), valor(datos[i])!),
        ],
        color: color,
        dotData: const FlDotData(show: false),
      );
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          linea((l) => l.x, Colors.red),
          linea((l) => l.y, Colors.green),
          linea((l) => l.z, Colors.blue),
        ],
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(),
          rightTitles: AxisTitles(),
          bottomTitles: AxisTitles(),
        ),
      ),
    );
  }

  Widget _tarjeta(String titulo, List<Widget> hijos) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            ...hijos,
          ],
        ),
      ),
    );
  }
}
