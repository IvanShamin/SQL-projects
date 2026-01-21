/* PHASE 8: INNOVATION GAP ANALYSIS (WHITE SPACE MAPPING)
   ------------------------------------------------------
   Goal: Identify "Undeveloped" chemical systems.
   Method: 
   1. Simplify compositions into "Base Systems" (Top 3 Oxides).
   2. Calculate coordinates for a Triaxial (Ternary) Map.
*/

WITH MolarWeights AS (
    -- Reuse the molar weight table from Phase 6
    SELECT id, chemvzorec,
    CASE chemvzorec
        WHEN 'Li2O' THEN 29.88 WHEN 'Na2O' THEN 61.98 WHEN 'K2O'  THEN 94.20
        WHEN 'MgO'  THEN 40.30 WHEN 'CaO'  THEN 56.08 WHEN 'ZnO'  THEN 81.38
        WHEN 'BaO'  THEN 153.33 WHEN 'PbO'  THEN 223.20 WHEN 'SrO'  THEN 103.62
        WHEN 'Al2O3' THEN 101.96 WHEN 'B2O3' THEN 69.62  
        WHEN 'SiO2' THEN 60.08 WHEN 'ZrO2' THEN 123.22 WHEN 'TiO2' THEN 79.87
        ELSE 100.0 
    END AS mw,
    CASE 
        WHEN chemvzorec IN ('SiO2','ZrO2','TiO2','P2O5') THEN 'FORMER'
        WHEN chemvzorec IN ('Al2O3','B2O3') THEN 'STABILIZER'
        ELSE 'FLUX'
    END AS function_group
    FROM oxidy
),
MolarData AS (
    SELECT 
        f.id, f.nazev, o.chemvzorec, mw.function_group,
        (s.mnozstvi / mw.mw) AS moles
    FROM frity f
    JOIN slozeni s ON f.id = s.id_pol
    JOIN oxidy o ON s.id_sur = o.id
    JOIN MolarWeights mw ON o.id = mw.id
),
-- 1. IDENTIFY THE "SYSTEM" (Top 3 oxides by molar amount)
RankedOxides AS (
    SELECT 
        nazev, chemvzorec, moles,
        ROW_NUMBER() OVER(PARTITION BY nazev ORDER BY moles DESC) as rnk
    FROM MolarData
),
SystemTags AS (
    SELECT 
        nazev,
        GROUP_CONCAT(chemvzorec ORDER BY rnk SEPARATOR '-') as base_system
    FROM RankedOxides
    WHERE rnk <= 3
    GROUP BY nazev
),
-- 2. CALCULATE TRIAXIAL COORDINATES (For the Map)
TriaxialPoints AS (
    SELECT 
        nazev,
        SUM(CASE WHEN function_group = 'FORMER' THEN moles ELSE 0 END) as former_moles,
        SUM(CASE WHEN function_group = 'STABILIZER' THEN moles ELSE 0 END) as stabilizer_moles,
        SUM(CASE WHEN function_group = 'FLUX' THEN moles ELSE 0 END) as flux_moles
    FROM MolarData
    GROUP BY nazev
)
SELECT 
    t.nazev AS frit_name,
    s.base_system,
    -- Calculate % of Total Moles for the Graph
    ROUND(100 * t.former_moles / (t.former_moles + t.stabilizer_moles + t.flux_moles), 1) AS pct_former,
    ROUND(100 * t.stabilizer_moles / (t.former_moles + t.stabilizer_moles + t.flux_moles), 1) AS pct_stabilizer,
    ROUND(100 * t.flux_moles / (t.former_moles + t.stabilizer_moles + t.flux_moles), 1) AS pct_flux
FROM TriaxialPoints t
JOIN SystemTags s ON t.nazev = s.nazev
ORDER BY base_system;
