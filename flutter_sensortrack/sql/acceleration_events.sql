-- SensorTrack · Tabla de eventos de cambio brusco de aceleración
-- Ejecutar en Supabase → SQL Editor → Run

CREATE TABLE acceleration_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    x DOUBLE PRECISION NOT NULL,           -- valores del acelerómetro (m/s²)
    y DOUBLE PRECISION NOT NULL,           -- en el momento del evento
    z DOUBLE PRECISION NOT NULL,
    magnitude DOUBLE PRECISION NOT NULL,   -- |a| = √(x² + y² + z²)
    intensity DOUBLE PRECISION NOT NULL,   -- | |a| − 9.81 |, lo que se compara con el umbral
    threshold DOUBLE PRECISION NOT NULL,   -- umbral usado en la detección
    detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Políticas RLS: la app solo puede consultar e insertar (no editar ni borrar).
ALTER TABLE acceleration_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir lectura" ON acceleration_events
    FOR SELECT TO anon, authenticated USING (true);

CREATE POLICY "Permitir insercion" ON acceleration_events
    FOR INSERT TO anon, authenticated WITH CHECK (true);

GRANT SELECT, INSERT ON acceleration_events TO anon, authenticated;
