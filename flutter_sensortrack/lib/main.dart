import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/datos.dart';
import 'screens/splash.dart';
import 'screens/inicio.dart';
import 'screens/sensores.dart';
import 'screens/ubicacion.dart';
import 'screens/historial.dart';
import 'screens/detalle_lectura.dart';
import 'screens/estadisticas.dart';

// Datos del proyecto en Supabase (Project Settings → API).
const supabaseUrl = 'https://lphqukzthmwnasrqwyjd.supabase.co';
const supabaseKey = 'sb_publishable_Q-9mKFtZD2_l-wLtjp6JGA_njKIDCXe';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await cargarDatos();

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);

  final supabase = Supabase.instance.client;

  if (supabase.auth.currentSession == null) {
    await supabase.auth.signInAnonymously();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SensorTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F4E79)),
      ),
      home: const SplashScreen(),
      routes: {
        '/inicio': (context) => const InicioScreen(),
        '/sensores': (context) => const SensoresScreen(),
        '/ubicacion': (context) => const UbicacionScreen(),
        '/historial': (context) => const HistorialScreen(),
        '/detalle': (context) => const DetalleLectura(),
        '/estadisticas': (context) => const EstadisticasScreen(),
      },
    );
  }
}
