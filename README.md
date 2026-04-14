# SAP ABAP Custom ALV Sales Order Report

> **Capstone Project** | Swapneel Mukherjee | Roll No: 2328213 | Batch: 2027 SAP (OE)  
> Specialization: SAP ABAP Development

---

## Problem Statement

Standard SAP transactions like **VA05** or **ME2M** do not offer the layout flexibility and custom business logic that real-world organizations demand. Finance and sales teams need a consolidated view of Sales Order data — header details, line items, customer information, and net values — with interactive filtering, subtotals, and direct export capabilities.

This project designs and develops a **Custom ALV (ABAP List Viewer) Report** that retrieves data from `VBAK`, `VBAP`, and `KNA1`, applies a user-defined selection screen, and presents the output in a feature-rich, interactive ALV Grid with color-coded order health indicators.

---

## Solution & Features

### Selection Screen
| Parameter | Description |
|---|---|
| `SO_DATE` | Date range for Sales Order creation (Obligatory) |
| `P_VKORG` | Sales Organization (default: 1000) |
| `SO_KUNNR` | Customer Number range |
| `SO_AUART` | Document Type (Standard / Rush / Contract) |

### Data Retrieval
Optimized `SELECT ... INNER JOIN` across three SAP database tables:
- **VBAK** — Sales Order Header
- **VBAP** — Sales Order Item
- **KNA1** — Customer Master
- **LIPS** — Delivery Item (for overdue detection)

### Color-Coded Order Health

| Color | Condition | ALV Key |
|---|---|---|
| 🔴 Red | Undelivered orders older than 30 days | `C610` |
| 🟡 Yellow | Orders approaching deadline (15–30 days) | `C510` |
| 🟢 Green | On-track / delivered orders | `C310` |

### ALV Grid Capabilities
- Dynamic field catalog via `REUSE_ALV_FIELDCATALOG_MERGE`
- Subtotals and grand totals on **Net Value** (`NETWR`) and **Quantity** (`KWMENG`)
- Zebra-striping and auto-fit column widths
- Saveable layout variants per user
- Custom toolbar: **Refresh** and **Send by Email** buttons
- Direct export to **Excel (.xlsx)** and **PDF** from SAP GUI

---

## Tech Stack

| Component | Details |
|---|---|
| SAP Platform | SAP ECC 6.0 / S/4HANA 2022 |
| Language | ABAP Release 7.50+ |
| Development Transaction | SE38 — ABAP Editor |
| UI Technology | ALV Grid Control — `CL_GUI_ALV_GRID` |
| Container | `CL_GUI_CUSTOM_CONTAINER` (Screen 100) |
| Function Modules | `REUSE_ALV_FIELDCATALOG_MERGE`, `REUSE_ALV_EVENTS_GET` |
| Transport Layer | SAP CTS — Package `ZREPORTS` |
| Testing | SE38 → F8 Execute, ABAP Debugger |

---

## Code Structure

```
SAP-ABAP-Custom-ALV-Report/
├── Z_CUSTOM_ALV_SALES_REPORT.abap   ← Full ABAP source code
├── Swapneel_ALV_Report_Project.pdf  ← Full project report (upload separately)
├── Screenshots/                     ← SAP GUI screenshots (upload separately)
│   ├── Fig1_SE38_Editor.png
│   ├── Fig2_Selection_Screen.png
│   ├── Fig3_ALV_Grid_Output.png
│   ├── Fig4_Color_Coding.png
│   ├── Fig5_Subtotals.png
│   └── Fig6_Export_to_Excel.png
└── README.md
```

---

## Step-by-Step Development

The program is built in 7 clearly separated steps:

1. **SE38 Setup** — Create executable program `Z_CUSTOM_ALV_SALES_REPORT` in package `ZREPORTS`
2. **Global Declarations** — Type structure `ty_report`, internal tables, ALV object references
3. **Selection Screen** — User-facing parameter block with obligatory date range
4. **Data Fetch** — Optimized `SELECT INNER JOIN` on VBAK + VBAP + KNA1
5. **Color Coding** — `LOOP` assigns row color key based on `SY-DATUM - ERDAT`
6. **Field Catalog** — `REUSE_ALV_FIELDCATALOG_MERGE` + manual customization of key fields
7. **ALV Display** — Layout config + `CL_GUI_ALV_GRID->SET_TABLE_FOR_FIRST_DISPLAY`

---

## Unique Highlights

- **Dynamic Field Catalog** — Generated at runtime from the internal table structure; no hard-coding required
- **Business-Logic-Driven Colors** — Row colors computed from real-time date diff (`SY-DATUM`), giving live order health visibility
- **Declarative Subtotals** — Uses `DO_SUM` flags in the field catalog instead of manual `COMPUTE SUM`
- **Personalized Variants** — Users save column sequences and filters as named ALV variants
- **Modular FORMs** — `F_GET_DATA`, `F_BUILD_FCAT`, `F_DISPLAY_ALV` follow SAP ABAP coding standards

---

## Future Improvements

- **CDS View Integration** — Migrate SELECT logic to ABAP CDS Views with UI annotations for S/4HANA Clean Core compliance
- **SAP Fiori ALP** — Expose CDS view as OData service and build an Analytical List Page in SAP BAS
- **Automated Email Alerts** — Schedule as background job (SM36) to email overdue order list to sales managers daily
- **Configurable Thresholds** — Store overdue day thresholds in a custom Z-table (`Z_ALV_CONFIG`) for admin configuration without code changes
- **Audit Trail Logging** — Log every execution (user, timestamp, selection criteria, record count) to `Z_ALV_AUDIT_LOG` for compliance

---

## Screenshots

> *Upload your SAP GUI screenshots to the `Screenshots/` folder and they will display here.*

| Fig. | Description |
|---|---|
| Fig. 1 | SE38 Editor — source code, syntax check passed (green) |
| Fig. 2 | Selection Screen — date range, Sales Org, Customer, Doc Type |
| Fig. 3 | ALV Grid Output — all columns, zebra-striping, auto-fit widths |
| Fig. 4 | Color Coding — red/yellow/green rows by order age |
| Fig. 5 | Subtotals — Net Value and Quantity aggregated per customer |
| Fig. 6 | Export to Excel — Local File export generating .xlsx |

---

*Submitted as part of the SAP ABAP Capstone Project — April 2026*
