-- Project: Analyzing and Formatting PostgreSQL Sales Data (DataCamp)
-- Author: Ivan Shamin
-- Date: February 2026

-- 1. Top five products per category by profit margin
WITH cte AS (
    SELECT 
        category, 
        product_name, 
        SUM(sales) AS product_total_sales, 
        SUM(profit) AS product_total_profit
    FROM orders o 
    JOIN products p USING (product_id)
    GROUP BY product_name, category
),
ranked AS (
    SELECT 
        category,
        product_name,
        product_total_sales,
        product_total_profit,
        RANK() OVER (PARTITION BY category ORDER BY product_total_sales DESC) AS product_rank
    FROM cte
)
SELECT * 
FROM ranked 
WHERE product_rank <= 5
ORDER BY category, product_rank;

-- 2. Impute missing quantity values
WITH missing AS (
    SELECT product_id, discount, market, region, sales, quantity
    FROM orders
    WHERE quantity IS NULL
),
unit_prices AS (
    SELECT 
        product_id, discount, market, region, 
        AVG(sales / quantity::numeric) AS unit_price
    FROM orders
    WHERE quantity IS NOT NULL AND quantity > 0
    GROUP BY product_id, discount, market, region
)
SELECT 
    m.product_id,
    m.discount,
    m.market,
    m.region,
    m.sales,
    m.quantity,
    ROUND(m.sales / u.unit_price, 0)::integer AS calculated_quantity
FROM missing m
JOIN unit_prices u USING (product_id, discount, market, region)
ORDER BY m.product_id;
