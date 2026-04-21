REPORT z_custom_alv_sales_report LINE-SIZE 250 NO STANDARD PAGE HEADING.

TYPES: BEGIN OF ty_report,
         vbeln  TYPE vbak-vbeln,
         erdat  TYPE vbak-erdat,
         auart  TYPE vbak-auart,
         vkorg  TYPE vbak-vkorg,
         kunnr  TYPE kna1-kunnr,
         name1  TYPE kna1-name1,
         posnr  TYPE vbap-posnr,
         matnr  TYPE vbap-matnr,
         arktx  TYPE vbap-arktx,
         kwmeng TYPE vbap-kwmeng,
         netwr  TYPE vbap-netwr,
         waerk  TYPE vbak-waerk,
         color  TYPE c LENGTH 4,
       END OF ty_report.

DATA: it_report TYPE STANDARD TABLE OF ty_report,
      wa_report TYPE ty_report,
      it_fcat   TYPE lvc_t_fcat,
      wa_fcat   TYPE lvc_s_fcat,
      gs_layout TYPE lvc_s_layo,
      go_alv    TYPE REF TO cl_gui_alv_grid,
      go_custom TYPE REF TO cl_gui_custom_container.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: so_date  FOR sy-datum OBLIGATORY,
                  so_kunnr FOR kna1-kunnr,
                  so_auart FOR vbak-auart.
  PARAMETERS:     p_vkorg  TYPE vkorg DEFAULT '1000'.
SELECTION-SCREEN END OF BLOCK b1.

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

  LOOP AT it_report INTO wa_report.
    DATA(lv_days) = sy-datum - wa_report-erdat.

    IF lv_days > 30.
      wa_report-color = 'C610'.
    ELSEIF lv_days BETWEEN 15 AND 30.
      wa_report-color = 'C510'.
    ELSE.
      wa_report-color = 'C310'.
    ENDIF.

    MODIFY it_report FROM wa_report.
  ENDLOOP.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name     = sy-repid
      i_internal_tabname = 'IT_REPORT'
      i_inclname         = sy-repid
    CHANGING
      ct_fieldcat        = it_fcat.

  LOOP AT it_fcat INTO wa_fcat.
    CASE wa_fcat-fieldname.
      WHEN 'VBELN'.  wa_fcat-key    = 'X'. wa_fcat-coltext = 'Sales Order'.
      WHEN 'NETWR'.  wa_fcat-do_sum = 'X'. wa_fcat-coltext = 'Net Value'.
      WHEN 'KWMENG'. wa_fcat-do_sum = 'X'. wa_fcat-coltext = 'Qty'.
      WHEN 'COLOR'.  wa_fcat-no_out = 'X'.
    ENDCASE.
    MODIFY it_fcat FROM wa_fcat.
  ENDLOOP.

  gs_layout-zebra      = 'X'.
  gs_layout-cwidth_opt = 'X'.
  gs_layout-info_fname = 'COLOR'.

  CREATE OBJECT go_custom
    EXPORTING container_name = 'MAIN_CONTAINER'.

  CREATE OBJECT go_alv
    EXPORTING i_parent = go_custom.

  go_alv->set_table_for_first_display(
    EXPORTING is_layout       = gs_layout
    CHANGING  it_outtab       = it_report
              it_fieldcatalog = it_fcat ).
