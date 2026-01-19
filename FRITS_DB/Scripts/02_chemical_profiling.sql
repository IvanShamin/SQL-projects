/* STEP 2: INVENTORY & CHEMICAL PROFILING
  Goal: Analyze frit complexity and oxide distribution across the library.
*/
USE frity;

-- Report: Complexity Audit
-- Categorizes frits by the number of oxides provided (Simple vs. Complex).
SELECT 
    f.nazev AS frit_name,
    COUNT(s.id_sur) AS oxide_count,
    GROUP_CONCAT(o.chemvzorec SEPARATOR ', ') AS oxide_list
FROM frity f
JOIN slozeni s ON f.id = s.id_pol
JOIN oxidy o ON s.id_sur = o.id
GROUP BY f.nazev
ORDER BY oxide_count DESC;

-- Report: Global Oxide Distribution (The "Staples" Report)
-- Statistical summary of how often each oxide appears and its typical concentration.
SELECT 
    o.chemvzorec AS formula,
    COUNT(f.id) AS appearance_frequency,
    ROUND(AVG(s.mnozstvi), 2) AS avg_concentration,
    MAX(s.mnozstvi) AS max_concentration,
    MIN(s.mnozstvi) AS min_concentration
FROM oxidy o
JOIN slozeni s ON o.id = s.id_sur
JOIN frity f ON s.id_pol = f.id
GROUP BY o.id, o.chemvzorec
ORDER BY appearance_frequency DESC;
