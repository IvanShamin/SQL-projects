/*

  DESCRIPTION: 
    This query maps market price data (per kg) to chemical oxides stored in the 'oxidy' table. 
    Since price is a volatile metric, it is handled here as a calculated column rather than 
    a hard-coded table attribute to allow for easy "what-if" cost simulations.
  
  CERAMIC INSIGHT:
    Prices range from bulk materials (SiO2 @ 70) to precious metal oxides (Ag2O @ 750,000).
    Mapping these values is the first step in calculating the total economic cost 
    of a frit or glaze batch.
*/

SELECT 
    id, 
    nazev AS oxide_name_cs,   -- Czech name from the database
    chemvzorec AS formula,    -- Chemical formula (e.g., SiO2, Li2O)
    
    /* Assigning market prices based on recent material catalog data.
       Values represent cost per kilogram in local currency.
    */
    CASE chemvzorec
        -- High-value colorants and precious metals
        WHEN 'Ag2O'   THEN 750000
        WHEN 'WO3'    THEN 85000
        WHEN 'Pr6O11' THEN 75000
        WHEN 'SnO2'   THEN 65000
        WHEN 'MoO3'   THEN 43000
        WHEN 'NiO'    THEN 19000
        WHEN 'Sb2O5'  THEN 17000
        WHEN 'Bi2O3'  THEN 17000
        WHEN 'Se'     THEN 16000
        
        -- Intermediate fluxes and stabilizers
        WHEN 'CuO'    THEN 9500
        WHEN 'V2O5'   THEN 8500
        WHEN 'Y2O3'   THEN 6000
        WHEN 'Li2O'   THEN 5500
        WHEN 'Cr2O3'  THEN 4300
        WHEN 'CoO'    THEN 3800
        WHEN 'ZrO2'   THEN 3300
        WHEN 'CdO'    THEN 3300
        WHEN 'PbO'    THEN 2800
        WHEN 'TiO2'   THEN 2700
        WHEN 'ZnO'    THEN 2700
        WHEN 'B2O3'   THEN 2200
        WHEN 'SrO2'   THEN 2200
        WHEN 'MnO2'   THEN 2200
        WHEN 'P2O5'   THEN 2050
        WHEN 'CeO2'   THEN 1500
        WHEN 'K2O'    THEN 1400
        WHEN 'MnO'    THEN 1300
        WHEN 'SrO'    THEN 900
        WHEN 'BaO'    THEN 800
        WHEN 'F'      THEN 700
        WHEN 'MgO'    THEN 500
        
        -- Bulk glass formers and common fluxes
        WHEN 'Al2O3'  THEN 350
        WHEN 'Na2O'   THEN 350
        WHEN 'S'      THEN 300
        WHEN 'CaO'    THEN 135
        WHEN 'Fe2O3'  THEN 100
        WHEN 'SiO2'   THEN 70
        
        ELSE 0 -- Fallback for rare or undefined oxides
    END AS price_per_kg
FROM oxidy
ORDER BY price_per_kg DESC;

-- USAGE: Save as 'v_oxide_prices.sql' or use as a subquery for recipe costing.
