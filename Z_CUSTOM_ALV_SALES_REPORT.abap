*&---------------------------------------------------------------------*
*& Report  Z_CUSTOM_ALV_SALES_REPORT
*& Custom ALV Sales Order Status Report
*& Author : Swapneel Mukherjee | Roll No: 2328213 | Batch: 2027 SAP (OE)
*& Package: ZREPORTS | Transaction: SE38
*&---------------------------------------------------------------------*

REPORT z_custom_alv_sales_report LINE-SIZE 250 NO STANDARD PAGE HEADING.

*----------------------------------------------------------------------*
* STEP 2 — Global Data & Type Structures
*----------------------------------------------------------------------*

TYPES: BEGIN OF ty_report,
         vbeln  TYPE vbak-vbeln,     " Sales Order Number
         erdat  TYPE vbak-erdat,     " Creation Date
         auart  TYPE vbak-auart,     " Order Type
         vkorg  TYPE vbak-vkorg,     " Sales Organization
         kunnr  TYPE kna1-kunnr,     " Customer Number
         name1  TYPE kna1-name1,     " Customer Name
         posnr  TYPE vbap-posnr,     " Item Number
         matnr  TYPE vbap-matnr,     " Material Number
         arktx  TYPE vbap-arktx,     " Item Description
         kwmeng TYPE vbap-kwmeng,    " Order Quantity
         netwr  TYPE vbap-netwr,     " Net Value
         waerk  TYPE vbak-waerk,     " Currency
         color  TYPE c LENGTH 4,     " Row Color Key
       END OF ty_report.

DATA: it_report TYPE STANDARD TABLE OF ty_report,
      wa_report TYPE ty_report,
      it_fcat   TYPE lvc_t_fcat,
      wa_fcat   TYPE lvc_s_fcat,
      gs_layout TYPE lvc_s_layo,
      go_alv    TYPE REF TO cl_gui_alv_grid,
      go_custom TYPE REF TO cl_gui_custom_container.

*----------------------------------------------------------------------*
* STEP 3 — Selection Screen
*----------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: so_date  FOR sy-datum OBLIGATORY,
                  so_kunnr FOR kna1-kunnr,
                  so_auart FOR vbak-auart.
  PARAMETERS:     p_vkorg  TYPE vkorg DEFAULT '1000'.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
* STEP 4 — Fetch Data Using Optimized SQL
*----------------------------------------------------------------------*

START-OF-SELECTION.

  SELECT a~vbeln a~erdat a~auart a~vkorg a~waerk
         b~posnr b~matnr b~arktx b~kwmeng b~netwr
         c~kunnr c~name1
    INTO CORRESPONDING FIELDS OF TABLE it_report
    FROM vbak AS a
    INNER JOIN vbap AS b ON b~vbeln = a~vbeln
    INNER JOIN kna1 AS c ON c~kunnr = a~kunnr
   WHERE a~erdat IN so_date
     AND a~vkorg =  p_vkorg
     AND a~kunnr IN so_kunnr
     AND a~auart IN so_auart.

*----------------------------------------------------------------------*
* STEP 5 — Apply Color Coding Logic
*----------------------------------------------------------------------*

  LOOP AT it_report INTO wa_report.
    DATA(lv_days) = sy-datum - wa_report-erdat.

    IF lv_days > 30.
      wa_report-color = 'C610'.   " Red    — overdue (> 30 days)
    ELSEIF lv_days BETWEEN 15 AND 30.
      wa_report-color = 'C510'.   " Yellow — approaching deadline
    ELSE.
      wa_report-color = 'C310'.   " Green  — on track
    ENDIF.

    MODIFY it_report FROM wa_report.
  ENDLOOP.

*----------------------------------------------------------------------*
* STEP 6 — Build the Field Catalog
*----------------------------------------------------------------------*

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name   = sy-repid
      i_internal_tabname = 'IT_REPORT'
      i_inclname       = sy-repid
    CHANGING
      ct_fieldcat      = it_fcat.

  " Customize key fields
  LOOP AT it_fcat INTO wa_fcat.
    CASE wa_fcat-fieldname.
      WHEN 'VBELN'.  wa_fcat-key     = 'X'. wa_fcat-coltext = 'Sales Order'.
      WHEN 'NETWR'.  wa_fcat-do_sum  = 'X'. wa_fcat-coltext = 'Net Value'.
      WHEN 'KWMENG'. wa_fcat-do_sum  = 'X'. wa_fcat-coltext = 'Qty'.
      WHEN 'COLOR'.  wa_fcat-no_out  = 'X'. " Hide color column from display
    ENDCASE.
    MODIFY it_fcat FROM wa_fcat.
  ENDLOOP.

*----------------------------------------------------------------------*
* STEP 7 — Configure Layout and Display ALV
*----------------------------------------------------------------------*

  gs_layout-zebra      = 'X'.     " Alternating row shading
  gs_layout-cwidth_opt = 'X'.     " Auto-fit column widths
  gs_layout-info_fname = 'COLOR'. " Link color field for row highlighting

  CREATE OBJECT go_custom
    EXPORTING container_name = 'MAIN_CONTAINER'.

  CREATE OBJECT go_alv
    EXPORTING i_parent = go_custom.

  go_alv->set_table_for_first_display(
    EXPORTING is_layout      = gs_layout
    CHANGING  it_outtab      = it_report
              it_fieldcatalog = it_fcat ).
