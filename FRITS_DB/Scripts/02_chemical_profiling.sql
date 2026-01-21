/* --------------------------------------------------------------------------------
PHASE 3: CHEMICAL INVENTORY & PROFILING
Goal: Analyze distribution and concentration statistics across the library.
--------------------------------------------------------------------------------
*/

-- 3.1 Global Oxide Distribution (The "Staples" Report)
-- Frequency and concentration averages per chemical species.
SELECT 
    o.chemvzorec AS formula,
    COUNT(f.id) AS appearance_frequency,
    ROUND(AVG(s.mnozstvi), 2) AS avg_concentration,
    MAX(s.mnozstvi) AS max_concentration
FROM oxidy o
JOIN slozeni s ON o.id = s.id_sur
JOIN frity f ON s.id_pol = f.id
GROUP BY o.id, o.chemvzorec
ORDER BY appearance_frequency DESC;

-- 3.2 Potency Ratio Benchmarking
-- Identifying 'Signature' frits by comparing them to database-wide averages.
WITH v_compositions AS (
    SELECT f.nazev as frit_name, o.chemvzorec as formula, s.mnozstvi as amount
    FROM frity f 
    JOIN slozeni s ON f.id = s.id_pol 
    JOIN oxidy o ON s.id_sur = o.id
),
GlobalAverages AS (
    SELECT formula, AVG(amount) as avg_db_amount
    FROM v_compositions
    GROUP BY formula
)
SELECT 
    v.frit_name, v.formula, v.amount,
    ROUND(v.amount / g.avg_db_amount, 2) AS potency_ratio
FROM v_compositions v
JOIN GlobalAverages g ON v.formula = g.formula
WHERE v.amount > g.avg_db_amount
ORDER BY potency_ratio DESC;
