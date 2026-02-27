-- =============================================================
-- Schema: Excel → SQL Loader
-- Adapt table/column names to match your actual database.
-- =============================================================

-- Reference table for chemical components (e.g. oxides)
CREATE TABLE IF NOT EXISTS components (
    id     VARCHAR(20)  PRIMARY KEY,
    symbol VARCHAR(20)  NOT NULL UNIQUE,
    name   VARCHAR(100)
);

-- Main materials table
CREATE TABLE IF NOT EXISTS materials (
    id   VARCHAR(20)  PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Composition table — one row per (material, component) pair
CREATE TABLE IF NOT EXISTS composition (
    id_material  VARCHAR(20)    NOT NULL,
    id_component VARCHAR(20)    NOT NULL,
    value        DECIMAL(6, 2)  NOT NULL CHECK (value >= 0 AND value <= 100),
    PRIMARY KEY (id_material, id_component),
    FOREIGN KEY (id_material)  REFERENCES materials(id),
    FOREIGN KEY (id_component) REFERENCES components(id)
);
