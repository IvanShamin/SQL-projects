# GoodThought NGO Impact Analysis

**SQL project** analyzing assignments, donations and impact of GoodThought NGO initiatives (2010–2023)  
Data source: PostgreSQL database used in DataCamp / Databricks-style DataLab notebook

## Project Description

GoodThought NGO focuses on **education**, **healthcare**, and **sustainable development** to support underprivileged communities worldwide.

This analysis uses SQL to answer two main questions:

1. Which assignment has the **highest impact score** in each region?
2. Which assignments received the **highest total rounded donation amounts** (with donor type)?

## Key Results

### 1. Top Impact Assignment per Region

| Region | Assignment Name   | Impact Score | Number of Donations |
|--------|-------------------|--------------|---------------------|
| East   | Assignment_316    | 10.00        | (not shown)         |
| North  | Assignment_2253   | 9.99         | (not shown)         |
| South  | Assignment_3547   | 10.00        | (not shown)         |
| West   | Assignment_2794   | 9.99         | (not shown)         |

### 2. Assignments with Highest Rounded Total Donation Amounts

| Rank | Assignment Name   | Region | Rounded Total Donation Amount | Donor Type   |
|------|-------------------|--------|-------------------------------|--------------|
| 0    | Assignment_3035   | East   | $5840.98                      | Individual   |
| 1    | Assignment_300    | West   | $3133.66                      | Organization |
| 2    | Assignment_486    | North  | $2777.97                      | Individual   |
| 3    | Assignment_785    | (not shown) | $2626.87                | Organization |
| 4    | Assignment_208    | East   | $2489.69                      | (not shown)  |

(Showing top 5 from notebook output)

## SQL Highlights

Used in the notebook:

- **CTEs** for intermediate calculations
- **Window function** → `ROW_NUMBER()` to rank impact per region
- **Aggregation** → `COUNT()`, `SUM()`, `ROUND()`
- **JOINs** between `assignments`, `donations`, `donors`
- `GROUP BY` + `ORDER BY` for ranking

Example structure (top impact per region):

```sql
WITH cte AS (
    SELECT 
        a.assignment_id,
        COUNT(d.donation_id) AS num_total_donations
    FROM assignments a
    JOIN donations d ON a.assignment_id = d.assignment_id
    GROUP BY a.assignment_id
),
cte2 AS (
    SELECT 
        a.assignment_name,
        a.region,
        a.impact_score,
        cte.num_total_donations,
        ROW_NUMBER() OVER (PARTITION BY a.region ORDER BY a.impact_score DESC) AS rank_num
    FROM assignments a
    JOIN cte ON a.assignment_id = cte.assignment_id
)
SELECT 
    assignment_name,
    region,
    impact_score,
    num_total_donations
FROM cte2
WHERE rank_num = 1
ORDER BY region ASC;
