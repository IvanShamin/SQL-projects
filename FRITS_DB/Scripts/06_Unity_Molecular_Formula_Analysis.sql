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

/* PHASE 06: UNITY MOLECULAR FORMULA (SEGER FORMULA) CALCULATOR
   -----------------------------------------------------------
   Goal: Calculate the Seger Formula (UMF) for each frit (Fluxes = 1.0).
   This standardizes chemistry for scientific comparison.
*/

WITH MolarConversion AS (
    -- 1. Convert Weight Percentage to Molar Equivalents
    SELECT 
        f.nazev AS frit_name,
        o.chemvzorec,
        (s.mnozstvi / mw.mw) AS moles,
        CASE 
            WHEN o.chemvzorec IN ('Li2O','Na2O','K2O','MgO','CaO','ZnO','BaO','PbO','SrO') THEN 'FLUX'
            WHEN o.chemvzorec IN ('Al2O3','B2O3','Fe2O3') THEN 'STABILIZER'
            ELSE 'FORMER'
        END AS oxide_group
    FROM frity f
    JOIN slozeni s ON f.id = s.id_pol
    JOIN oxidy o ON s.id_sur = o.id
    JOIN (
        -- Table of Oxide Molar Weights
        SELECT id, 
        CASE chemvzorec 
            WHEN 'Li2O' THEN 29.88 WHEN 'Na2O' THEN 61.98 WHEN 'K2O' THEN 94.20
            WHEN 'MgO' THEN 40.30 WHEN 'CaO' THEN 56.08 WHEN 'ZnO' THEN 81.38
            WHEN 'PbO' THEN 223.20 WHEN 'B2O3' THEN 69.62 WHEN 'Al2O3' THEN 101.96
            WHEN 'SiO2' THEN 60.08 WHEN 'ZrO2' THEN 123.22 WHEN 'TiO2' THEN 79.87
            ELSE 100 END AS mw FROM oxidy
    ) mw ON o.id = mw.id
),
FluxSum AS (
    -- 2. Sum of all moles in the FLUX category per frit (Unity Base)
    SELECT 
        frit_name,
        SUM(moles) AS total_flux_moles
    FROM MolarConversion
    WHERE oxide_group = 'FLUX'
    GROUP BY frit_name
),
-- 3. Final Normalization (Dividing all components by the Flux Sum)
UMF_Data AS (
    SELECT 
        mc.frit_name,
        mc.chemvzorec,
        mc.oxide_group,
        ROUND(mc.moles / fs.total_flux_moles, 4) AS seger_value
    FROM MolarConversion mc
    JOIN FluxSum fs ON mc.frit_name = fs.frit_name
)

-- Summary of Molar Ratios by Group
SELECT 
    frit_name, 
    oxide_group, 
    SUM(seger_value) AS group_molar_sum
FROM UMF_Data
GROUP BY frit_name, oxide_group
ORDER BY frit_name, FIELD(oxide_group, 'FLUX', 'STABILIZER', 'FORMER');
