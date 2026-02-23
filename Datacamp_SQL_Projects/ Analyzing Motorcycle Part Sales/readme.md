# GoodThought NGO Impact Analysis

**SQL project** — Analyzing assignments, donations, and impact scores for GoodThought NGO (2010–2023)  
Completed in DataCamp DataLab | February 2026

## Project Overview

GoodThought NGO focuses on **education**, **healthcare**, and **sustainable development** to uplift underprivileged communities worldwide.

This project uses a PostgreSQL database to answer two key questions:

1. Which assignment has the **highest impact score** in each geographical region?
2. Which assignments received the **highest rounded total donation amounts** (including donor type)?

## Key Results

### Top Impact Assignment per Region

| Region | Assignment Name   | Impact Score | Total Donations |
|--------|-------------------|--------------|-----------------|
| East   | Assignment_316    | 10.00        | —               |
| North  | Assignment_2253   | 9.99         | —               |
| South  | Assignment_3547   | 10.00        | —               |
| West   | Assignment_2794   | 9.99         | —               |

### Assignments with Highest Rounded Total Donation Amounts

| Rank | Assignment Name   | Region | Rounded Total Donation | Donor Type    |
|------|-------------------|--------|------------------------|---------------|
| 0    | Assignment_3035   | East   | $5840.98               | Individual    |
| 1    | Assignment_300    | West   | $3133.66               | Organization  |
| 2    | Assignment_486    | North  | $2777.97               | Individual    |
| 3    | Assignment_785    | —      | $2626.87               | Organization  |
| 4    | Assignment_208    | East   | $2489.69               | —             |

## Main SQL Techniques Used

- CTEs for intermediate calculations
- Window function: `ROW_NUMBER()` for ranking per region
- Aggregation: `COUNT()`, `SUM()`, `ROUND()`
- Multiple JOINs (`assignments` ↔ `donations` ↔ `donors`)

See `ANALYSIS-GoodThought.md` for the full queries and explanations.

## Repository Contents


- `README.md` (this file)  
- `ANALYSIS-GoodThought.md`  


Technologies: PostgreSQL, SQL, DataCamp DataLab

Last updated: February 22–23, 2026
