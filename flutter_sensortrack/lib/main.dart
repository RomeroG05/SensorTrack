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
import 'screens/impactos.dart';

// Datos del proyecto en Supabase (Project Settings → API).
const supabaseUrl = 'https://ahdwvgmuhotfuqgatssq.supabase.co';
const supabaseKey = 'sb_publishable_Ryb06cnakJARRi4s-Hr9pQ_-Naf8BZt';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await cargarDatos();

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);

  // La sesión anónima es opcional: si falla (sin internet o desactivada en
  // Supabase), la app arranca igual y usa el rol anon de la clave pública.
  final auth = Supabase.instance.client.auth;
  if (auth.currentSession == null) {
    try {
      await auth.signInAnonymously().timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Sesión anónima no disponible: $e');
    }
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
        '/impactos': (context) => const ImpactosScreen(),
      },
    );
  }
}
