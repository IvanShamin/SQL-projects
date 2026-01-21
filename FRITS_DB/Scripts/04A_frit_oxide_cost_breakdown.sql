/* --------------------------------------------------------------------------------
PHASE 4A: ECONOMIC IMPACT ANALYSIS
Goal: Estimate raw material costs per metric ton (mT) based on oxide prices.
--------------------------------------------------------------------------------

/* GLAZURA FRIT COST ANALYSIS - DETAILED BREAKDOWN
  This script calculates the total cost per metric ton (mT) for each frit
  while displaying the specific price contribution of every oxide.
  
  Logic: 
  - (mnozstvi / 100.0) converts percentage composition to mass fraction.
  - SUM(...) OVER (PARTITION BY...) calculates the total frit cost without collapsing rows.
*/

WITH OxidePrices AS (
    SELECT id, chemvzorec,
    CASE chemvzorec
        WHEN 'Ag2O'   THEN 750000 WHEN 'WO3'    THEN 85000
        WHEN 'Pr6O11' THEN 75000  WHEN 'SnO2'   THEN 65000
        WHEN 'MoO3'   THEN 43000  WHEN 'NiO'    THEN 19000
        WHEN 'Sb2O5'  THEN 17000  WHEN 'Bi2O3'  THEN 17000
        WHEN 'Se'     THEN 16000  WHEN 'CuO'    THEN 9500
        WHEN 'V2O5'   THEN 8500   WHEN 'Y2O3'   THEN 6000
        WHEN 'Li2O'   THEN 5500   WHEN 'Cr2O3'  THEN 4300
        WHEN 'CoO'    THEN 3800   WHEN 'ZrO2'   THEN 3300
        WHEN 'CdO'    THEN 3300   WHEN 'PbO'    THEN 2800
        WHEN 'TiO2'   THEN 2700   WHEN 'ZnO'    THEN 2700
        WHEN 'B2O3'   THEN 2200   WHEN 'SrO2'   THEN 2200
        WHEN 'MnO2'   THEN 2200   WHEN 'P2O5'   THEN 2050
        WHEN 'CeO2'   THEN 1500   WHEN 'K2O'    THEN 1400
        WHEN 'MnO'    THEN 1300   WHEN 'SrO'    THEN 900
        WHEN 'BaO'    THEN 800    WHEN 'F'      THEN 700
        WHEN 'MgO'    THEN 500    WHEN 'Al2O3'  THEN 600
        WHEN 'Na2O'   THEN 1000   WHEN 'S'      THEN 300
        WHEN 'CaO'    THEN 135    WHEN 'Fe2O3'  THEN 100
        WHEN 'SiO2'   THEN 70     WHEN 'F2'     THEN 0
        ELSE 0 
    END AS price_per_unit
    FROM oxidy
)
SELECT 
    f.nazev AS frit_name,
    op.chemvzorec AS oxide_name,
    s.mnozstvi AS percentage_amount,
    op.price_per_unit,
    -- Calculation of individual oxide cost contribution for transparency
    ROUND((s.mnozstvi / 100.0) * op.price_per_unit, 2) AS oxide_cost_contribution,
    -- Total cost for the entire frit (summed across all oxides in that frit)
    ROUND(SUM((s.mnozstvi / 100.0) * op.price_per_unit) OVER (PARTITION BY f.nazev), 2) AS total_frit_cost_per_mT
FROM frity f
JOIN slozeni s ON f.id = s.id_pol
JOIN OxidePrices op ON s.id_sur = op.id
ORDER BY total_frit_cost_per_mT DESC, percentage_amount DESC;
