import 'package:flutter/material.dart';

/// Splash con el nombre de la aplicación; pasa a Inicio a los 2 segundos.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/inicio');
    });
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colores.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sensors, size: 96, color: colores.onPrimary),
            const SizedBox(height: 16),
            Text(
              'SensorTrack',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: colores.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
