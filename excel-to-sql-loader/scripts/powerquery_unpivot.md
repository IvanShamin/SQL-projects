# Power Query – Unpivot Columns Guide

After Step 6 (generating INSERT fragments), you have a **2-D grid** of values spread across many columns. Power Query flattens it into a single column so you can copy and paste everything into your SQL client in one go.

---

## Why Power Query?

| Approach | When to use |
|----------|-------------|
| `TOCOL()` function | Excel M365 / Office 2021+ — fastest option |
| Power Query Unpivot | Excel 2016–2019, LibreOffice — works everywhere |
| Manual copy-paste | < 50 rows — acceptable but tedious |

---

## Step-by-Step (Excel)

### 1. Select your data

Click any cell inside your `inserts_composition` sheet table.

### 2. Open Power Query

**Data** → **From Table/Range**

> If the button isn't visible, the data isn't formatted as a Table yet.  
> Press **Ctrl+T** first, then try again.

### 3. Select all columns

In the Power Query editor, click the first column header, then **Shift+Click** the last column header.

### 4. Unpivot

**Transform** → **Unpivot Columns**

Power Query creates two columns:
- **Attribute** — the original column name (you don't need this)
- **Value** — your INSERT fragments ✅

### 5. Remove the Attribute column

Right-click the **Attribute** column → **Remove**.

### 6. Load back to Excel

**Home** → **Close & Load** → **Close & Load To…** → choose a new sheet.

---

## Step-by-Step (LibreOffice Calc)

LibreOffice doesn't have Power Query natively. Use one of these alternatives:

### Option A — Macro (Basic)

```vb
' Tools → Macros → Basic IDE → paste this, then run it
Sub UnpivotSheet()
    Dim oSheet As Object
    Dim oTarget As Object
    Dim r As Long, c As Long
    Dim lastRow As Long, lastCol As Long
    Dim val As String

    oSheet  = ThisComponent.Sheets.getByName("inserts_composition")
    oTarget = ThisComponent.Sheets.getByName("flat_inserts")

    lastRow = 50   ' adjust as needed
    lastCol = 30   ' adjust as needed
    Dim outRow As Long
    outRow = 0

    For r = 1 To lastRow
        For c = 1 To lastCol
            val = Trim(oSheet.getCellByPosition(c, r).getString())
            If val <> "" Then
                oTarget.getCellByPosition(0, outRow).setString(val)
                outRow = outRow + 1
            End If
        Next c
    Next r

    MsgBox "Done! " & outRow & " rows written."
End Sub
```

### Option B — Python script

See `scripts/unpivot.py` in this repo.

---

## After Unpivoting

You should now have one column with rows like:

```
(mat_001,comp_SiO2,55.30),
(mat_001,comp_Al2O3,12.10),
(mat_002,comp_SiO2,48.70),
```

Proceed to **Step 8 – Filter Empty Rows** in the main README.
