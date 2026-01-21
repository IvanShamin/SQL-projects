/* PHASE 10: FIRING RANGE ESTIMATOR (MELTING INDEX)
   ------------------------------------------------------
   Goal: Predict the firing temperature range based on the
         Flux-to-Refractory ratio and Boron levels.
*/

WITH MolarWeights AS (
    SELECT id, chemvzorec,
    CASE chemvzorec
        -- Strongest Melters (Fluxes)
        WHEN 'Li2O' THEN 29.88 WHEN 'Na2O' THEN 61.98 WHEN 'K2O' THEN 94.20
        WHEN 'B2O3' THEN 69.62 WHEN 'PbO'  THEN 223.20 WHEN 'F2'  THEN 38.00
        -- Refractories (Heat Resistors)
        WHEN 'SiO2' THEN 60.08 WHEN 'Al2O3' THEN 101.96 WHEN 'ZrO2' THEN 123.22
        ELSE 100.0 
    END AS mw,
    CASE 
        WHEN chemvzorec IN ('Li2O','Na2O','K2O','B2O3','PbO','F2') THEN 'POWER_FLUX'
        WHEN chemvzorec IN ('SiO2','Al2O3','ZrO2') THEN 'REFRACTORY'
        ELSE 'INTERMEDIATE'
    END AS thermal_role
    FROM oxidy
),
ThermalAnalysis AS (
    SELECT 
        f.nazev AS frit_name,
        SUM(CASE WHEN mw.thermal_role = 'POWER_FLUX' THEN (s.mnozstvi / mw.mw) ELSE 0 END) AS moles_flux,
        SUM(CASE WHEN mw.thermal_role = 'REFRACTORY' THEN (s.mnozstvi / mw.mw) ELSE 0 END) AS moles_refractory
    FROM frity f
    JOIN slozeni s ON f.id = s.id_pol
    JOIN oxidy o ON s.id_sur = o.id
    JOIN MolarWeights mw ON o.id = mw.id
    GROUP BY f.nazev
)
SELECT 
    frit_name,
    ROUND(moles_flux, 3) as flux_power,
    ROUND(moles_refractory, 3) as refractory_load,
    ROUND(moles_refractory / NULLIF(moles_flux, 0), 2) AS melt_resistance_index,
    CASE 
        WHEN (moles_refractory / NULLIF(moles_flux, 0)) < 1.5 THEN 'Ultra-Low Fire (Decoration/Third Fire)'
        WHEN (moles_refractory / NULLIF(moles_flux, 0)) BETWEEN 1.5 AND 3.0 THEN 'Low Fire (Earthenware/Raku)'
        WHEN (moles_refractory / NULLIF(moles_flux, 0)) BETWEEN 3.0 AND 5.5 THEN 'Mid Range (Stoneware/Tile)'
        WHEN (moles_refractory / NULLIF(moles_flux, 0)) > 5.5 THEN 'High Fire (Porcelain/Hard Glaze)'
        ELSE 'Unknown'
    END AS estimated_firing_range
FROM ThermalAnalysis
ORDER BY melt_resistance_index ASC;
