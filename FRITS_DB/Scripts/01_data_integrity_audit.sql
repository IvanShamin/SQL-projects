/* STEP 1: DATA INTEGRITY & QUALITY AUDIT
  Goal: Identify recipes that do not sum to 100% and check for data entry errors.
*/
USE frity;

-- Audit: Grand Totals and Variance
-- Precise stoichiometry is required for ceramic calculations.
-- This identifies frits needing manual correction.
SELECT 
    f.nazev AS frit_name,
    ROUND(SUM(s.mnozstvi), 1) AS total_percentage,
    ABS(100 - SUM(s.mnozstvi)) AS variance
FROM frity f 
JOIN slozeni s ON f.id = s.id_pol 
GROUP BY f.nazev
HAVING total_percentage <> 100.0
ORDER BY variance DESC;

-- Audit: Granular Composition Check
-- Uses Window Functions to see how each oxide contributes to the total frit sum.
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
