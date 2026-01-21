/* PHASE 6: UNITY MOLECULAR FORMULA (UMF) CALCULATOR
   --------------------------------------------------
   Goal: Normalize chemistry so the sum of Fluxes (R2O + RO) = 1.0.
   Method: 
   1. Divide Weight% by Molecular Weight to get Molar Equivalents.
   2. Sum the Moles of all Fluxes.
   3. Divide all Molar Equivalents by that sum.
*/

WITH MolarWeights AS (
    SELECT id, chemvzorec,
    CASE chemvzorec
        -- FLUXES (R2O & RO)
        WHEN 'Li2O'   THEN 29.88  WHEN 'Na2O'   THEN 61.98  WHEN 'K2O'    THEN 94.20
        WHEN 'MgO'    THEN 40.30  WHEN 'CaO'    THEN 56.08  WHEN 'ZnO'    THEN 81.38
        WHEN 'BaO'    THEN 153.33 WHEN 'PbO'    THEN 223.20 WHEN 'SrO'    THEN 103.62
        -- AMPHOTERIC (R2O3)
        WHEN 'Al2O3'  THEN 101.96 WHEN 'B2O3'   THEN 69.62  WHEN 'Fe2O3'  THEN 159.69
        -- GLASS FORMERS (RO2)
        WHEN 'SiO2'   THEN 60.08  WHEN 'TiO2'   THEN 79.87  WHEN 'ZrO2'   THEN 123.22
        WHEN 'SnO2'   THEN 150.71 WHEN 'P2O5'   THEN 141.94
        ELSE 100.0 -- Fallback for unknowns
    END AS mw,
    -- Classification for normalization logic
    CASE 
        WHEN chemvzorec IN ('Li2O','Na2O','K2O','MgO','CaO','ZnO','BaO','PbO','SrO') THEN 'FLUX'
        WHEN chemvzorec IN ('Al2O3','B2O3','Fe2O3') THEN 'AMPHOTERIC'
        ELSE 'FORMER'
    END AS oxide_group
    FROM oxidy
),
MolarEquivalents AS (
    SELECT 
        f.nazev AS frit_name,
        o.chemvzorec,
        mw.oxide_group,
        (s.mnozstvi / mw.mw) AS moles
    FROM frity f
    JOIN slozeni s ON f.id = s.id_pol
    JOIN oxidy o ON s.id_sur = o.id
    JOIN MolarWeights mw ON o.id = mw.id
),
FluxSums AS (
    -- Calculating the "Unity" divisor (Sum of all Fluxes)
    SELECT 
        frit_name,
        SUM(moles) AS total_flux_moles
    FROM MolarEquivalents
    WHERE oxide_group = 'FLUX'
    GROUP BY frit_name
)
SELECT 
    me.frit_name,
    me.chemvzorec AS oxide,
    me.oxide_group,
    ROUND(me.moles / fs.total_flux_moles, 4) AS umf_value,
    -- Calculating the crucial Silica:Alumina ratio
    ROUND(
        (SUM(CASE WHEN me.chemvzorec = 'SiO2' THEN me.moles ELSE 0 END) OVER(PARTITION BY me.frit_name)) /
        NULLIF((SUM(CASE WHEN me.chemvzorec = 'Al2O3' THEN me.moles ELSE 0 END) OVER(PARTITION BY me.frit_name)), 0)
    , 2) AS si_al_ratio
FROM MolarEquivalents me
JOIN FluxSums fs ON me.frit_name = fs.frit_name
ORDER BY me.frit_name, me.oxide_group;
