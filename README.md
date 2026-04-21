# SAP ABAP — Custom ALV Sales Order Status Report

A custom ABAP report that consolidates SAP sales header, item, and customer master data into a single interactive ALV grid with traffic-light row colouring based on order age.

---

## Student Details

| Field | Value |
|---|---|
| **Name** | Swapneel Mukherjee |
| **Roll Number** | 2328213 |
| **Batch / Program** | 2027 SAP (OE) |
| **Submission Date** | 21 April 2026 |

---

## Project Overview

| | |
|---|---|
| **Program Name** | `Z_CUSTOM_ALV_SALES_REPORT` |
| **Package** | `ZREPORTS` |
| **Transaction** | `SE38` |
| **Module** | SD (Sales & Distribution) |
| **Tables Used** | `VBAK`, `VBAP`, `KNA1` |

The report fetches sales order header, item, and customer master data using inner joins, applies traffic-light colour coding based on order age, and displays the results in an interactive ALV grid with sorting, filtering, totals, and Excel export.

---

## Key Features

- **Flexible selection screen** — mandatory date range with optional filters on customer, order type, and sales organisation.
- **Optimised SQL** — single `SELECT` with two `INNER JOIN`s instead of nested loops.
- **Traffic-light row colouring:**
  - **Green (C310)** — on track, order age ≤ 14 days
  - **Yellow (C510)** — approaching deadline, 15–30 days
  - **Red (C610)** — overdue, > 30 days
- **Column totals** on Quantity and Net Value.
- **Zebra striping** and auto-fit column widths.
- **Full-screen ALV** via `REUSE_ALV_GRID_DISPLAY` — no dynpro dependency.
- **Graceful empty-result handling** via `sy-subrc` check.

---

## How to Execute

Requires an SAP system with the standard SD demo dataset (IDES, S/4 HANA training, or institute training server).

1. Log in to SAP GUI (client `800` recommended).
2. Open transaction **`SE38`**.
3. Enter program name **`Z_CUSTOM_ALV_SALES_REPORT`** → click **Create**.
4. Choose type **Executable program**, package **`ZREPORTS`** (or `$TMP` for local).
5. Paste the contents of [`Z_CUSTOM_ALV_SALES_REPORT.abap`](./Z_CUSTOM_ALV_SALES_REPORT.abap).
6. Activate (**Ctrl + F3**).
7. Execute (**F8**).
8. Enter a date range on the selection screen (e.g. `01.01.2026` to `21.04.2026`) → press **F8**.
9. The ALV grid appears with colour-coded rows and totals.

---

## Technology Stack

| Layer | Technology |
|---|---|
| Language | ABAP |
| Platform | SAP ECC 6.0 / S/4 HANA |
| Development Env. | SAP GUI, `SE38` |
| ALV Framework | `REUSE_ALV_GRID_DISPLAY` (SLIS) |
| Output | Full-screen interactive ALV grid |

---

## Repository Structure

```
SAP-ABAP-Custom-ALV-Report/
├── README.md                          ← this file
└── Z_CUSTOM_ALV_SALES_REPORT.abap     ← complete ABAP source (comment-free)
```

---

## Note

SAP GUI screenshots are not included as system access was unavailable during development. The code is complete and ready for live demo on any SAP training system with SD data.
