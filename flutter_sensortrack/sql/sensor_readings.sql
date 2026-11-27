-- SensorTrack · Script de creación de la tabla
-- Ejecutar en Supabase → SQL Editor → Run

CREATE TABLE sensor_readings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sensor_type TEXT NOT NULL,
    x DOUBLE PRECISION,
    y DOUBLE PRECISION,
    z DOUBLE PRECISION,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    accuracy DOUBLE PRECISION,
    recorded_at TIMESTAMPTZ DEFAULT NOW()
);

-- Políticas RLS: la app solo puede consultar e insertar (no editar ni borrar).
-- Se incluye "authenticated" porque la app inicia sesión anónima
-- (signInAnonymously), y esos usuarios usan el rol authenticated, no anon.
ALTER TABLE sensor_readings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir lectura" ON sensor_readings
    FOR SELECT TO anon, authenticated USING (true);

CREATE POLICY "Permitir insercion" ON sensor_readings
    FOR INSERT TO anon, authenticated WITH CHECK (true);

GRANT SELECT, INSERT ON sensor_readings TO anon, authenticated;
