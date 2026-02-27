# 📊 Excel → SQL Loader

> A step-by-step workflow for loading structured Excel data (with chemical compositions or similar multi-column datasets) into a relational database — using Excel formulas, Power Query, and SQL.

---

## 🗂️ Table of Contents

- [Overview](#overview)
- [Database Schema](#database-schema)
- [Workflow](#workflow)
  - [Step 1 – Understand the Schema](#step-1--understand-the-schema)
  - [Step 2 – Map IDs from the Database](#step-2--map-ids-from-the-database)
  - [Step 3 – XLookup Composition Values](#step-3--xlookup-composition-values)
  - [Step 4 – Find Material IDs](#step-4--find-material-ids)
  - [Step 5 – Generate INSERT for Materials Table](#step-5--generate-insert-for-materials-table)
  - [Step 6 – Generate INSERT for Composition Table](#step-6--generate-insert-for-composition-table)
  - [Step 7 – Flatten Columns via Power Query](#step-7--flatten-columns-via-power-query)
  - [Step 8 – Filter Empty Rows](#step-8--filter-empty-rows)
  - [Step 9 – Execute SQL & Verify](#step-9--execute-sql--verify)
- [Data Integrity Check](#data-integrity-check)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

When a technologist sends you a spreadsheet with new material data, manually writing SQL inserts is error-prone and slow. This workflow turns that Excel file into ready-to-run SQL using only:

- **Excel formulas** (`XLOOKUP`, `CONCATENATE`)
- **Power Query** (built into Excel/LibreOffice)
- **Your SQL client** of choice

The approach is database-agnostic and works with any 3-table schema where a main entity has associated composition rows linked via IDs.

---

## Database Schema

The workflow assumes a schema like this:

```sql
-- Main materials table
CREATE TABLE materials (
    id   VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Composition table (one row per oxide per material)
CREATE TABLE composition (
    id_material VARCHAR(20),
    id_component VARCHAR(20),
    value DECIMAL(6,2),
    FOREIGN KEY (id_material)  REFERENCES materials(id),
    FOREIGN KEY (id_component) REFERENCES components(id)
);

-- Reference table for chemical components / oxides
CREATE TABLE components (
    id     VARCHAR(20) PRIMARY KEY,
    symbol VARCHAR(20),
    name   VARCHAR(100)
);
```

> ✏️ Adapt table and column names to your actual schema — the formulas in Step 5 and 6 reference them directly.

---

## Workflow

### Step 1 – Understand the Schema

Run a JOIN across all three tables so you know exactly which columns exist:

```sql
SELECT *
FROM   materials  m
JOIN   composition c ON m.id        = c.id_material
JOIN   components  o ON c.id_component = o.id;
```

Take note of the column order — you'll need it when building `INSERT` statements later.

---

### Step 2 – Map IDs from the Database

Pull all component IDs from the database:

```sql
SELECT id, symbol FROM components ORDER BY symbol;
```

Paste the result into a lookup sheet in your Excel workbook (e.g. a sheet called **`ref_components`**).

---

### Step 3 – XLookup Composition Values

In your main data sheet, add a row of IDs above the composition data columns. Use `XLOOKUP` to match each component symbol to its database ID:

```
=XLOOKUP(AL$1, ref_components!$B:$B, ref_components!$A:$A, "NOT FOUND")
```

This fills the ID row automatically for every component column.

---

### Step 4 – Find Material IDs

Similarly, retrieve existing material IDs from the database and add them to your sheet:

```sql
SELECT id, name FROM materials ORDER BY name;
```

Paste into a **`ref_materials`** sheet and use `XLOOKUP` (or manual entry for new materials) to populate the ID column in your data sheet.

---

### Step 5 – Generate INSERT for Materials Table

In a helper column, build the SQL `INSERT` for each new material:

```excel
=CONCATENATE("INSERT INTO materials VALUES ('";A4;"','";B4;"');")
```

| Column | Contains       |
|--------|---------------|
| A      | material ID   |
| B      | material name |

Copy the generated strings and paste & run them in your SQL client.

---

### Step 6 – Generate INSERT for Composition Table

Duplicate your data sheet and rename it (e.g. **`inserts_composition`**). In each data cell, replace the raw value with an `INSERT` fragment:

```excel
=CONCATENATE("(";'DataSheet'!$A4;",";'DataSheet'!AL$2;",";'DataSheet'!AL4;"),")
```

| Reference        | Meaning               |
|------------------|-----------------------|
| `'DataSheet'!$A4`  | material ID (row)    |
| `'DataSheet'!AL$2` | component ID (col header) |
| `'DataSheet'!AL4`  | composition value    |

This produces one `(material_id, component_id, value),` fragment per cell across the whole table.

---

### Step 7 – Flatten Columns via Power Query

All those fragments live in a 2D grid. You need them in a single column. Use **Power Query**:

1. Select the table in `inserts_composition`.
2. Go to **Data → From Table/Range**.
3. In the Power Query editor:
   - Select all columns.
   - Go to **Transform → Unpivot Columns**.
4. Keep only the `Value` column (the `INSERT` fragments).
5. **Close & Load** back to a new sheet.

> 💡 If your Excel version has `TOCOL()`, you can skip Power Query and use that function instead.

---

### Step 8 – Filter Empty Rows

The Unpivot step creates rows for cells where the composition value was empty. These look like:

```
(material_id, component_id, ),
```

Filter them out:

1. Enable AutoFilter on the Value column.
2. **Text Filters → Does Not Contain** → type ` ,)` → OK.

You now have a clean list of `INSERT` value fragments.

---

### Step 9 – Execute SQL & Verify

Copy all filtered rows. Build the final query:

```sql
INSERT INTO composition (id_material, id_component, value)
VALUES
  (mat_001, comp_SiO2, 55.30),
  (mat_001, comp_Al2O3, 12.10),
  -- ... (paste your rows here)
  (mat_002, comp_SiO2, 48.70);
```

Run it in your SQL client.

---

## Data Integrity Check

After loading, verify that compositions sum to 100 % for each material:

```sql
SELECT   id_material,
         SUM(value)      AS total,
         CASE
             WHEN ABS(SUM(value) - 100) < 0.01 THEN '✅ OK'
             ELSE '❌ Check needed'
         END             AS status
FROM     composition
GROUP BY id_material
ORDER BY status DESC;
```

Any row not showing **✅ OK** should be investigated before the data goes to production.

---

## Project Structure

```
excel-to-sql-loader/
├── README.md                    ← you are here
├── sql/
│   ├── schema.sql               ← CREATE TABLE statements
│   ├── join_check.sql           ← Step 1 query
│   └── integrity_check.sql      ← Data integrity query
├── excel_templates/
│   └── loader_template.xlsx     ← Pre-built Excel template with all formulas
├── scripts/
│   └── powerquery_unpivot.md    ← Power Query step-by-step guide with screenshots
├── docs/
│   └── workflow_diagram.png     ← Visual overview of the full pipeline
└── examples/
    └── sample_data.csv          ← Anonymised example dataset
```

---

## Requirements

| Tool | Version | Notes |
|------|---------|-------|
| Microsoft Excel | 2016+ | Power Query built-in; `XLOOKUP` requires 2019+ or M365 |
| LibreOffice Calc | 7.0+ | Use `VLOOKUP` instead of `XLOOKUP`; Power Query via Get & Transform add-in |
| Any SQL client | — | DBeaver, DataGrip, pgAdmin, MySQL Workbench, etc. |
| Database | MySQL / PostgreSQL / MariaDB | Minor syntax tweaks may be needed |

---

## Contributing

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/my-improvement`)
3. Commit your changes (`git commit -m 'Add: improved integrity check'`)
4. Push and open a Pull Request

Bug reports and suggestions are welcome via **Issues**.

---

## License

MIT © contributors — see [LICENSE](LICENSE) for details.
