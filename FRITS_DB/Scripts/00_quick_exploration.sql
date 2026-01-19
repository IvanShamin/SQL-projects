/* STEP 0: INITIAL DATA EXPLORATION
  Author: [Your Name]
  Description: Preliminary data inspection and development of ranking logic.
  This script serves as a scratchpad for verifying table relationships.
*/

-- 1. Metadata Inspection
USE frity;
SHOW TABLES; 
-- Expected tables: 
-- frity (Metadata), oxidy (Chemical Library), slozeni (Composition Junction)

-- 2. Data Relationship Verification
-- Joining the three-table schema to verify relational integrity.
-- This shows the raw join before column selection.
SELECT *
FROM frity f 
JOIN slozeni s ON f.id = s.id_pol 
JOIN oxidy o ON s.id_sur = o.id
LIMIT 10;

-- 3. Chemical Profile Construction
-- Isolating necessary fields for ceramic analysis: Frit Name, Oxide Formula, and Quantity.
SELECT 
    f.nazev AS frit_name, 
    o.chemvzorec AS formula,
    s.mnozstvi AS amount
FROM frity f 
JOIN slozeni s ON f.id = s.id_pol 
JOIN oxidy o ON s.id_sur = o.id;

-- 4. Logic Development: Oxide Ranking
-- Applying DENSE_RANK to identify the hierarchy of oxides within each frit.
-- This was the prototype for the "Top Carriers" report.
SELECT 
    f.nazev AS frit_name, 
    o.chemvzorec AS formula,
    s.mnozstvi AS amount,
    DENSE_RANK() OVER(PARTITION BY o.chemvzorec ORDER BY s.mnozstvi DESC) AS oxide_rank
FROM frity f 
JOIN slozeni s ON f.id = s.id_pol 
JOIN oxidy o ON s.id_sur = o.id;

-- 5. High-Concentration Identification (Top 5)
-- Final exploration query to isolate the most potent sources for each chemical.
WITH CTE_Ranking AS (
    SELECT 
        f.nazev AS frit_name,
        o.chemvzorec AS formula,
        s.mnozstvi AS amount,
        RANK() OVER(PARTITION BY o.chemvzorec ORDER BY s.mnozstvi DESC) AS oxide_rank
    FROM frity f 
    JOIN slozeni s ON f.id = s.id_pol
    JOIN oxidy o ON s.id_sur = o.id
)
SELECT * FROM CTE_Ranking
WHERE oxide_rank <= 5;
