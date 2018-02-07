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


    DATA: LT_FLIGHT TYPE STANDARD TABLE OF SFLIGHT,
          LRF_DESCR TYPE REF TO CL_ABAP_TYPEDESCR,
          LV_JSON   TYPE STRING.


    SELECT * FROM SFLIGHT INTO TABLE LT_FLIGHT UP TO 10 ROWS .

* serialize table lt_flight into JSON, skipping initial fields and converting ABAP field names into camelCase
    LV_JSON = /UI2/CL_JSON=>SERIALIZE( DATA = LT_FLIGHT COMPRESS = ABAP_TRUE PRETTY_NAME = /UI2/CL_JSON=>PRETTY_MODE-CAMEL_CASE ).
    WRITE / LV_JSON.

    CLEAR LT_FLIGHT.

* deserialize JSON string json into internal table lt_flight doing camelCase to ABAP like field name mapping
    /UI2/CL_JSON=>DESERIALIZE( EXPORTING JSON = LV_JSON PRETTY_NAME = /UI2/CL_JSON=>PRETTY_MODE-CAMEL_CASE CHANGING DATA = LT_FLIGHT ).




* abap (itab) -> json
    DATA(O_WRITER_ITAB) = CL_SXML_STRING_WRITER=>CREATE( TYPE = IF_SXML=>CO_XT_JSON ).
    CALL TRANSFORMATION ID SOURCE VALUES = LT_FLIGHT RESULT XML O_WRITER_ITAB.
    DATA: LV_RESULT TYPE STRING.
    CL_ABAP_CONV_IN_CE=>CREATE( )->CONVERT( EXPORTING
                                              INPUT = O_WRITER_ITAB->GET_OUTPUT( )
                                            IMPORTING
                                              DATA = LV_RESULT ).

    WRITE: / 'ABAP (iTab) -> JSON: ', LV_RESULT.

* JSON -> ABAP (iTab)
    CLEAR LT_FLIGHT.
    CALL TRANSFORMATION ID SOURCE XML LV_RESULT RESULT VALUES = LT_FLIGHT.

    IF LINES( LT_FLIGHT ) > 0.
      WRITE: / 'JSON -> ABAP (iTab): ', LT_FLIGHT[ 1 ]-CARRID.
      WRITE: / 'JSON -> ABAP (iTab): ', LT_FLIGHT[ 1 ]-CONNID.
      WRITE: / 'JSON -> ABAP (iTab): ', LT_FLIGHT[ 1 ]-FLDATE.
      WRITE: / 'JSON -> ABAP (iTab): ', LT_FLIGHT[ 1 ]-PRICE.
    ENDIF.

* ABAP (iTab) -> JSON (trex)
    DATA(O_TREX) = NEW CL_TREX_JSON_SERIALIZER( LT_FLIGHT ).
    O_TREX->SERIALIZE( ).
    DATA(LV_TREX_JSON) = O_TREX->GET_DATA( ).

    WRITE: / 'ABAP (iTab) -> JSON (trex): ', LV_TREX_JSON.



  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  JSON_DEMO=>MAIN( ).
