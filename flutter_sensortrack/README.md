# SensorTrack

Aplicación móvil en **Flutter** que lee el acelerómetro, el giroscopio y el GPS del dispositivo, muestra los valores en tiempo real y guarda las mediciones en **Supabase** para consultarlas como historial y estadísticas.

Taller práctico · Desarrollo de Plataformas Móviles.

## Pantallas

| Ruta | Pantalla | Contenido |
| --- | --- | --- |
| (inicio) | Splash | Nombre de la aplicación |
| `/inicio` | Inicio | Menú, estado de conexión con Supabase y sensores disponibles |
| `/sensores` | Sensores | Acelerómetro y giroscopio en tiempo real, botón **Guardar medición** y monitoreo automático (cada 5 s, se inicia y detiene) |
| `/ubicacion` | Ubicación | Latitud, longitud, precisión y fecha/hora; guardar con autorización del usuario |
| `/historial` | Historial | Registros guardados en Supabase |
| `/detalle` | Detalle | Detalle del registro seleccionado (recibe la `Lectura` como argumento) |
| `/estadisticas` | Estadísticas | Total, mediciones por sensor, mín/máx del acelerómetro, última ubicación y gráfico |

## Estructura

```text
lib/
├── main.dart                  Inicializa Supabase, carga los datos y define las rutas
├── data/
│   ├── sensores.json          Catálogo de sensores
│   ├── datos.dart             cargarDatos(): lee sensores.json
│   └── supabase_service.dart  guardarLectura, obtenerLecturas, verificarConexion
├── models/
│   ├── lectura.dart           Fila de la tabla sensor_readings
│   └── sensor_info.dart       Sensor del catálogo
├── screens/
│   ├── splash.dart
│   ├── inicio.dart
│   ├── sensores.dart
│   ├── ubicacion.dart
│   ├── historial.dart
│   ├── detalle_lectura.dart
│   └── estadisticas.dart
└── widgets/
    ├── tarjeta_sensor.dart    Valores X, Y, Z + botón Guardar medición
    └── dato_fila.dart         Fila etiqueta / valor
```

Las pantallas leen los sensores con `sensors_plus` y `geolocator`, y guardan o consultan los datos a través de `supabase_service.dart`. Los streams de sensores se cancelan en `dispose()`.

## Tecnologías

| Paquete | Uso |
| --- | --- |
| `supabase_flutter` | Backend y base de datos PostgreSQL |
| `sensors_plus` | Acelerómetro y giroscopio |
| `geolocator` | Ubicación GPS y permisos |
| `fl_chart` | Gráfico de evolución |

## Puesta en marcha

1. Crea un proyecto en <https://supabase.com/>.
2. En **SQL Editor**, ejecuta [`sql/sensor_readings.sql`](sql/sensor_readings.sql). El script crea la tabla y las políticas RLS: la app solo puede consultar e insertar.
3. En **Project Settings → API**, copia la Project URL y la Publishable key, y ponlas en `lib/main.dart`:

   ```dart
   const supabaseUrl = 'https://xxxx.supabase.co';
   const supabaseKey = 'sb_publishable_xxxx';
   ```

4. Conecta el teléfono con la depuración USB activada y ejecuta:

   ```bash
   flutter pub get
   flutter run
   ```

Pruebas: `flutter test`
