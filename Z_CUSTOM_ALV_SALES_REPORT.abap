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
      it_fcat   TYPE slis_t_fieldcat_alv,
      wa_fcat   TYPE slis_fieldcat_alv,
      gs_layout TYPE slis_layout_alv.

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

  IF sy-subrc <> 0.
    MESSAGE 'No sales orders found for the given selection' TYPE 'S'.
    LEAVE LIST-PROCESSING.
  ENDIF.

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

  PERFORM build_fieldcat.

  gs_layout-zebra             = 'X'.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-info_fieldname    = 'COLOR'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = gs_layout
      it_fieldcat        = it_fcat
      i_save             = 'A'
    TABLES
      t_outtab           = it_report
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

FORM build_fieldcat.

  DATA: lv_pos TYPE i VALUE 1.

  DEFINE add_field.
    CLEAR wa_fcat.
    wa_fcat-col_pos   = lv_pos.
    wa_fcat-fieldname = &1.
    wa_fcat-seltext_l = &2.
    wa_fcat-seltext_m = &2.
    wa_fcat-seltext_s = &2.
    wa_fcat-key       = &3.
    wa_fcat-do_sum    = &4.
    wa_fcat-no_out    = &5.
    APPEND wa_fcat TO it_fcat.
    lv_pos = lv_pos + 1.
  END-OF-DEFINITION.

  add_field 'VBELN'  'Sales Order'        'X'  ''   ''.
  add_field 'ERDAT'  'Created On'         ''   ''   ''.
  add_field 'AUART'  'Order Type'         ''   ''   ''.
  add_field 'VKORG'  'Sales Org'          ''   ''   ''.
  add_field 'KUNNR'  'Customer'           ''   ''   ''.
  add_field 'NAME1'  'Customer Name'      ''   ''   ''.
  add_field 'POSNR'  'Item'               ''   ''   ''.
  add_field 'MATNR'  'Material'           ''   ''   ''.
  add_field 'ARKTX'  'Description'        ''   ''   ''.
  add_field 'KWMENG' 'Qty'                ''   'X'  ''.
  add_field 'NETWR'  'Net Value'          ''   'X'  ''.
  add_field 'WAERK'  'Curr'               ''   ''   ''.
  add_field 'COLOR'  'Color Key'          ''   ''   'X'.

ENDFORM.
