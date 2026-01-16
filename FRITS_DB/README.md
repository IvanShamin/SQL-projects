# Frit Chemical Composition Analysis

This SQL project analyzes the chemical composition of frits (ceramic materials) by joining tables `frity`, `slozeni`, and `oxidy`. It explores table structures, joins data for oxide formulas and amounts, and ranks oxides by amount per formula.

## Database Setup
- Tables: `frity` (frits), `slozeni` (compositions), `oxidy` (oxides)
- Key joins: `frity.id = slozeni.id_pol` and `slozeni.id_sur = oxidy.id`

## Queries
See `analysis.sql` for full code:
- Explore tables
- Join for composition
- Select key info (frit name, oxide formula, amount)
- Rank oxides by amount (partitioned by formula)

## How to Run
1. Connect to your PostgreSQL DB (or similar).
2. Run `analysis.sql`.
3. Example output: Ranks highest oxide amounts per formula.

## Tools Used
- SQL (PostgreSQL dialect)
- Window function: `DENSE_RANK() OVER (PARTITION BY ...)`
