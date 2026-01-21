/* --------------------------------------------------------------------------------
PHASE 1: DATA QUALITY ASSURANCE & AUDIT
Goal: Identify non-stoichiometric recipes and orphaned records.
--------------------------------------------------------------------------------
*/

-- 1.1 Stoichiometry Audit (100% Check)
-- Ceramic calculations require precise sums. This isolates data entry errors.
SELECT 
    f.nazev AS frit_name,
    ROUND(SUM(s.mnozstvi), 1) AS total_percentage,
    ABS(100 - SUM(s.mnozstvi)) AS variance
FROM frity f 
JOIN slozeni s ON f.id = s.id_pol 
GROUP BY f.nazev
HAVING total_percentage <> 100.0
ORDER BY variance DESC;

-- 1.2 Granular Composition Check
-- Calculating running totals per frit to verify oxide counts.
SELECT 
    f.nazev AS frit_name, 
    o.chemvzorec AS formula,
    s.mnozstvi AS oxide_amount,
    COUNT(s.mnozstvi) OVER(PARTITION BY f.nazev) AS count_of_oxides,
    SUM(s.mnozstvi) OVER(PARTITION BY f.nazev) AS running_total
FROM frity f 
JOIN slozeni s ON f.id = s.id_pol 
JOIN oxidy o ON s.id_sur = o.id
ORDER BY count_of_oxides DESC, frit_name;
