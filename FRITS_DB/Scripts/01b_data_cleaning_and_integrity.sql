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

-- 3. RESOLUTION OF ORPHANED RECORD: Frit 'A3352' (ID: 2042)
-- Orphaned record identified via LEFT JOIN audit. 
-- Technologist-verified composition added to populate the chemical profile.
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES ('2042', '1', '54.18');
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES ('2042', '4', '14.16');
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES ('2042', '5', '7.83');
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES ('2042', '13', '12.69');
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES ('2042', '6', '5.01');
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES ('2042', '7', '0.65');
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES ('2042', '16', '2.81');
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES ('2042', '17', '1.34');
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES ('2042', '18', '1.33');
