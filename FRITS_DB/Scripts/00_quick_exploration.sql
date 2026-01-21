/* ================================================================================
PROJECT: Frits_DB - Ceramic Material Informatics
AUTHOR: Ivan Shamin
DESCRIPTION: A comprehensive SQL framework for managing ceramic frit data, 
             auditing stoichiometry, and predicting physical properties.
================================================================================
*/

-- SETUP: Database selection
USE frity;

/* --------------------------------------------------------------------------------
PHASE 0: INITIAL EXPLORATION & SCHEMA DISCOVERY
Goal: Verify table relationships and inspect the raw chemical library.
--------------------------------------------------------------------------------
*/

-- 0.1 Schema Overview
-- Expected: frity (metadata), oxidy (oxides), slozeni (compositions)
SHOW TABLES; 

-- 0.2 Relational Integrity Check
-- Verifying the junction table (slozeni) correctly connects metadata and chemistry.
SELECT f.nazev, o.chemvzorec, s.mnozstvi
FROM frity f 
JOIN slozeni s ON f.id = s.id_pol 
JOIN oxidy o ON s.id_sur = o.id
LIMIT 10;

-- 0.3 Global Oxide Hierarchy
-- Identifying the primary carriers for each chemical via DENSE_RANK.
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
SELECT * FROM CTE_Ranking WHERE oxide_rank <= 5;
