/* PHASE 7: MATERIAL INFORMATICS - SURFACE PREDICTION
   ------------------------------------------------------
   Goal: Categorize frits by visual finish (Matte vs Glossy)
   Logic: Based on the Stull Chart and industrial Si:Al molar ratios.
*/

WITH MolarWeights AS (
    SELECT id, chemvzorec,
    CASE chemvzorec
        WHEN 'Li2O' THEN 29.88 WHEN 'Na2O' THEN 61.98 WHEN 'K2O'  THEN 94.20
        WHEN 'MgO'  THEN 40.30 WHEN 'CaO'  THEN 56.08 WHEN 'ZnO'  THEN 81.38
        WHEN 'BaO'  THEN 153.33 WHEN 'PbO'  THEN 223.20 WHEN 'SrO'  THEN 103.62
        WHEN 'Al2O3' THEN 101.96 WHEN 'SiO2' THEN 60.08
        ELSE 100.0 
    END AS mw,
    CASE 
        WHEN chemvzorec IN ('Li2O','Na2O','K2O','MgO','CaO','ZnO','BaO','PbO','SrO') THEN 'FLUX'
        ELSE 'NETWORK'
    END AS oxide_group
    FROM oxidy
),
MolarCalculations AS (
    SELECT 
        f.nazev AS frit_name,
        SUM(CASE WHEN o.chemvzorec = 'SiO2' THEN (s.mnozstvi / mw.mw) ELSE 0 END) AS moles_si,
        SUM(CASE WHEN o.chemvzorec = 'Al2O3' THEN (s.mnozstvi / mw.mw) ELSE 0 END) AS moles_al,
        SUM(CASE WHEN mw.oxide_group = 'FLUX' THEN (s.mnozstvi / mw.mw) ELSE 0 END) AS total_flux
    FROM frity f
    JOIN slozeni s ON f.id = s.id_pol
    JOIN oxidy o ON s.id_sur = o.id
    JOIN MolarWeights mw ON o.id = mw.id
    GROUP BY f.nazev
),
StullRatios AS (
    SELECT 
        frit_name,
        ROUND(moles_si / NULLIF(moles_al, 0), 2) AS si_al_ratio,
        -- Normalizing Alumina to the Unity Flux (The "UMF Alumina" axis)
        ROUND(moles_al / NULLIF(total_flux, 0), 3) AS alumina_umf,
        -- Normalizing Silica to the Unity Flux (The "UMF Silica" axis)
        ROUND(moles_si / NULLIF(total_flux, 0), 3) AS silica_umf
    FROM MolarCalculations
)
SELECT 
    frit_name,
    si_al_ratio,
    silica_umf,
    alumina_umf,
    CASE 
        WHEN si_al_ratio < 4.0 OR alumina_umf > 0.6 THEN 'Ultra-Matte (High Refractory)'
        WHEN si_al_ratio BETWEEN 4.0 AND 6.5 THEN 'Matte / Satin'
        WHEN si_al_ratio BETWEEN 6.5 AND 10.0 THEN 'Standard Glossy'
        WHEN si_al_ratio > 10.0 AND silica_umf > 4.0 THEN 'High-Acid Resistant Glass'
        WHEN si_al_ratio > 10.0 THEN 'Fluid / Crystalline'
        ELSE 'Complex/Incomplete chemistry'
    END AS predicted_texture
FROM StullRatios
ORDER BY si_al_ratio ASC;
