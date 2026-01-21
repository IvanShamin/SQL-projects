/* STEP 3: MATERIAL INFORMATICS & POTENCY
  Goal: Identify 'Signature' frits and primary chemical carriers.
*/
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
    v.frit_name, v.formula, v.amount AS concentration,
    ROUND(avg_db_amount,2) as avg_db_amount,
    ROUND(v.amount / g.avg_db_amount, 2) AS potency_ratio
FROM v_compositions v
JOIN GlobalAverages g ON v.formula = g.formula
WHERE v.amount > g.avg_db_amount
ORDER BY potency_ratio DESC;
