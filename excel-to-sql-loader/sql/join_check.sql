-- =============================================================
-- Step 1 — Understand the schema
-- Run this to see all columns and how tables relate.
-- =============================================================

SELECT
    m.id          AS material_id,
    m.name        AS material_name,
    o.id          AS component_id,
    o.symbol      AS component_symbol,
    o.name        AS component_name,
    c.value       AS composition_value
FROM   materials   m
JOIN   composition c ON m.id           = c.id_material
JOIN   components  o ON c.id_component = o.id
ORDER  BY m.id, o.symbol;


-- =============================================================
-- Step 2 — Pull all component IDs for Excel lookup sheet
-- =============================================================

SELECT id, symbol, name
FROM   components
ORDER  BY symbol;


-- =============================================================
-- Step 4 — Pull all existing material IDs for Excel lookup sheet
-- =============================================================

SELECT id, name
FROM   materials
ORDER  BY name;
