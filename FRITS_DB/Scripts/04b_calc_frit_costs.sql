/* --------------------------------------------------------------------------------
PHASE 4B: ECONOMIC IMPACT ANALYSIS
Goal: Estimate raw material costs per metric ton (mT) based on oxide prices and separating by groups.
--------------------------------------------------------------------------------

/* GLAZURA FRIT COST ESTIMATOR 
  Calculates the theoretical cost of a frit based on the market price of its constituent oxides.
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
    -- Grouping by frit to get the total sum
    ROUND(SUM((s.mnozstvi / 100.0) * op.price_per_unit), 2) AS estimated_cost_per_mT,
    -- Optional: Price level category for Marketing
    CASE 
        WHEN SUM((s.mnozstvi / 100.0) * op.price_per_unit) < 400 THEN 'Price Group 1 (Eco)'
        WHEN SUM((s.mnozstvi / 100.0) * op.price_per_unit) < 800 THEN 'Price Group 2 (Standard)'
        ELSE 'Price Group 3 (Premium/Specialty)'
    END AS cost_tier
FROM frity f
JOIN slozeni s ON f.id = s.id_pol
JOIN OxidePrices op ON s.id_sur = op.id
GROUP BY f.nazev
ORDER BY estimated_cost_per_mT DESC;
