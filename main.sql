WITH tickets_priorizados AS (
    SELECT
        ticket_id,
        usuario,
        impacto,
        urgencia,
        fecha_reporte,
        estado,
        CASE
            WHEN impacto = 'Alto'  AND urgencia = 'Alta'  THEN 'Crítica'
            WHEN impacto = 'Alto'  OR  urgencia = 'Alta'  THEN 'Alta'
            WHEN impacto = 'Medio' AND urgencia = 'Media' THEN 'Media'
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
