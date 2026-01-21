/* --------------------------------------------------------------------------------
PHASE 2: DATA REMEDIATION (DML)
Goal: Apply technologist-verified corrections and purge redundant data.
--------------------------------------------------------------------------------
*/

-- 2.1 Stoichiometric Repair: 'ZMP 05421' (ID: 2642)
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES 
('2642', '8', '8.22'), ('2642', '4', '3'), ('2642', '5', '8.55'), 
('2642', '6', '14.37'), ('2642', '7', '1.6'), ('2642', '16', '0.68'), 
('2642', '17', '4.08');

-- 2.2 Duplicate Resolution: Purging Redundant Record (ID: 2171)
DELETE FROM slozeni WHERE id_pol = '2171';
DELETE FROM frity WHERE id = '2171';

-- 2.3 Orphaned Record Population: 'A3352' (ID: 2042)
INSERT INTO slozeni (id_pol, id_sur, mnozstvi) VALUES 
('2042', '1', '54.18'), ('2042', '4', '14.16'), ('2042', '5', '7.83'), 
('2042', '13', '12.69'), ('2042', '6', '5.01'), ('2042', '7', '0.65'), 
('2042', '16', '2.81'), ('2042', '17', '1.34'), ('2042', '18', '1.33');

-- 2.4  REMOVING INCORRECT FRIT VARIATION: 'VO6273' (ID: 2380)
Remove the chemical composition links first
DELETE FROM slozeni WHERE id_pol = 2380;
 Remove the master record from the frits table
DELETE FROM frity WHERE id = 2380;
