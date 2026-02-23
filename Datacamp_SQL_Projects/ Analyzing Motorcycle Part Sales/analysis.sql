/*
 * Project: Analyzing Motorcycle Part Sales – Wholesale Net Revenue
 * Goal: Calculate net revenue after payment fees for Wholesale orders only
 * Group by: product_line, month, warehouse
 * Data period: June – August 2021
 * Database: PostgreSQL (DataCamp / DataLab)
 * Author: [your name / GitHub username]
 * Date: February 23, 2026
 */

-- ===========================================
-- Recommended / Corrected Query
-- ===========================================

SELECT 
    product_line,
    TRIM(TO_CHAR(date, 'Month')) AS month,                    -- 'June', 'July', 'August' without trailing space
    warehouse,
    ROUND(SUM(total * (1 - payment_fee))::numeric, 2) AS net_revenue
FROM sales
WHERE client_type = 'Wholesale'
GROUP BY 
    product_line,
    TRIM(TO_CHAR(date, 'Month')),
    warehouse
ORDER BY 
    product_line ASC,
    TO_CHAR(date, 'Month') ASC,                               -- keeps chronological order
    net_revenue DESC;                                         -- highest revenue first within group

-- Alternative version using EXTRACT + CASE (cleaner month names, no TRIM needed)
SELECT 
    product_line,
    CASE EXTRACT(MONTH FROM date)
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
    END AS month,
    warehouse,
    ROUND(SUM(total * (1 - payment_fee))::numeric, 2) AS net_revenue
FROM sales
WHERE client_type = 'Wholesale'
GROUP BY 
    product_line,
    EXTRACT(MONTH FROM date),
    warehouse,
    CASE EXTRACT(MONTH FROM date)
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
    END
ORDER BY 
    product_line,
    EXTRACT(MONTH FROM date),                                 -- 6 → 7 → 8
    net_revenue DESC;

-- ===========================================
-- Common Mistake – Original approach (incorrect)
-- ===========================================

/*
SELECT 
    product_line,
    TO_CHAR(date, 'Month') AS month,
    warehouse,
    SUM(total) - SUM(payment_fee) AS net_revenue
FROM sales
WHERE client_type = 'Wholesale'
GROUP BY product_line, TO_CHAR(date, 'Month'), warehouse
ORDER BY product_line, month, net_revenue DESC;
*/

-- Why wrong?
-- payment_fee is a RATE (percentage), e.g. 0.03 = 3%
-- You cannot sum rates and subtract from total revenue
-- Correct logic: fee amount = total * payment_fee → net = total - fee = total * (1 - payment_fee)
-- Must apply per row BEFORE summing

-- ===========================================
-- Output format expected by the project
-- ===========================================
/*
product_line    | month  | warehouse | net_revenue
----------------+--------+-----------+------------
Braking system  | June   | North     | XXXX.XX
Braking system  | June   | Central   | XXXX.XX
...
Electrical system | August | West    | XXXX.XX
(≈ 48 rows total)
*/
