# Excel Formula Reference

Quick-copy formulas for each step of the workflow.

> Replace sheet names (`DataSheet`, `ref_components`, `ref_materials`) and cell references
> to match your actual workbook layout.

---

## Step 3 — XLOOKUP: Component Symbol → Database ID

Paste in the **ID row** above each composition column (e.g. row 2):

```excel
=XLOOKUP(AL$1, ref_components!$B:$B, ref_components!$A:$A, "NOT FOUND")
```

| Part | Meaning |
|------|---------|
| `AL$1` | Cell containing the component symbol (column header) |
| `ref_components!$B:$B` | Symbol column in your lookup sheet |
| `ref_components!$A:$A` | ID column in your lookup sheet |
| `"NOT FOUND"` | Error text if no match — search for this before loading! |

**LibreOffice / older Excel — use VLOOKUP instead:**

```excel
=IFERROR(VLOOKUP(AL$1, ref_components!$A:$B, 2, 0), "NOT FOUND")
```

---

## Step 5 — CONCATENATE: INSERT for Materials Table

```excel
=CONCATENATE("INSERT INTO materials VALUES ('";A4;"','";B4;"');")
```

| Cell | Content |
|------|---------|
| A4   | Material ID |
| B4   | Material name |

**Result example:**
```sql
INSERT INTO materials VALUES ('MAT_001','Material A');
```

---

## Step 6 — CONCATENATE: INSERT Fragment for Composition Table

Paste in every data cell of the `inserts_composition` sheet:

```excel
=CONCATENATE("(";DataSheet!$A4;",";DataSheet!AL$2;",";DataSheet!AL4;"),")
```

| Reference | Meaning |
|-----------|---------|
| `DataSheet!$A4` | Material ID (locked column, moving row) |
| `DataSheet!AL$2` | Component ID (locked row, moving column) |
| `DataSheet!AL4` | Composition value |

**Result example:**
```
(MAT_001,comp_SiO2,55.30),
```

---

## Step 8 — Filter Empty Rows

In the flattened column, apply:

**AutoFilter → Text Filters → Does Not Contain → ` ,)`**

This removes fragments where the composition value was blank, which look like:

```
(MAT_001,comp_ZrO2, ,),
```

---

## Tip: Check for "NOT FOUND" before loading

```excel
=COUNTIF(A2:AZ2, "NOT FOUND")
```

If this returns anything other than 0, fix the missing IDs before running inserts.
