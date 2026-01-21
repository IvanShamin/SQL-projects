/* PHASE 11: REGULATORY & SAFETY COMPLIANCE (REACH/RoHS)
   ------------------------------------------------------
   Goal: Flag frits containing regulated heavy metals or toxic oxides.
*/

SELECT 
    f.nazev AS frit_name,
    GROUP_CONCAT(o.chemvzorec SEPARATOR ', ') AS hazardous_components,
    SUM(s.mnozstvi) AS total_hazardous_pct,
    CASE 
        WHEN MAX(CASE WHEN o.chemvzorec = 'PbO' THEN 1 ELSE 0 END) = 1 THEN 'DANGER: LEAD (Pb)'
        WHEN MAX(CASE WHEN o.chemvzorec = 'CdO' THEN 1 ELSE 0 END) = 1 THEN 'DANGER: CADMIUM (Cd)'
        WHEN MAX(CASE WHEN o.chemvzorec = 'BaO' THEN 1 ELSE 0 END) = 1 THEN 'WARNING: BARIUM (Ba)'
        WHEN MAX(CASE WHEN o.chemvzorec IN ('F2','Li2O') THEN 1 ELSE 0 END) = 1 THEN 'CAUTION: Fumes/Active'
        ELSE 'General Safe Use'
    END AS safety_classification
FROM frity f
JOIN slozeni s ON f.id = s.id_pol
JOIN oxidy o ON s.id_sur = o.id
WHERE o.chemvzorec IN ('PbO', 'CdO', 'BaO', 'F2', 'As2O3', 'Sb2O3')
GROUP BY f.nazev
ORDER BY safety_classification, total_hazardous_pct DESC;
