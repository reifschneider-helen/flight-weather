CLASS zcx_14_flight_weather_errors DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_t100_message.
    INTERFACES if_t100_dyn_msg.

    DATA mv_var1 TYPE string.
    DATA mv_var2 TYPE string.
    DATA mv_var3 TYPE string.
    DATA mv_var4 TYPE string.

    CONSTANTS:
      BEGIN OF invalid_flight_input_data,
        msgid TYPE symsgid VALUE 'ZMSG_14_FLIGHT_WEATH',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF invalid_flight_input_data.

    METHODS constructor
      IMPORTING
        !textid LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous OPTIONAL
        iv_var1 TYPE string OPTIONAL
        iv_var2 TYPE string OPTIONAL
        iv_var3 TYPE string OPTIONAL
        iv_var4 TYPE string OPTIONAL.

ENDCLASS.

CLASS zcx_14_flight_weather_errors IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( previous = previous ).

    me->mv_var1 = iv_var1.
    me->mv_var2 = iv_var2.
    me->mv_var3 = iv_var3.
    me->mv_var4 = iv_var4.

    IF textid IS SUPPLIED.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
