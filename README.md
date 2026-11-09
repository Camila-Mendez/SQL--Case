# Práctica SQL: SELECT CASE · Caso 3

**Priorización de tickets de soporte TI**

Curso de Base de Datos · ULACIT · Prof. Jonathan Mora · 2026

---

## Descripción

Esta práctica aplica expresiones `CASE` dentro de consultas `SELECT` para convertir datos crudos en información útil a partir de reglas de negocio. El equipo eligió el **Caso 3**: el área de soporte técnico recibe tickets con distintos niveles de impacto y urgencia, y necesita una consulta que asigne una prioridad de atención a cada ticket abierto o en proceso.

## Integrantes

| Nombre | Rol |
|---|---|
| Camila Méndez Reyes | |
| Valentina Zamora Cartín | |
| Diego Aguilar Jiménez | |
| Génesis Chaverri Rodríguez | |

## Estructura del repositorio

```
.
├── README.md
└── main.sql    # Tabla, datos de prueba y consulta con CASE
```

## Modelo de datos

Tabla `tickets`, según los campos sugeridos en la guía:

| Campo | Tipo | Uso |
|---|---|---|
| `ticket_id` | INT | Número del ticket |
| `usuario` | VARCHAR(80) | Persona que reporta el incidente |
| `impacto` | VARCHAR(20) | Alto, Medio o Bajo |
| `urgencia` | VARCHAR(20) | Alta, Media o Baja |
| `fecha_reporte` | DATE | Fecha de creación del ticket |
| `estado` | VARCHAR(20) | Abierto, En proceso o Cerrado |

## Reglas de negocio

| Condición | Prioridad |
|---|---|
| Impacto alto **y** urgencia alta | Crítica |
| Impacto alto **o** urgencia alta | Alta |
| Impacto medio **y** urgencia media | Media |
| Cualquier otro caso | Baja |
| Tickets cerrados | No aparecen en el reporte |

## Consulta

```sql
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
```

## Explicación de la lógica

**CASE con condiciones compuestas.** Las reglas se evalúan de arriba hacia abajo y `CASE` se detiene en la primera que se cumple. Por eso la regla `AND` de prioridad crítica va antes que la regla `OR` de prioridad alta: si se invirtiera el orden, un ticket con impacto y urgencia altos caería en "Alta" y nunca llegaría a "Crítica".

**Filtro de cerrados.** El `WHERE estado <> 'Cerrado'` deja solo los tickets abiertos o en proceso, tal como pide el caso.

**Orden personalizado.** Ordenar alfabéticamente por la prioridad no sirve (quedaría Alta, Baja, Crítica, Media). Se usa un segundo `CASE` en el `ORDER BY` que traduce cada prioridad a un número del 1 al 4. La consulta va dentro de un `WITH` para poder ordenar por el alias `prioridad_atencion`, lo que la hace compatible con MySQL 8+, PostgreSQL y SQL Server.

## Supuestos

1. Los valores de `impacto`, `urgencia` y `estado` se guardan con mayúscula inicial y sin variaciones (`'Alto'`, `'Media'`, `'En proceso'`, etc.).
2. Combinaciones como impacto medio con urgencia baja no cumplen ninguna regla específica, así que caen en **Baja** por el `ELSE`, como indica la regla "cualquier otro caso".
3. Dentro de una misma prioridad, los tickets más antiguos se muestran primero (`fecha_reporte ASC`), porque llevan más tiempo esperando atención. La guía no define este desempate, así que se documenta como decisión del equipo.

## Validación

Para comprobar que la consulta clasifica bien, los datos de prueba cubren las 9 combinaciones posibles de impacto y urgencia, además de al menos un ticket cerrado que no debe aparecer.

| Impacto \ Urgencia | Alta | Media | Baja |
|---|---|---|---|
| **Alto** | Crítica | Alta | Alta |
| **Medio** | Alta | Media | Baja |
| **Bajo** | Alta | Baja | Baja |

Se considera correcta si:

- Cada ticket recibe la prioridad que indica la matriz.
- Ningún ticket con estado `Cerrado` aparece en el resultado.
- El resultado sale en el orden Crítica → Alta → Media → Baja.

## Conclusión

`CASE` permite meter reglas de negocio directamente en la consulta, sin depender de la aplicación para interpretar los datos. En este caso sirvió para dos cosas: crear una columna que traduce impacto y urgencia a una prioridad entendible, y ordenar el reporte según la importancia real de cada ticket en lugar del orden alfabético. Lo más importante fue cuidar el orden de las condiciones, porque de eso depende que cada ticket quede en la categoría correcta.
