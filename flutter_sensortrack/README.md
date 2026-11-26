# SensorTrack

Aplicación móvil hecha con **Flutter** que lee los sensores del teléfono (acelerómetro, giroscopio y GPS), muestra sus valores en tiempo real y guarda las mediciones en **Supabase**.

> Taller práctico · Desarrollo de Plataformas Móviles

---

## ¿Qué hace la app?

| Pantalla | Qué puedes hacer |
| --- | --- |
| **Splash** | Ver el nombre de la app al abrirla. |
| **Inicio** | Ver si hay conexión con Supabase, qué sensores tiene el teléfono y elegir una opción del menú. |
| **Sensores** | Ver X, Y, Z del acelerómetro y el giroscopio en tiempo real. Guardar una medición o activar el guardado automático cada 5 segundos. |
| **Ubicación** | Obtener latitud, longitud, precisión y hora. Guardarla en Supabase, siempre después de confirmar. |
| **Historial** | Ver todas las mediciones guardadas y tocar una para ver su detalle. |
| **Estadísticas** | Ver el total de registros, los registros por sensor, el mínimo y el máximo del acelerómetro, la última ubicación y un gráfico. |

## Sensores

| Sensor | Qué mide | Paquete |
| --- | --- | --- |
| Acelerómetro | Aceleración en X, Y, Z (m/s²) | `sensors_plus` |
| Giroscopio | Rotación en X, Y, Z (rad/s) | `sensors_plus` |
| GPS | Latitud, longitud y precisión | `geolocator` |

## Tecnologías

- **Flutter / Dart**: la aplicación
- **Supabase**: base de datos en la nube (PostgreSQL)
- **sensors_plus**: acelerómetro y giroscopio
- **geolocator**: GPS y permisos de ubicación
- **fl_chart**: gráfico de estadísticas

---

## Cómo ejecutarla

### 1. Descargar el proyecto

```bash
git clone https://github.com/RomeroG05/SensorTrack.git
cd SensorTrack/flutter_sensortrack
flutter pub get
```

### 2. Crear la base de datos

1. Crea un proyecto en [supabase.com](https://supabase.com/).
2. Ve a **SQL Editor**, pega el contenido de [`sql/sensor_readings.sql`](sql/sensor_readings.sql) y pulsa **Run**.
3. Ve a **Project Settings → API** y copia la **Project URL** y la **Publishable key**.

### 3. Conectar la app

Pega esos dos datos al inicio de [`lib/main.dart`](lib/main.dart):

```dart
const supabaseUrl = 'https://xxxx.supabase.co';
const supabaseKey = 'sb_publishable_xxxx';
```

> Usa solo la clave **pública**. Nunca pongas la clave `secret` en la app.

### 4. Ejecutar en el teléfono

Conecta el teléfono con la **depuración USB** activada y ejecuta:

```bash
flutter run
```

> Usa un teléfono real: los sensores no funcionan bien en el emulador.

---

## Estructura del proyecto

```text
lib/
├── main.dart              Arranque de la app y rutas
├── data/                  Datos
│   ├── sensores.json        Lista de sensores
│   ├── datos.dart           Carga el JSON
│   └── supabase_service.dart  Guardar y consultar en Supabase
├── models/                Clases de datos
│   ├── lectura.dart         Una medición
│   └── sensor_info.dart     Un sensor
├── screens/               Pantallas
│   ├── splash.dart
│   ├── inicio.dart
│   ├── sensores.dart
│   ├── ubicacion.dart
│   ├── historial.dart
│   ├── detalle_lectura.dart
│   └── estadisticas.dart
└── widgets/               Piezas reutilizables
    ├── tarjeta_sensor.dart  Tarjeta con X, Y, Z y botón Guardar
    └── dato_fila.dart       Fila "etiqueta — valor"
sql/sensor_readings.sql    Script de la base de datos
```

**Cómo fluyen los datos:**

```text
Sensores del teléfono ──► Pantallas ──► supabase_service.dart ──► Supabase
                              ▲                                      │
                              └──────────── Historial / Estadísticas ◄┘
```

## Navegación

La app usa **rutas con nombre**. Desde el menú de Inicio se abre cada pantalla:

| Ruta | Pantalla |
| --- | --- |
| `/inicio` | Inicio |
| `/sensores` | Sensores |
| `/ubicacion` | Ubicación |
| `/historial` | Historial |
| `/detalle` | Detalle de un registro (recibe la medición como argumento) |
| `/estadisticas` | Estadísticas |

---

## Base de datos

Todas las mediciones se guardan en la tabla **`sensor_readings`**:

| Campo | Tipo | Para qué sirve |
| --- | --- | --- |
| `id` | UUID | Identificador (lo genera Supabase) |
| `sensor_type` | TEXT | `accelerometer`, `gyroscope` o `gps` |
| `x`, `y`, `z` | DOUBLE PRECISION | Valores del acelerómetro o del giroscopio |
| `latitude`, `longitude` | DOUBLE PRECISION | Coordenadas del GPS |
| `accuracy` | DOUBLE PRECISION | Precisión del GPS en metros |
| `recorded_at` | TIMESTAMPTZ | Fecha y hora de la captura |

**Seguridad (RLS):** la app solo puede **consultar** y **guardar** registros. No puede modificarlos ni borrarlos.

---

## Detalles importantes

- **Ahorro de datos:** el guardado automático guarda cada 5 segundos y se activa y desactiva con un interruptor.
- **Sensores:** al salir de la pantalla de Sensores se deja de leerlos (los *streams* se cancelan en `dispose()`).
- **Privacidad:** la ubicación solo se obtiene cuando la pides, y solo se guarda si confirmas en un diálogo.
- **Errores:** si no hay internet, falta un permiso o un sensor no existe, la app muestra un mensaje claro en lugar de cerrarse.
- **Permisos de Android:** internet y ubicación. El permiso de ubicación se pide solo al usarla.

## Pruebas

```bash
flutter test     # pruebas de los modelos y del catálogo de sensores
flutter analyze  # revisión del código
```

---

## Requisitos del taller

| Requisito | Cumplido en |
| --- | --- |
| 3 sensores | Acelerómetro, giroscopio y GPS |
| Splash, menú, conexión y sensores disponibles | `splash.dart`, `inicio.dart` |
| Datos en tiempo real | `sensores.dart`, `ubicacion.dart` |
| Botón "Guardar medición" y registro en Supabase | `tarjeta_sensor.dart`, `supabase_service.dart` |
| Historial y detalle | `historial.dart`, `detalle_lectura.dart` |
| Estadísticas y gráfico | `estadisticas.dart` |
| Iniciar y detener el monitoreo | Interruptor de guardado automático |
| Permisos, errores y privacidad | `ubicacion.dart`, `supabase_service.dart` |
| Políticas RLS y script SQL | `sql/sensor_readings.sql` |

## Evidencias

Pruebas en un dispositivo físico (Samsung Galaxy S24 Ultra):

- Pantallas de la app funcionando en el teléfono
- Captura de los sensores en tiempo real
- Registros guardados en Supabase (Table Editor)

---

