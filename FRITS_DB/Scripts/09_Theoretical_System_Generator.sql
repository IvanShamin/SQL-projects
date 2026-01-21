/* PHASE 9: THEORETICAL SYSTEM GENERATOR (THE "INNOVATION ENGINE")
   ----------------------------------------------------------------
   Goal: Generate theoretical Flux-Stabilizer-Former combinations 
         and identify which ones are completely missing from the DB.
*/

WITH OxideRoles AS (
    -- 1. Define the roles to ensure we only build valid glass systems
    -- (A valid glass needs a Former + Stabilizer + Flux)
    SELECT chemvzorec,
    CASE 
        WHEN chemvzorec IN ('SiO2','B2O3','P2O5') THEN 'FORMER' -- The Backbone
        WHEN chemvzorec IN ('Al2O3','ZrO2','TiO2','SnO2') THEN 'STABILIZER' -- The Skeleton
        WHEN chemvzorec IN ('Na2O','K2O','Li2O','CaO','MgO','ZnO','PbO','BaO','SrO') THEN 'FLUX' -- The Melter
        ELSE 'ADDITIVE'
    END AS role
    FROM oxidy
),
TheoreticalSystems AS (
    -- 2. Generate every possible 3-component glass system (Cross Join)
    SELECT 
        f.chemvzorec AS former,
        s.chemvzorec AS stabilizer,
        x.chemvzorec AS flux,
        CONCAT(f.chemvzorec, '-', s.chemvzorec, '-', x.chemvzorec) AS system_signature
    FROM OxideRoles f
    CROSS JOIN OxideRoles s
    CROSS JOIN OxideRoles x
    WHERE f.role = 'FORMER' 
      AND s.role = 'STABILIZER' 
      AND x.role = 'FLUX'
),
ExistingSystems AS (
    -- 3. Identify what you currently have (Flagging presence)
    SELECT DISTINCT
        CONCAT(
            MAX(CASE WHEN o.chemvzorec IN ('SiO2','B2O3','P2O5') THEN o.chemvzorec ELSE NULL END), '-',
            MAX(CASE WHEN o.chemvzorec IN ('Al2O3','ZrO2','TiO2','SnO2') THEN o.chemvzorec ELSE NULL END), '-',
            MAX(CASE WHEN o.chemvzorec IN ('Na2O','K2O','Li2O','CaO','MgO','ZnO','PbO','BaO','SrO') THEN o.chemvzorec ELSE NULL END)
        ) AS existing_signature
    FROM frity f
    JOIN slozeni sl ON f.id = sl.id_pol
    JOIN oxidy o ON sl.id_sur = o.id
    GROUP BY f.id
)
-- 4. The Gap Analysis: Show me what I DON'T have
SELECT 
    t.former,
    t.stabilizer,
    t.flux,
    t.system_signature AS candidate_system,
    'UNEXPLORED' as status
FROM TheoreticalSystems t
LEFT JOIN ExistingSystems e ON t.system_signature = e.existing_signature
WHERE e.existing_signature IS NULL
ORDER BY t.former, t.stabilizer;
