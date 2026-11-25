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

-- Políticas RLS: la app (clave pública) solo puede consultar e insertar.
ALTER TABLE sensor_readings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir lectura" ON sensor_readings
    FOR SELECT TO anon USING (true);

CREATE POLICY "Permitir insercion" ON sensor_readings
    FOR INSERT TO anon WITH CHECK (true);

GRANT SELECT, INSERT ON sensor_readings TO anon;
