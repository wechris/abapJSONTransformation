*&---------------------------------------------------------------------*
*& Report ZJSONTRANSFORMATION
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZJSONTRANSFORMATION.

CLASS JSON_DEMO DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS MAIN.
  PRIVATE SECTION.
    CLASS-DATA OUT TYPE REF TO IF_DEMO_OUTPUT.
ENDCLASS.

CLASS JSON_DEMO IMPLEMENTATION.
  METHOD MAIN.


    DATA: LT_FLIGHT     TYPE STANDARD TABLE OF SFLIGHT,
          LRF_DESCR     TYPE REF TO CL_ABAP_TYPEDESCR,
          LR_SELECTIONS TYPE REF TO CL_SALV_SELECTIONS,
          GR_TABLE      TYPE REF TO CL_SALV_TABLE,
          LV_JSON       TYPE STRING,
          LV_TREX_JSON  TYPE XSTRING.


    SELECT * FROM SFLIGHT INTO TABLE LT_FLIGHT UP TO 10 ROWS.

* serialize table lt_flight into JSON, skipping initial fields and converting ABAP field names into camelCase
    LV_JSON = /UI2/CL_JSON=>SERIALIZE( DATA = LT_FLIGHT COMPRESS = ABAP_TRUE PRETTY_NAME = /UI2/CL_JSON=>PRETTY_MODE-CAMEL_CASE ).

    " Display JSON in ABAP
    CALL TRANSFORMATION SJSON2HTML SOURCE XML LV_JSON
                               RESULT XML DATA(LVC_HTML).
    CL_ABAP_BROWSER=>SHOW_HTML( TITLE = 'ABAP (iTab) -> JSON: /ui2/cl_json=>serialize' HTML_STRING = CL_ABAP_CODEPAGE=>CONVERT_FROM( LVC_HTML ) ).

    CLEAR LT_FLIGHT.

* deserialize JSON string json into internal table lt_flight doing camelCase to ABAP like field name mapping
    /UI2/CL_JSON=>DESERIALIZE( EXPORTING JSON = LV_JSON PRETTY_NAME = /UI2/CL_JSON=>PRETTY_MODE-CAMEL_CASE CHANGING DATA = LT_FLIGHT ).

    CL_SALV_TABLE=>FACTORY(
       EXPORTING
          LIST_DISPLAY = 'X'
        IMPORTING
          R_SALV_TABLE = GR_TABLE
        CHANGING
          T_TABLE      = LT_FLIGHT ).
    GR_TABLE->SET_SCREEN_POPUP(
      START_COLUMN = 1
      END_COLUMN   = 100
      START_LINE   = 1
      END_LINE     = 20 ).
*    lr_selections = gr_table->get_selections( ).
*    lr_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).
    GR_TABLE->DISPLAY( ).




*    CALL FUNCTION 'RS_COMPLEX_OBJECT_EDIT'
*      EXPORTING
*        object_name          = 'TEXT'
*        mode                 = space
*      CHANGING
*        object               = lt_flight
*      EXCEPTIONS
*        object_not_supported = 1
*        OTHERS               = 2.


* abap (itab) -> json
    DATA(O_WRITER_ITAB) = CL_SXML_STRING_WRITER=>CREATE( TYPE = IF_SXML=>CO_XT_JSON ).
    CALL TRANSFORMATION ID SOURCE VALUES = LT_FLIGHT RESULT XML O_WRITER_ITAB.
    DATA: LV_RESULT TYPE STRING.
    CL_ABAP_CONV_IN_CE=>CREATE( )->CONVERT( EXPORTING
                                              INPUT = O_WRITER_ITAB->GET_OUTPUT( )
                                            IMPORTING
                                              DATA = LV_RESULT ).

    " Display JSON in ABAP
    CALL TRANSFORMATION SJSON2HTML SOURCE XML LV_JSON
                               RESULT XML LVC_HTML.
    CL_ABAP_BROWSER=>SHOW_HTML( TITLE = 'ABAP (iTab) -> JSON: Transformation' HTML_STRING = CL_ABAP_CODEPAGE=>CONVERT_FROM( LVC_HTML ) ).

* JSON -> ABAP (iTab)
    CLEAR LT_FLIGHT.
    CALL TRANSFORMATION ID SOURCE XML LV_RESULT RESULT VALUES = LT_FLIGHT.

    CL_SALV_TABLE=>FACTORY(
   EXPORTING
      LIST_DISPLAY = 'X'
    IMPORTING
      R_SALV_TABLE = GR_TABLE
    CHANGING
      T_TABLE      = LT_FLIGHT ).
    GR_TABLE->SET_SCREEN_POPUP(
      START_COLUMN = 1
      END_COLUMN   = 100
      START_LINE   = 1
      END_LINE     = 20 ).
*    lr_selections = gr_table->get_selections( ).
*    lr_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).
    GR_TABLE->DISPLAY( ).

* ABAP (iTab) -> JSON (trex)
    DATA(O_TREX) = NEW CL_TREX_JSON_SERIALIZER( LT_FLIGHT ).
    O_TREX->SERIALIZE( ).
    LV_TREX_JSON = O_TREX->GET_DATA( ).

    CALL METHOD CL_ABAP_CONV_IN_CE=>CREATE
      EXPORTING
        INPUT = LV_TREX_JSON
      RECEIVING
        CONV  = DATA(LR_CONV).
    LR_CONV->READ(
    IMPORTING
        DATA    = LV_JSON ).

    " Display JSON in ABAP
    CALL TRANSFORMATION SJSON2HTML SOURCE XML LV_JSON
    RESULT XML LVC_HTML.
    CL_ABAP_BROWSER=>SHOW_HTML( TITLE = 'ABAP (iTab) -> JSON: TTREX JSON Serializer' HTML_STRING = CL_ABAP_CODEPAGE=>CONVERT_FROM( LVC_HTML ) ).



  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  JSON_DEMO=>MAIN( ).
