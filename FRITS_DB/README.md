# Ceramic Materials Informatics: Frit Database Analysis

This repository demonstrates a professional Data Analytics project applied to **Ceramic Engineering**. By analyzing chemical compositions, I've developed a suite of tools for quality auditing and material sourcing.

## 🗄️ Database Architecture
The project is built on three core relational tables:
* **frity**: Master table of frit names and metadata.
* **oxidy**: Chemical dictionary containing oxide formulas ($SiO_2$, $Al_2O_3$, $B_2O_3$, etc.).
* **slozeni**: Junction table containing the percentage composition for each frit.

## 🚀 Analytical Workflow

### [00] Data Discovery & Exploration
* **Purpose**: Initial inspection of table relationships and schema verification.
* **Key Logic**: Multi-table joins to create flat chemical profiles.

### [01] Data Integrity Audit
* **Purpose**: Ensuring chemical accuracy before engineering work.
* **Technique**: Flagging recipes where the sum of oxides $\neq$ 100%.
* **Impact**: Prevents mathematical errors in subsequent batching or thermal calculations.

### [02] Inventory & Chemical Profiling
* **Purpose**: Categorizing the database by "Complexity" and "Commonality."
* **Technique**: Using `GROUP_CONCAT` for profile listing and statistical functions (`AVG`, `MAX`) for distribution analysis.

### [03] Material Informatics (Advanced Ranking)
* **Purpose**: Identifying the best materials for targeted chemistry.
* **Technique**: SQL Window Functions (`DENSE_RANK`) and custom **Potency Ratios**.

## 🛠️ Technical Skills Demonstrated
* **Advanced SQL**: Window Functions (`RANK`, `DENSE_RANK`), CTEs, and Conditional Aggregation.
* **Data Governance**: Automated auditing for percentage summation and variance.
* **Domain Expertise**: Applying chemical engineering principles (stoichiometry, oxide potency) to data analysis.

## 📂 Folder Structure
```text
SQL-projects/FRITS_DB/
                  ├── Scripts/
                  │   ├── 00_quick_exploration.sql     # Initial discovery
                  │   ├── 01_data_integrity_audit.sql  # Stoichiometry validation
                  │   ├── 02_chemical_profiling.sql    # Inventory variety analysis
                  │   └── 03_material_informatics.sql  # Advanced ranking & potency
                  └── README.md
                      
