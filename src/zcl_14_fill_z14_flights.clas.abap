CLASS zcl_14_fill_z14_flights DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_14_fill_z14_flights IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA:
        lt_flights TYPE TABLE OF z14_flights.

    GET TIME STAMP FIELD DATA(lt_tstmp).

    TRY.

        SELECT
        FROM /dmo/flight
        FIELDS client,
               carrier_id,
               connection_id,
               flight_date,
               price,
               currency_code,
               plane_type_id,
               seats_max,
               seats_occupied,
               @sy-uname AS local_created_by,
               @lt_tstmp AS local_created_at,
               @sy-uname AS local_last_changed_by,
               @lt_tstmp AS local_last_changed_at,
               @lt_tstmp AS last_changed_at
         INTO TABLE @lt_flights.

        INSERT z14_flights
        FROM TABLE @lt_flights.

        IF sy-subrc <> 0.
          out->write( 'Error while inserting data' ).
        ELSE.
          out->write( 'Table was filled successfully' ).
        ENDIF.


      CATCH cx_root INTO DATA(lx_error).
        out->write( |Error: { lx_error->get_text( ) }| ).

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
