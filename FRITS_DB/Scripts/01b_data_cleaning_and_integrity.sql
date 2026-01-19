/* PHASE 1.1: DATA REMEDIATION & STRUCTURAL INTEGRITY
   -------------------------------------------------------
   Following the Phase 1 Audit, these corrections were applied to ensure 
   the database is chemically valid and relationally sound for Phase 2.
*/

-- 1. STOICHIOMETRIC CORRECTION: Frit 'ZMP 05421' (ID: 2642)
-- Previously identified as an anomaly (missing oxides).
-- Technologist-verified composition added to achieve 100% total sum.
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES ('2642', '8', '8.22');
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES ('2642', '4', '3');
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES ('2642', '5', '8.55');
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES ('2642', '6', '14.37');
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES ('2642', '7', '1.6');
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES ('2642', '16', '0.68');
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES ('2642', '17', '4.08');

-- 2. DUPLICATE RESOLUTION: (IDs: 2171 & 2172)
-- Both IDs shared the same name. ID 2171 was identified as a redundant record.
-- Step A: Delete composition entries associated with the redundant ID.
DELETE FROM slozeni WHERE id_pol = '2171';
-- Step B: Delete the master record from 'frity' to maintain referential integrity.
DELETE FROM frity WHERE id = '2171';

-- 3. ORPHANED RECORD IDENTIFICATION: (ID: 2042 | Name: A3352)
-- During integrity check, ID 2042 was found in 'frity' with no data in 'slozeni'.
-- QUERY USED TO FIND DISCREPANCIES:
/*
SELECT * 
FROM frity f
LEFT JOIN slozeni s ON f.id = s.id_pol
WHERE s.id_pol IS NULL;
*/
-- ACTION: Pending technologist decision on whether to populate or purge this record.
