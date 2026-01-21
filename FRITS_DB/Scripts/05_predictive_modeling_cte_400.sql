/* --------------------------------------------------------------------------------
PHASE 5: PREDICTIVE TECHNICAL MODELING
Goal: Predict linear Coefficient of Thermal Expansion (CTE) via Appen Summation.
--------------------------------------------------------------------------------
*/

WITH AppenFactors AS (
    SELECT id, chemvzorec,
CASE chemvzorec
        -- PRIMARY GLAZURA OXIDES 
        WHEN 'Na2O'   THEN 395.0 WHEN 'K2O'    THEN 465.0 
        WHEN 'Li2O'   THEN 215.0 WHEN 'CaO'    THEN 130.0 
        WHEN 'BaO'    THEN 200.0 WHEN 'MgO'    THEN 60.0  
        WHEN 'ZnO'    THEN 50.0  WHEN 'PbO'    THEN 130.0 
        WHEN 'SrO'    THEN 160.0 WHEN 'SiO2'   THEN 38.0  
        WHEN 'Al2O3'  THEN -30.0 WHEN 'ZrO2'   THEN 60.0  
        WHEN 'TiO2'   THEN 30.0  WHEN 'SnO2'   THEN -45.0
        WHEN 'Fe2O3'  THEN 55.0  WHEN 'CoO'    THEN 50.0
        WHEN 'CuO'    THEN 50.0  WHEN 'MnO'    THEN 105.0
        WHEN 'NiO'    THEN 50.0  WHEN 'Cr2O3'  THEN -50.0
        WHEN 'CeO2'   THEN 100.0 WHEN 'V2O5'   THEN 150.0

        -- NEWLY ADDED FACTORS FROM YOUR REQUEST
        WHEN 'P2O5'   THEN 140.0 -- High expansion (network loosener in silicates)
        WHEN 'B2O3'   THEN 0.1   -- Standard Appen baseline (often near zero/negative) [cite: 651, 680]
        WHEN 'MnO2'   THEN 80.0  -- Similar to other transition metals
        WHEN 'Sb2O5'  THEN 40.0  -- Antimony (stabilizer)
        WHEN 'Bi2O3'  THEN 100.0 -- Bismuth (heavy metal flux)
        WHEN 'Ag2O'   THEN 350.0 -- Silver (Highly expansive alkali-like behavior)
        WHEN 'MoO3'   THEN 40.0  -- Molybdenum
        WHEN 'WO3'    THEN 30.0  -- Tungsten
        WHEN 'Pr6O11' THEN 90.0  -- Praseodymium (Rare earth average)
        WHEN 'CdO'    THEN 110.0 -- Cadmium
        WHEN 'Se'      THEN 50.0  -- Selenium
        WHEN 'S'       THEN 100.0 -- Sulfur (highly variable, estimated)
        WHEN 'F2'      THEN 50.0  -- Fluorine (lowers expansion by breaking bonds)
        ELSE 0 
    END AS appen_factor
    FROM oxidy
),
FritTotals AS (
    -- First, we aggregate at the Frit level to get the actual Total CTE per frit
    SELECT 
        f.id AS frit_id,
        f.nazev AS frit_name,
        SUM(s.mnozstvi * af.appen_factor) * 0.01 AS total_cte_400
    FROM frity f
    JOIN slozeni s ON f.id = s.id_pol
    JOIN AppenFactors af ON s.id_sur = af.id
    GROUP BY f.id, f.nazev
),
FinalReport AS (
    -- Now we join back to the oxides to show the detailed breakdown
    SELECT 
        ft.frit_name,
        o.chemvzorec AS oxide,
        s.mnozstvi AS oxide_pct,
        ROUND((s.mnozstvi * af.appen_factor) * 0.01, 3) AS oxide_contribution,
        ROUND(ft.total_cte_400, 2) AS total_frit_cte_400,
        -- Calculate the average of the totals across the entire frit library
        ROUND(AVG(ft.total_cte_400) OVER(), 2) AS library_avg_cte_400
    FROM FritTotals ft
    JOIN slozeni s ON ft.frit_id = s.id_pol
    JOIN oxidy o ON s.id_sur = o.id
    JOIN AppenFactors af ON o.id = af.id
)
SELECT * FROM FinalReport
ORDER BY total_frit_cte_400 DESC, frit_name, oxide_pct DESC;
