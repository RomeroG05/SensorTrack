import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../data/detector_impacto.dart';
import '../data/supabase_service.dart';
import '../models/evento_aceleracion.dart';
import '../models/lectura.dart';

/// Detección de cambios bruscos de aceleración: monitor en tiempo real,
/// alerta visual, registro en Supabase e historial de eventos.
class ImpactosScreen extends StatefulWidget {
  const ImpactosScreen({super.key});

  @override
  State<ImpactosScreen> createState() => _ImpactosScreenState();
}

class _ImpactosScreenState extends State<ImpactosScreen> {
  final _detector = DetectorImpacto();

  /// Intensidad actual. Se actualiza con cada muestra (50 por segundo) sin
  /// redibujar toda la pantalla: solo el monitor escucha este valor.
  final _intensidad = ValueNotifier<double>(0);

  StreamSubscription? _sub;
  bool _activo = true;
  String? _errorSensor;

  /// Evento que se muestra en la alerta (null = sin alerta).
  EventoAceleracion? _alerta;
  Timer? _timerAlerta;

  List<EventoAceleracion> _eventos = [];
  bool _cargando = true;
  String? _errorHistorial;

  @override
  void initState() {
    super.initState();
    // gameInterval (~20 ms): un golpe dura pocas decenas de milisegundos y con
    // un muestreo más lento se podría perder el pico de aceleración.
    _sub = accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
        .listen(
          _analizar,
          onError: (_) =>
              setState(() => _errorSensor = 'Acelerómetro no disponible'),
        );
    _cargarHistorial();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _timerAlerta?.cancel();
    _intensidad.dispose();
    super.dispose();
  }

  void _analizar(AccelerometerEvent e) {
    _intensidad.value = DetectorImpacto.intensidad(e.x, e.y, e.z);
    if (!_activo) return;
    final evento = _detector.analizar(e.x, e.y, e.z);
    if (evento != null) _onEvento(evento);
  }

  Future<void> _onEvento(EventoAceleracion evento) async {
    // Alerta visual (y vibración) durante 3 segundos.
    HapticFeedback.heavyImpact();
    setState(() => _alerta = evento);
    _timerAlerta?.cancel();
    _timerAlerta = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _alerta = null);
    });

    // Registro en Supabase.
    try {
      await guardarEvento(evento);
      if (!mounted) return;
      setState(() => _eventos.insert(0, evento));
    } catch (e) {
      _mensaje('Evento detectado, pero no se guardó. ${mensajeError(e)}');
    }
  }

  Future<void> _cargarHistorial() async {
    setState(() {
      _cargando = true;
      _errorHistorial = null;
    });
    try {
      final eventos = await obtenerEventos();
      if (!mounted) return;
      setState(() => _eventos = eventos);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorHistorial = mensajeError(e));
    }
    if (mounted) setState(() => _cargando = false);
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
      backgroundColor: _alerta != null ? Colors.red.shade50 : null,
      appBar: AppBar(
        title: const Text('Detección de impactos'),
        backgroundColor: _alerta != null ? Colors.red : null,
        foregroundColor: _alerta != null ? Colors.white : null,
      ),
      body: RefreshIndicator(
        onRefresh: _cargarHistorial,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_errorSensor != null)
              Text(_errorSensor!, style: const TextStyle(color: Colors.red)),
            _monitor(),
            const SizedBox(height: 8),
            _tarjetaAlerta(),
            const SizedBox(height: 8),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Historial de eventos (${_eventos.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: _cargarHistorial,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            ..._historial(),
          ],
        ),
      ),
    );
  }

  /// Intensidad en tiempo real comparada con el umbral.
  Widget _monitor() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Intensidad actual  | |a| − 9.81 |'),
            ValueListenableBuilder<double>(
              valueListenable: _intensidad,
              builder: (context, i, _) {
                final nivel = (i / DetectorImpacto.umbral).clamp(0.0, 1.0);
                final color = nivel >= 1
                    ? Colors.red
                    : nivel > 0.6
                    ? Colors.orange
                    : Colors.green;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${i.toStringAsFixed(2)} m/s²',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: color, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: nivel,
                      color: color,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              'Umbral: ${DetectorImpacto.umbral.toStringAsFixed(1)} m/s²',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Detección activa'),
              value: _activo,
              onChanged: (v) => setState(() => _activo = v),
            ),
          ],
        ),
      ),
    );
  }

  /// Alerta visual: tarjeta roja mientras dura la alerta.
  Widget _tarjetaAlerta() {
    final e = _alerta;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: e != null ? Colors.red : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            e != null
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            color: e != null ? Colors.white : Colors.grey.shade700,
            size: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: e != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¡Cambio brusco detectado!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Intensidad ${e.intensidad.toStringAsFixed(2)} m/s² '
                        '(umbral ${e.umbral.toStringAsFixed(1)})',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  )
                : Text(
                    _activo
                        ? 'Sin alertas. Agita el teléfono con fuerza para probar.'
                        : 'Detección en pausa.',
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _historial() {
    if (_cargando) {
      return const [Center(child: CircularProgressIndicator())];
    }
    if (_errorHistorial != null) {
      return [
        Text(_errorHistorial!, style: const TextStyle(color: Colors.red)),
      ];
    }
    if (_eventos.isEmpty) {
      return const [Text('Todavía no hay eventos detectados.')];
    }
    return [
      for (final e in _eventos)
        Card(
          child: ListTile(
            leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
            title: Text('Intensidad ${e.intensidad.toStringAsFixed(2)} m/s²'),
            subtitle: Text(
              'X ${e.x.toStringAsFixed(2)}  Y ${e.y.toStringAsFixed(2)}  '
              'Z ${e.z.toStringAsFixed(2)}  ·  |a| ${e.magnitud.toStringAsFixed(2)}\n'
              '${formatearFecha(e.detectadoEn)}',
            ),
            isThreeLine: true,
          ),
        ),
    ];
  }
}
