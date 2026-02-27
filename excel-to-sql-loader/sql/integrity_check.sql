-- =============================================================
-- Data Integrity Check
-- Verifies that composition values sum to 100 per material.
-- Run after every bulk load.
-- =============================================================

SELECT
    m.id                                    AS material_id,
    m.name                                  AS material_name,
    ROUND(SUM(c.value), 2)                  AS total_percent,
    CASE
        WHEN ABS(SUM(c.value) - 100) < 0.01
            THEN 'OK'
        ELSE 'CHECK NEEDED'
    END                                     AS status
FROM   materials   m
JOIN   composition c ON m.id = c.id_material
GROUP  BY m.id, m.name
ORDER  BY status DESC, m.id;


-- =============================================================
-- Quick count — how many components per material?
-- =============================================================

SELECT
    m.id            AS material_id,
    m.name          AS material_name,
    COUNT(c.value)  AS num_components
FROM   materials   m
JOIN   composition c ON m.id = c.id_material
GROUP  BY m.id, m.name
ORDER  BY m.id;
