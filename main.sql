-- =========================================================
-- ULACIT - Base de Datos
-- Caso 3: Priorización de tickets de soporte TI
-- Script integrado: creación de tabla, datos de prueba y consulta
-- =========================================================

-- PARTE 1. CREACIÓN DE LA TABLA (Persona 1)
DROP TABLE IF EXISTS tickets;

CREATE TABLE tickets (
    ticket_id INT PRIMARY KEY,
    usuario VARCHAR(80) NOT NULL,
    impacto VARCHAR(20) NOT NULL,
    urgencia VARCHAR(20) NOT NULL,
    fecha_reporte DATE NOT NULL,
    estado VARCHAR(20) NOT NULL
);

-- PARTE 2. DATOS DE PRUEBA (Persona 1)
INSERT INTO tickets
    (ticket_id, usuario, impacto, urgencia, fecha_reporte, estado)
VALUES
    (1001, 'María Fernández', 'Alto',   'Alta',  '2026-11-08', 'Abierto'),
    (1002, 'Andrés Castro',   'Alto',   'Media', '2026-11-08', 'Abierto'),
    (1003, 'Valeria Rojas',   'Medio',  'Alta',  '2026-11-07', 'En proceso'),
    (1004, 'Diego Solís',     'Bajo',   'Alta',  '2026-11-07', 'Abierto'),
    (1005, 'Sofía Vargas',    'Medio',  'Media', '2026-11-06', 'Abierto'),
    (1006, 'José Mena',       'Bajo',   'Media', '2026-11-06', 'Abierto'),
    (1007, 'Camila Arias',    'Bajo',   'Baja',  '2026-11-05', 'En proceso'),
    (1008, 'Pablo Jiménez',   'Alto',   'Baja',  '2026-11-05', 'En proceso'),
    (1009, 'Elena Ruiz',      'Medio',  'Baja',  '2026-11-04', 'Abierto'),
    (1010, 'Natalia León',    'Alto',   'Alta',  '2026-11-04', 'Cerrado'),
    (1011, 'Gabriel Mora',    'Bajo',   'Alta',  '2026-11-03', 'Cerrado'),
    (1012, 'Lucía Chaves',    'Medio',  'Media', '2026-11-08', 'En proceso');

-- PARTE 3. CONSULTA DE PRIORIZACIÓN
-- El CASE en SELECT (Persona 2): columna prioridad_atencion con AND y OR.
-- IMPORTANTE: el orden de los WHEN importa. CASE devuelve el PRIMER WHEN
-- que se cumpla, así que 'Crítica' (Alto AND Alta) debe ir primero.
-- Si "Alto OR Alta" fuera antes, un ticket Alto + Alta quedaría como
-- 'Alta' y nunca llegaría a 'Crítica'.
WITH tickets_priorizados AS (
    SELECT
        ticket_id,
        usuario,
        impacto,
        urgencia,
        fecha_reporte,
        estado,
        CASE
            -- 1) Lo más restrictivo primero: ambas condiciones (AND)
            WHEN impacto = 'Alto'  AND urgencia = 'Alta'  THEN 'Crítica'
            -- 2) Solo una de las dos (OR); los Alto+Alta ya se clasificaron arriba
            WHEN impacto = 'Alto'  OR  urgencia = 'Alta'  THEN 'Alta'
            -- 3) Impacto medio y urgencia media
            WHEN impacto = 'Medio' AND urgencia = 'Media' THEN 'Media'
            -- 4) Cualquier otro caso
            ELSE 'Baja'
        END AS prioridad_atencion
    FROM tickets
    WHERE estado <> 'Cerrado'
)
SELECT *
FROM tickets_priorizados
ORDER BY
    CASE prioridad_atencion
        WHEN 'Crítica' THEN 1
        WHEN 'Alta'    THEN 2
        WHEN 'Media'   THEN 3
        ELSE 4
    END,
    fecha_reporte ASC;
